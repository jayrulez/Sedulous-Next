using Sedulous.SDL;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Foundation.Logging.Debug;
using Sedulous.RHI;
using Sedulous.RHI.Vulkan;
using System.Collections;
using Sedulous.Renderer;
namespace RHITest.Triangle;

internal static
{
	public static SPIRVBindingOffsets SPIRV_BINDING_OFFSETS = .() { samplerOffset = 100, textureOffset = 200, constantBufferOffset = 300, storageTextureAndBufferOffset = 400 };
	public const bool D3D11_COMMANDBUFFER_EMULATION = false;
	public const uint32 DEFAULT_MEMORY_ALIGNMENT = 16;
	public const uint32 BUFFERED_FRAME_MAX_NUM = 2;
	public const uint32 SWAP_CHAIN_TEXTURE_NUM = BUFFERED_FRAME_MAX_NUM;

	public static Color<float> COLOR_0 = .() { r = 1.0f, g = 1.0f, b = 0.0f, a = 1.0f };
	public static Color<float> COLOR_1 = .() { r = 0.46f, g = 0.72f, b = 0.0f, a = 1.0f };

	public static uint16[?] g_IndexData = .(0, 1, 2);
}

struct BackBuffer
{
	public FrameBuffer frameBuffer;
	public Descriptor colorAttachment;
	public Texture texture;
}

struct Frame
{
	public DeviceSemaphore deviceSemaphore;
	public CommandAllocator commandAllocator;
	public CommandBuffer commandBuffer;
	public Descriptor constantBufferView;
	public DescriptorSet constantBufferDescriptorSet;
	public uint64 constantBufferViewOffset;
}

[CRepr]
struct ConstantBufferLayout
{
	public float[3] color;
	public float scale;
}

[CRepr]
struct Vertex
{
	public float[2] position;
	public float[2] uv;
}

class RHITestApplication : SDLApplication
{
	private readonly ILogger mLogger = null ~ delete _;

	private DeviceAllocator mDeviceAllocator = null;
	private Device mDevice = null;

	private SwapChain mSwapChain = null;
	private CommandQueue mCommandQueue = null;
	private QueueSemaphore mAcquireSemaphore = null;
	private QueueSemaphore mReleaseSemaphore = null;

	private DescriptorPool m_DescriptorPool = null;
	private PipelineLayout m_PipelineLayout = null;
	private Pipeline m_Pipeline = null;
	private DescriptorSet m_TextureDescriptorSet = null;
	private Descriptor m_TextureShaderResource = null;
	private Descriptor m_Sampler = null;
	private Buffer m_ConstantBuffer = null;
	private Buffer m_GeometryBuffer = null;
	private Texture m_Texture = null;

	private Frame[BUFFERED_FRAME_MAX_NUM] mFrames = .();
	private List<BackBuffer> mSwapChainBuffers = new .() ~ delete _;

	private List<Memory> m_MemoryAllocations;

	private uint64 m_GeometryOffset = 0;
	private float m_Transparency = 1.0f;
	private float m_Scale = 1.0f;

	private uint32 mSwapInterval = 0;

	private uint32 mFrameNum = uint32.MaxValue;

	private RendererPlugin mRendererPlugin = null ~ delete _;

	public this(String windowTitle, uint32 windowWidth, uint32 windowHeight)
		: base(mLogger = new DebugLogger(), windowTitle, windowWidth, windowHeight)
	{
	}

	protected override Result<void> OnStartup()
	{
		if (base.OnStartup() case .Err)
			return .Err;

		DeviceCreationDesc deviceDesc = .()
			{
				enableAPIValidation = true,
				enableNRIValidation = true,
				spirvBindingOffsets = SPIRV_BINDING_OFFSETS
			};

		Result result = CreateDeviceVK(deviceDesc, mDeviceAllocator, Logger, out mDevice);
		if (result != .SUCCESS)
		{
			Logger.LogError("Failed to create Device");
			return .Err;
		}

		mRendererPlugin = new .(mEngine, mDevice);

		mPlugins.Add(mRendererPlugin);

		return .Ok;
	}

	protected override Result<void> OnInitialize()
	{
		if (base.OnInitialize() case .Err)
			return .Err;

		var result = mDevice.GetCommandQueue(.GRAPHICS, out mCommandQueue);
		if (result != .SUCCESS)
			return .Err;

		ShaderCompiler compiler = scope .();

		List<uint8> fragmentShaderByteCode = scope .();

		Result<void> compileResult = compiler.CompileShader(.()
			{
				shaderPath = "shaders/Triangle.fs.hlsl",
				shaderStage = .FRAGMENT,
				shaderModel = "6_5",
				entryPoint = "main",
				outputType = .SPIRV,
				spirvBindingOffsets = SPIRV_BINDING_OFFSETS
			}, fragmentShaderByteCode);

		if (compileResult case .Err)
		{
			return .Err;
		}

		List<uint8> vertexShaderByteCode = scope .();

		compileResult = compiler.CompileShader(.()
			{
				shaderPath = "shaders/Triangle.vs.hlsl",
				shaderStage = .VERTEX,
				shaderModel = "6_5",
				entryPoint = "main",
				outputType = .SPIRV,
				spirvBindingOffsets = SPIRV_BINDING_OFFSETS
			}, vertexShaderByteCode);

		if (compileResult case .Err)
		{
			return .Err;
		}

		// Swap chain
		Format swapChainFormat = default;
		{
			SwapChainDesc swapChainDesc = .();
			swapChainDesc.windowSystemType = .WINDOWS;
			swapChainDesc.window = .()
				{
					windows = WindowsWindow()
						{
							hwnd = Window.SurfaceInfo.Handles[0]
						}
				};
			swapChainDesc.commandQueue = mCommandQueue;
			swapChainDesc.format = SwapChainFormat.BT709_G22_8BIT;
			swapChainDesc.verticalSyncInterval = mSwapInterval;
			swapChainDesc.width = (.)Window.Width;
			swapChainDesc.height = (.)Window.Height;
			swapChainDesc.textureNum = SWAP_CHAIN_TEXTURE_NUM;
			result = mDevice.CreateSwapChain(swapChainDesc, out mSwapChain);
			if (result != .SUCCESS)
				return .Err;

			uint32 swapChainTextureNum = 0;
			Texture* swapChainTextures = mSwapChain.GetTextures(ref swapChainTextureNum, ref swapChainFormat);

			for (uint32 i = 0; i < swapChainTextureNum; i++)
			{
				Texture2DViewDesc textureViewDesc = .() { texture = swapChainTextures[i], viewType = Texture2DViewType.COLOR_ATTACHMENT, format = swapChainFormat };

				Descriptor colorAttachment = null;
				result = mDevice.CreateTexture2DView(textureViewDesc, out colorAttachment);

				ClearValueDesc clearColor = .();
				clearColor.rgba32f = COLOR_0;

				FrameBufferDesc frameBufferDesc = .()
					{
						colorAttachmentNum = 1,
						colorAttachments = &colorAttachment,
						colorClearValues = &clearColor
					};
				FrameBuffer frameBuffer = null;
				result = mDevice.CreateFrameBuffer(frameBufferDesc, out frameBuffer);

				readonly BackBuffer backBuffer = .() { frameBuffer = frameBuffer, colorAttachment =  colorAttachment, texture = swapChainTextures[i] };
				mSwapChainBuffers.Add(backBuffer);
			}
		}

		result = mDevice.CreateQueueSemaphore(out mAcquireSemaphore);
		result = mDevice.CreateQueueSemaphore(out mReleaseSemaphore);

		// Buffered resources
		for (ref Frame frame in ref mFrames)
		{
			result = mDevice.CreateDeviceSemaphore(true, out frame.deviceSemaphore);
			result = mDevice.CreateCommandAllocator(mCommandQueue, WHOLE_DEVICE_GROUP, out frame.commandAllocator);
			result = frame.commandAllocator.CreateCommandBuffer(out frame.commandBuffer);
		}

		// Pipeline
		{
		}

		// Descriptor pool
		{
		}

		// Load texture
		{
		}

		// Resources
		{
		}

		// Descriptors
		{
		}

		// Descriptor sets
		{
		}

		// Upload data
		{
		}


		return .Ok;
	}

	protected override void OnFinalize()
	{
		mCommandQueue.WaitForIdle();

		for (ref Frame frame in ref mFrames)
		{
			mDevice.DestroyCommandBuffer(ref frame.commandBuffer);
			mDevice.DestroyCommandAllocator(ref frame.commandAllocator);
			mDevice.DestroyDeviceSemaphore(ref frame.deviceSemaphore);
			mDevice.DestroyDescriptor(ref frame.constantBufferView);
		}

		for (ref BackBuffer backBuffer in ref mSwapChainBuffers)
		{
			mDevice.DestroyFrameBuffer(ref backBuffer.frameBuffer);
			mDevice.DestroyDescriptor(ref backBuffer.colorAttachment);
		}
		mDevice.DestroyPipeline(ref m_Pipeline);
		mDevice.DestroyPipelineLayout(ref m_PipelineLayout);
		mDevice.DestroyDescriptor(ref m_TextureShaderResource);
		mDevice.DestroyDescriptor(ref m_Sampler);
		mDevice.DestroyBuffer(ref m_ConstantBuffer);
		mDevice.DestroyBuffer(ref m_GeometryBuffer);
		mDevice.DestroyTexture(ref m_Texture);
		mDevice.DestroyDescriptorPool(ref m_DescriptorPool);
		mDevice.DestroyQueueSemaphore(ref mAcquireSemaphore);
		mDevice.DestroyQueueSemaphore(ref mReleaseSemaphore);
		mDevice.DestroySwapChain(ref mSwapChain);

		for (Memory memory in m_MemoryAllocations)
			mDevice.FreeMemory(ref memory);

		base.OnFinalize();
	}

	private void PrepareFrame(uint32 frameIndex)
	{
	}

	private void RenderFrame(uint32 frameIndex)
	{
		readonly uint32 windowWidth = Window.Width;
		readonly uint32 windowHeight = Window.Height;
		readonly uint32 bufferedFrameIndex = frameIndex % BUFFERED_FRAME_MAX_NUM;
		readonly ref Frame frame = ref mFrames[bufferedFrameIndex];

		readonly uint32 backBufferIndex = mSwapChain.AcquireNextTexture(mAcquireSemaphore);
		readonly ref BackBuffer backBuffer = ref mSwapChainBuffers[backBufferIndex];

		mCommandQueue.Wait(frame.deviceSemaphore);
		frame.commandAllocator.Reset();

		CommandBuffer commandBuffer = frame.commandBuffer;
		commandBuffer.Begin(null, 0);
		{
			TextureTransitionBarrierDesc textureTransitionBarrierDesc = .();
			textureTransitionBarrierDesc.texture = backBuffer.texture;
			textureTransitionBarrierDesc.prevAccess = AccessBits.UNKNOWN;
			textureTransitionBarrierDesc.nextAccess = AccessBits.COLOR_ATTACHMENT;
			textureTransitionBarrierDesc.prevLayout = TextureLayout.UNKNOWN;
			textureTransitionBarrierDesc.nextLayout = TextureLayout.COLOR_ATTACHMENT;
			textureTransitionBarrierDesc.arraySize = 1;
			textureTransitionBarrierDesc.mipNum = 1;

			TransitionBarrierDesc transitionBarriers = .();
			transitionBarriers.textureNum = 1;
			transitionBarriers.textures = &textureTransitionBarrierDesc;
			commandBuffer.PipelineBarrier(&transitionBarriers, null, BarrierDependency.ALL_STAGES);

			commandBuffer.BeginRenderPass(backBuffer.frameBuffer, RenderPassBeginFlag.NONE);
			{
				commandBuffer.BeginAnnotation("Clear");

				ClearDesc clearDesc = .();
				clearDesc.colorAttachmentIndex = 0;

				clearDesc.value.rgba32f = .() { r = 1.0f, g = 0.0f, b = 0.0f, a = 1.0f };
				Rect rect1 = .() { left = 0, top = 0, width = windowWidth, height = windowHeight / 3 };
				commandBuffer.ClearAttachments(&clearDesc, 1, &rect1, 1);

				clearDesc.value.rgba32f = .() { r = 0.0f, g = 1.0f, b = 0.0f, a = 1.0f };
				Rect rect2 = .() { left = 0, top = (.)windowHeight / 3, width = windowWidth, height = windowHeight / 3 };
				commandBuffer.ClearAttachments(&clearDesc, 1, &rect2, 1);

				clearDesc.value.rgba32f = .() { r = 0.0f, g = 0.0f, b = 1.0f, a = 1.0f };
				Rect rect3 = .() { left = 0, top = (.)(windowHeight * 2) / 3, width = windowWidth, height = windowHeight / 3 };
				commandBuffer.ClearAttachments(&clearDesc, 1, &rect3, 1);
			}
			commandBuffer.EndRenderPass();

			textureTransitionBarrierDesc.prevAccess = textureTransitionBarrierDesc.nextAccess;
			textureTransitionBarrierDesc.nextAccess = AccessBits.UNKNOWN;
			textureTransitionBarrierDesc.prevLayout = textureTransitionBarrierDesc.nextLayout;
			textureTransitionBarrierDesc.nextLayout = TextureLayout.PRESENT;

			commandBuffer.PipelineBarrier(&transitionBarriers, null, BarrierDependency.ALL_STAGES);
		}
		commandBuffer.End();

		readonly CommandBuffer[] commandBuffers = scope .(commandBuffer);

		WorkSubmissionDesc workSubmissionDesc = .()
			{
				commandBufferNum = (.)commandBuffers.Count,
				commandBuffers = commandBuffers.Ptr,
				wait = &mAcquireSemaphore,
				waitNum = 1,
				signal = &mReleaseSemaphore,
				signalNum = 1
			};

		mCommandQueue.Submit(workSubmissionDesc, frame.deviceSemaphore);
		mSwapChain.Present(mReleaseSemaphore);
	}

	protected override void OnFrameEnd()
	{
		PrepareFrame(mFrameNum);
		RenderFrame(mFrameNum);
		mFrameNum++;
	}

	protected override void OnShutdown()
	{
		if (mRendererPlugin != null)
			delete mRendererPlugin;

		if (mDevice != null)
			delete mDevice;

		if (mDeviceAllocator != null)
			delete mDeviceAllocator;

		base.OnShutdown();
	}
}

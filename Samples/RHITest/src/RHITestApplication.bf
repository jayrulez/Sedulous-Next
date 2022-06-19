using Sedulous.SDL;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Foundation.Logging.Debug;
using Sedulous.RHI;
using Sedulous.RHI.Vulkan;
using System.Collections;
namespace RHITest;

/**
public uint32 samplerOffset;
public uint32 textureOffset;
public uint32 constantBufferOffset;
public uint32 storageTextureAndBufferOffset;
*/

internal static
{
	public static SPIRVBindingOffsets SPIRV_BINDING_OFFSETS = .() { samplerOffset = 100, textureOffset = 200, constantBufferOffset = 300, storageTextureAndBufferOffset = 400 };
	public const bool D3D11_COMMANDBUFFER_EMULATION = false;
	public const  uint32 DEFAULT_MEMORY_ALIGNMENT = 16;
	public const  uint32 BUFFERED_FRAME_MAX_NUM = 2;
	public const  uint32 SWAP_CHAIN_TEXTURE_NUM = BUFFERED_FRAME_MAX_NUM;
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
}

class RHITestApplication : SDLApplication
{
	private readonly ILogger mLogger = null ~ delete _;

	private DeviceAllocator mDeviceAllocator = null;
	private Device mDevice = null;

	private SwapChain m_SwapChain = null;
	private CommandQueue m_CommandQueue = null;
	private QueueSemaphore m_AcquireSemaphore = null;
	private QueueSemaphore m_ReleaseSemaphore = null;

	private Frame[BUFFERED_FRAME_MAX_NUM] m_Frames = .();
	private List<BackBuffer> m_SwapChainBuffers = new .() ~ delete _;

	private uint32 mSwapInterval = 0;

	private uint32 mFrameNum = uint32.MaxValue;

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

		return .Ok;
	}

	protected override Result<void> OnInitialize()
	{
		if (base.OnInitialize() case .Err)
			return .Err;

		var result = mDevice.GetCommandQueue(.GRAPHICS, out m_CommandQueue);
		if (result != .SUCCESS)
			return .Err;

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
			swapChainDesc.commandQueue = m_CommandQueue;
			swapChainDesc.format = SwapChainFormat.BT709_G22_8BIT;
			swapChainDesc.verticalSyncInterval = mSwapInterval;
			swapChainDesc.width = (.)Window.Width;
			swapChainDesc.height = (.)Window.Height;
			swapChainDesc.textureNum = SWAP_CHAIN_TEXTURE_NUM;
			result = mDevice.CreateSwapChain(swapChainDesc, out m_SwapChain);
			if (result != .SUCCESS)
				return .Err;

			uint32 swapChainTextureNum = 0;
			Texture* swapChainTextures = m_SwapChain.GetTextures(ref swapChainTextureNum, ref swapChainFormat);

			for (uint32 i = 0; i < swapChainTextureNum; i++)
			{
				Texture2DViewDesc textureViewDesc = .() { texture = swapChainTextures[i], viewType = Texture2DViewType.COLOR_ATTACHMENT, format = swapChainFormat };

				Descriptor colorAttachment = null;
				result = mDevice.CreateTexture2DView(textureViewDesc, out colorAttachment);

				FrameBufferDesc frameBufferDesc = .()
					{
						colorAttachmentNum = 1,
						colorAttachments = &colorAttachment
					};
				FrameBuffer frameBuffer = null;
				result = mDevice.CreateFrameBuffer(frameBufferDesc, out frameBuffer);

				readonly BackBuffer backBuffer = .() { frameBuffer = frameBuffer, colorAttachment =  colorAttachment, texture = swapChainTextures[i] };
				m_SwapChainBuffers.Add(backBuffer);
			}
		}

		result = mDevice.CreateQueueSemaphore(out m_AcquireSemaphore);
		result = mDevice.CreateQueueSemaphore(out m_ReleaseSemaphore);

		// Buffered resources
		for (ref Frame frame in ref m_Frames)
		{
			result = mDevice.CreateDeviceSemaphore(true, out frame.deviceSemaphore);
			result = mDevice.CreateCommandAllocator(m_CommandQueue, WHOLE_DEVICE_GROUP, out frame.commandAllocator);
			result = frame.commandAllocator.CreateCommandBuffer(out frame.commandBuffer);
		}

		return .Ok;
	}

	protected override void OnFinalize()
	{
		m_CommandQueue.WaitForIdle();

		for (ref Frame frame in ref m_Frames)
		{
			mDevice.DestroyCommandBuffer(ref frame.commandBuffer);
			mDevice.DestroyCommandAllocator(ref frame.commandAllocator);
			mDevice.DestroyDeviceSemaphore(ref frame.deviceSemaphore);
		}

		for (ref BackBuffer backBuffer in ref m_SwapChainBuffers)
		{
			mDevice.DestroyFrameBuffer(ref backBuffer.frameBuffer);
			mDevice.DestroyDescriptor(ref backBuffer.colorAttachment);
		}

		mDevice.DestroyQueueSemaphore(ref m_AcquireSemaphore);
		mDevice.DestroyQueueSemaphore(ref m_ReleaseSemaphore);
		mDevice.DestroySwapChain(ref m_SwapChain);

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
		readonly ref Frame frame = ref m_Frames[bufferedFrameIndex];

		readonly uint32 backBufferIndex = m_SwapChain.AcquireNextTexture(m_AcquireSemaphore);
		readonly ref BackBuffer backBuffer = ref m_SwapChainBuffers[backBufferIndex];

		m_CommandQueue.Wait(frame.deviceSemaphore);
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
				Rect rect2 = .() { left = 0, top = (int32)windowHeight / 3, width = windowWidth, height = windowHeight / 3 };
				commandBuffer.ClearAttachments(&clearDesc, 1, &rect2, 1);

				clearDesc.value.rgba32f = .() { r = 0.0f, g = 0.0f, b = 1.0f, a = 1.0f };
				Rect rect3 = .() { left = 0, top = (int32)(windowHeight * 2) / 3, width = windowWidth, height = windowHeight / 3 };
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

		readonly CommandBuffer[] commandBufferArray = scope .(commandBuffer);

		WorkSubmissionDesc workSubmissionDesc = .()
			{
				commandBufferNum = (.)commandBufferArray.Count,
				commandBuffers = commandBufferArray.Ptr,
				wait = &m_AcquireSemaphore,
				waitNum = 1,
				signal = &m_ReleaseSemaphore,
				signalNum = 1
			};

		m_CommandQueue.Submit(workSubmissionDesc, frame.deviceSemaphore);
		m_SwapChain.Present(m_ReleaseSemaphore);
	}

	protected override void OnFrameEnd()
	{
		RenderFrame(mFrameNum++);
	}

	protected override void OnShutdown()
	{
		if (mDevice != null)
			delete mDevice;

		if (mDeviceAllocator != null)
			delete mDeviceAllocator;

		base.OnShutdown();
	}
}

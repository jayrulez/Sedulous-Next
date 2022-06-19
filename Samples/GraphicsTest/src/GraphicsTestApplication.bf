using Sedulous.SDL;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Foundation.Logging.Debug;
using Sedulous.Foundation.Mathematics;
using Sedulous.Graphics;
using System.Collections;
using System.IO;
using Sedulous.Platform;
using Sedulous.Graphics.Vulkan;
namespace GraphicsTest
{
	class GraphicsTestApplication : SDLApplication
	{
		private readonly ILogger mLogger = null ~ delete _;

		private ValidationLayer mGraphicsValidationLayer = null;
		protected FrameBuffer mFrameBuffer => mSwapChain.FrameBuffer;
		protected GraphicsContext mGraphicsContext = null;
		protected SwapChain mSwapChain = null;

		private Vector4[] vertexData = new Vector4[]
			( // TriangleList
			Vector4(0f, 0.5f, 0.0f, 1.0f), Vector4(1.0f, 0.0f, 0.0f, 1.0f),
			Vector4(0.5f, -0.5f, 0.0f, 1.0f), Vector4(0.0f, 1.0f, 0.0f, 1.0f),
			Vector4(-0.5f, -0.5f, 0.0f, 1.0f), Vector4(0.0f, 0.0f, 1.0f, 1.0f)
			) ~ delete _;

		private Viewport[] viewports;
		private Rect[] scissors;
		private CommandQueue commandQueue;
		private GraphicsPipelineState pipelineState;
		private Buffer[] vertexBuffers;

		
		protected TextureSampleCount SampleCount = TextureSampleCount.None;

		private SwapChainDescription CreateSwapChainDescription(uint32 width, uint32 height, ref SurfaceInfo surfaceInfo)
		{
			return SwapChainDescription()
				{
					Width = width,
					Height = height,
					SurfaceInfo = surfaceInfo,
					ColorTargetFormat = PixelFormat.R8G8B8A8_UNorm,
					ColorTargetFlags = TextureFlags.RenderTarget | TextureFlags.ShaderResource,
					DepthStencilTargetFormat = PixelFormat.D24_UNorm_S8_UInt,
					DepthStencilTargetFlags = TextureFlags.DepthStencil,
					SampleCount = this.SampleCount,
					IsWindowed = true,
					RefreshRate = 60
				};
		}

		public this(String windowTitle, uint32 windowWidth, uint32 windowHeight)
			: base(mLogger = new DebugLogger(), windowTitle, windowWidth, windowHeight)
		{
		}

		protected override Result<void> OnStartup()
		{
			if (base.OnStartup() case .Err)
				return .Err;

			mGraphicsValidationLayer = new ValidationLayer(.Trace);
			mGraphicsContext = new VKGraphicsContext();

			mGraphicsContext.DefaultTextureUploaderSize = 128 * 1024 * 1024;
			mGraphicsContext.DefaultBufferUploaderSize = 64 * 1024 * 1024;

			mGraphicsContext.CreateDevice(mGraphicsValidationLayer);

			SwapChainDescription swapChainDescription = CreateSwapChainDescription(Window.Width, Window.Height, ref Window.SurfaceInfo);
			mSwapChain = mGraphicsContext.CreateSwapChain(swapChainDescription);

			return .Ok;
		}

		protected override Result<void> OnInitialize()
		{
			base.OnInitialize();

			List<uint8> vsBytes = scope .();
			if (File.ReadAll("Shaders/VertexShader.spirv", vsBytes) case .Err) Console.WriteLine("ERROR: Failed to read vertex shader");

			List<uint8> psBytes = scope .();
			if (File.ReadAll("Shaders/FragmentShader.spirv", psBytes) case .Err) Console.WriteLine("ERROR: Failed to read fragment shader");

			// Compile Vertex and Pixel shaders
			ShaderDescription vertexShaderDescription = ShaderDescription(.Vertex, "VS", vsBytes); //await this.assetsDirectory.ReadAndCompileShader(mGraphicsContext, "HLSL", "VertexShader", ShaderStages.Vertex, "VS");
			ShaderDescription pixelShaderDescription = ShaderDescription(.Pixel, "PS", psBytes); //await this.assetsDirectory.ReadAndCompileShader(mGraphicsContext, "HLSL", "FragmentShader", ShaderStages.Pixel, "PS");

			Shader vertexShader = mGraphicsContext.Factory.CreateShader(ref vertexShaderDescription);
			Shader pixelShader = mGraphicsContext.Factory.CreateShader(ref pixelShaderDescription);

			BufferDescription vertexBufferDescription = BufferDescription((.)sizeof(Vector4) * (.)this.vertexData.Count, BufferFlags.VertexBuffer, ResourceUsage.Default);
			Buffer vertexBuffer = mGraphicsContext.Factory.CreateBuffer(this.vertexData, ref vertexBufferDescription);

			// Prepare Pipeline
			InputLayouts vertexLayouts = scope InputLayouts()
				.Add(scope LayoutDescription()
				.Add(ElementDescription(ElementFormat.Float4, ElementSemanticType.Position))
				.Add(ElementDescription(ElementFormat.Float4, ElementSemanticType.Color)));

			GraphicsPipelineDescription pipelineDescription = GraphicsPipelineDescription()
				{
					PrimitiveTopology = PrimitiveTopology.TriangleList,
					InputLayouts = vertexLayouts,
					Shaders = scope GraphicsShaderStateDescription()
						{
							VertexShader = vertexShader,
							PixelShader = pixelShader
						},
					RenderStates = RenderStateDescription()
						{
							RasterizerState = RasterizerStates.CullBack,
							BlendState = BlendStates.Opaque,
							DepthStencilState = DepthStencilStates.ReadWrite
						},
					Outputs = mFrameBuffer.OutputDescription
				};

			this.pipelineState = mGraphicsContext.Factory.CreateGraphicsPipeline(ref pipelineDescription);
			this.commandQueue = mGraphicsContext.Factory.CreateCommandQueue();

			var swapChainDescription = mSwapChain?.SwapChainDescription;
			var width = swapChainDescription.HasValue ? swapChainDescription.Value.Width : Window.Width;
			var height = swapChainDescription.HasValue ? swapChainDescription.Value.Height : Window.Height;

			this.viewports = new Viewport[1];
			this.viewports[0] = Viewport(0, 0, width, height);
			this.scissors = new Rect[1];
			this.scissors[0] = Rect(0, 0, (int)width, (int)height);

			this.vertexBuffers = new Buffer[1];
			this.vertexBuffers[0] = vertexBuffer;

			vertexShader.Dispose();
			delete vertexShader;

			pixelShader.Dispose();
			delete pixelShader;

			return .Ok;
		}

		protected override void OnFinalize()
		{
			if (viewports != null)
			{
				delete viewports;
			}
			if (scissors != null)
			{
				delete scissors;
			}
			if (commandQueue != null)
			{
				commandQueue.Dispose();
				defer:: delete commandQueue;
			}

			if (pipelineState != null)
			{
				pipelineState.Dispose();
				defer:: delete pipelineState;
			}

			if (vertexBuffers != null)
			{
				for (var buffer in vertexBuffers)
				{
					buffer.Dispose();
					defer:: delete buffer;
				}
				delete vertexBuffers;
			}
		}

		protected override void OnShutdown(){
			
			if (mSwapChain != null){
				mSwapChain.Dispose();
				defer :: delete mSwapChain;
			}

			if (mGraphicsContext != null){
				mGraphicsContext.Dispose();
				defer :: delete mGraphicsContext;
			}

			if (mGraphicsValidationLayer != null){
				delete mGraphicsValidationLayer;
			}

			base.OnShutdown();
		}

		protected override void OnFrameBegin()
		{
			base.OnFrameBegin();
		}

		protected override void OnFrameEnd()
		{
			CommandBuffer commandBuffer = this.commandQueue.CommandBuffer();

			commandBuffer.Begin();

			RenderPassDescription renderPassDescription = RenderPassDescription(mFrameBuffer, ClearValue(ClearFlags.All, 1, 0, Color.CornflowerBlue.ToVector4()));
			commandBuffer.BeginRenderPass(ref renderPassDescription);

			commandBuffer.SetViewports(this.viewports);
			commandBuffer.SetScissorRectangles(this.scissors);
			commandBuffer.SetGraphicsPipelineState(this.pipelineState);
			commandBuffer.SetVertexBuffers(this.vertexBuffers);

			commandBuffer.Draw((.)this.vertexData.Count / 2);

			commandBuffer.EndRenderPass();
			commandBuffer.End();

			commandBuffer.Commit();

			this.commandQueue.Submit();
			this.commandQueue.WaitIdle();

			mSwapChain.Present();

			base.OnFrameEnd();
		}
	}
}
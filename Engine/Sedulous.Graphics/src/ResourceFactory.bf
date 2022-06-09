using System;
using Sedulous.Graphics.Raytracing;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This Factory allow create GPU device resources.
	/// </summary>
	public abstract class ResourceFactory
	{
		/// <summary>
		/// Gets the generic graphicsContext.
		/// </summary>
		protected abstract GraphicsContext GraphicsContext { get; }

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.CommandQueue" /> instance.
		/// </summary>
		/// <param name="queueType">The commandQueue type, <see cref="T:Sedulous.Graphics.CommandQueueType" />.</param>
		/// <returns>The new commandQueue.</returns>
		public CommandQueue CreateCommandQueue(CommandQueueType queueType = CommandQueueType.Graphics)
		{
			GraphicsContext.ValidationLayer?.CreateCommandQueueValidation(queueType);
			return CreateCommandQueueInternal(queueType);
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.CommandQueue" /> instance.
		/// </summary>
		/// <param name="queueType">The commandQueue type, <see cref="T:Sedulous.Graphics.CommandQueueType" />.</param>
		/// <returns>The new commandQueue.</returns>
		[Inline]
		protected abstract CommandQueue CreateCommandQueueInternal(CommandQueueType queueType = CommandQueueType.Graphics);

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.GraphicsPipelineState" /> instance.
		/// </summary>
		/// <param name="description">The graphics pipelinestate description.</param>
		/// <returns>The new pipelinestate.</returns>
		public GraphicsPipelineState CreateGraphicsPipeline(ref GraphicsPipelineDescription description)
		{
			GraphicsContext.ValidationLayer?.CreateGraphicsPipelineValidation(ref description);
			return CreateGraphicsPipelineInternal(ref description);
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.GraphicsPipelineState" /> instance.
		/// </summary>
		/// <param name="description">The graphics pipelinestate description.</param>
		/// <returns>The new pipelinestate.</returns>
		[Inline]
		protected abstract GraphicsPipelineState CreateGraphicsPipelineInternal(ref GraphicsPipelineDescription description);

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.ComputePipelineState" /> instance.
		/// </summary>
		/// <param name="description">The compute pipelinestate description.</param>
		/// <returns>The new pipelinestate.</returns>
		public ComputePipelineState CreateComputePipeline(ref ComputePipelineDescription description)
		{
			GraphicsContext.ValidationLayer?.CreateComputePipelineValidation(ref description);
			return CreateComputePipelineInternal(ref description);
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.ComputePipelineState" /> instance.
		/// </summary>
		/// <param name="description">The compute pipelinestate description.</param>
		/// <returns>The new pipelinestate.</returns>
		[Inline]
		protected abstract ComputePipelineState CreateComputePipelineInternal(ref ComputePipelineDescription description);

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Raytracing.RaytracingPipelineState" /> instance.
		/// </summary>
		/// <param name="description">The raytracing pipelinestate description.</param>
		/// <returns>The new pipelinestate.</returns>
		public RaytracingPipelineState CreateRaytracingPipeline(ref RaytracingPipelineDescription description)
		{
			GraphicsContext.ValidationLayer?.CreateRaytracingPipelineValidation(ref description);
			return CreateRaytracingPipelineInternal(ref description);
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Raytracing.RaytracingPipelineState" /> instance.
		/// </summary>
		/// <param name="description">The raytracing pipelinestate description.</param>
		/// <returns>The new pipelinestate.</returns>
		[Inline]
		protected abstract RaytracingPipelineState CreateRaytracingPipelineInternal(ref RaytracingPipelineDescription description);

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Texture" /> instance.
		/// </summary>
		/// <param name="description">The texture description.</param>
		/// <param name="debugName">The texture name (Debug purposes).</param>
		/// <returns>The new texture.</returns>
		public Texture CreateTexture(ref TextureDescription description, String debugName = null)
		{
			SamplerStateDescription samplerState = SamplerStates.LinearWrap;
			Texture texture = CreateTexture(null, ref description, ref samplerState);
			texture.Name = debugName;
			return texture;
		}

		/// <summary>
		/// Gets a <see cref="T:Sedulous.Graphics.Texture" /> instance from an existing texture using the specified native pointer.
		/// </summary>
		/// <param name="texturePointer">The pointer of the texture.</param>
		/// <param name="textureDescription">The texture description of the already created texture.</param>
		/// <returns>The texture instance.</returns>
		public Texture GetTextureFromNativePointer(void* texturePointer, ref TextureDescription textureDescription)
		{
			if (texturePointer == null)
			{
				GraphicsContext.ValidationLayer?.Notify("Sedulous", "Texture pointer cannot be IntPtr.Zero in GetTextureFromNativePointer()");
			}
			return GetTextureFromNativePointerInternal(texturePointer, ref textureDescription);
		}

		/// <summary>
		/// Gets a <see cref="T:Sedulous.Graphics.Texture" /> instance from an existing texture using the specified native pointer.
		/// </summary>
		/// <param name="texturePointer">The pointer of the texture.</param>
		/// <param name="textureDescription">The texture description of the already created texture.</param>
		/// <returns>The texture instance.</returns>
		[Inline]
		protected abstract Texture GetTextureFromNativePointerInternal(void* texturePointer, ref TextureDescription textureDescription);

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Texture" /> instance.
		/// </summary>
		/// <param name="data">The texture data.</param>
		/// <param name="description">The texture description.</param>
		/// <param name="debugName">The texture name (Debug purposes).</param>
		/// <returns>The new texture1D.</returns>
		public Texture CreateTexture(DataBox[] data, ref TextureDescription description, String debugName = null)
		{
			SamplerStateDescription samplerState = SamplerStates.LinearWrap;
			Texture texture = CreateTexture(data, ref description, ref samplerState);
			texture.Name = debugName;
			return texture;
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Texture" /> instance.
		/// </summary>
		/// <param name="data">The texture data.</param>
		/// <param name="description">The texture description.</param>
		/// <param name="samplerState">The sampler state description <see cref="T:Sedulous.Graphics.SamplerStateDescription" /> struct.</param>
		/// <param name="debugName">The texture name (Debug pruposes).</param>
		/// <returns>The new texture.</returns>
		public Texture CreateTexture(DataBox[] data, ref TextureDescription description, ref SamplerStateDescription samplerState, String debugName = null)
		{
			GraphicsContext.ValidationLayer?.CreateTextureValidation(data, ref description, ref samplerState);
			Texture texture = CreateTextureInternal(data, ref description, ref samplerState);
			texture.Name = debugName;
			return texture;
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Texture" /> instance.
		/// </summary>
		/// <param name="data">The texture data.</param>
		/// <param name="description">The texture description.</param>
		/// <param name="samplerState">The sampler state description <see cref="T:Sedulous.Graphics.SamplerStateDescription" /> struct.</param>
		/// <returns>The new texture.</returns>
		[Inline]
		protected abstract Texture CreateTextureInternal(DataBox[] data, ref TextureDescription description, ref SamplerStateDescription samplerState);

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Buffer" /> instance.
		/// </summary>
		/// <param name="description">The index buffer description.</param>
		/// <param name="debugName">The buffer name (Debug purposes).</param>
		/// <returns>The new buffer.</returns>
		public Buffer CreateBuffer(ref BufferDescription description, String debugName = null)
		{
			Buffer buffer = CreateBuffer(null, ref description);
			buffer.Name = debugName;
			return buffer;
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Buffer" /> instance.
		/// </summary>
		/// <typeparam name="T">The data type.</typeparam>
		/// <param name="data">The data array.</param>
		/// <param name="description">The index buffer description.</param>
		/// <param name="debugName">The buffer name (Debug purposes).</param>
		/// <returns>The new buffer.</returns>
		public Buffer CreateBuffer<T>(T[] data, ref BufferDescription description, String debugName = null) where T : struct
		{
			Buffer buffer = CreateBuffer(data.Ptr, ref description);
			buffer.Name = debugName;
			return buffer;
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Buffer" /> instance.
		/// </summary>
		/// <typeparam name="T">The data type.</typeparam>
		/// <param name="data">The data reference.</param>
		/// <param name="description">The index buffer description.</param>
		/// <param name="debugName">The buffer name (Debug purposes).</param>
		/// <returns>The new buffer.</returns>
		public  Buffer CreateBuffer<T>(ref T data, ref BufferDescription description, String debugName = null) where T : struct
		{
			Buffer buffer = CreateBuffer(&data, ref description);
			buffer.Name = debugName;
			return buffer;
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Buffer" /> instance.
		/// </summary>
		/// <param name="data">Data pointer.</param>
		/// <param name="description">The index buffer description.</param>
		/// <param name="debugName">The buffer name (Debug purposes).</param>
		/// <returns>The new buffer.</returns>
		public Buffer CreateBuffer(void* data, ref BufferDescription description, String debugName = null)
		{
			GraphicsContext.ValidationLayer?.CreateBufferValidation(data, ref description);
			Buffer buffer = CreateBufferInternal(data, ref description);
			buffer.Name = debugName;
			return buffer;
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.Buffer" /> instance.
		/// </summary>
		/// <param name="data">Data pointer.</param>
		/// <param name="description">The index buffer description.</param>
		/// <returns>The new buffer.</returns>
		[Inline]
		protected abstract Buffer CreateBufferInternal(void* data, ref BufferDescription description);

		/// <summary>
		/// Create a <see cref="T:Sedulous.Graphics.QueryHeap" /> instance.
		/// </summary>
		/// <param name="description">The queryheap description.</param>
		/// <returns>The new queryheap.</returns>
		public abstract QueryHeap CreateQueryHeap(ref QueryHeapDescription description);

		/// <summary>
		/// Create a <see cref="T:Sedulous.Graphics.Shader" /> instance.
		/// </summary>
		/// <param name="description">The shader description.</param>
		/// <returns>The new shader.</returns>
		public Shader CreateShader(ref ShaderDescription description)
		{
			GraphicsContext.ValidationLayer?.CreateShaderValidation(ref description);
			return CreateShaderInternal(ref description);
		}

		/// <summary>
		/// Create a <see cref="T:Sedulous.Graphics.Shader" /> instance.
		/// </summary>
		/// <param name="description">The shader description.</param>
		/// <returns>The new shader.</returns>
		[Inline]
		protected abstract Shader CreateShaderInternal(ref ShaderDescription description);

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.SamplerState" /> instance.
		/// </summary>
		/// <param name="description">The sampler state description.</param>
		/// <returns>The new samplerstate.</returns>
		public SamplerState CreateSamplerState(ref SamplerStateDescription description)
		{
			GraphicsContext.ValidationLayer?.CreateSamplerStateValidation(ref description);
			return CreateSamplerStateInternal(ref description);
		}

		/// <summary>
		/// Creates a <see cref="T:Sedulous.Graphics.SamplerState" /> instance.
		/// </summary>
		/// <param name="description">The sampler state description.</param>
		/// <returns>The new samplerstate.</returns>
		[Inline]
		protected abstract SamplerState CreateSamplerStateInternal(ref SamplerStateDescription description);

		/// <summary>
		/// Create a <see cref="T:Sedulous.Graphics.FrameBuffer" /> instance.
		/// </summary>
		/// <param name="width">The with of the underlying textures.</param>
		/// <param name="height">The height of the underlying textures.</param>
		/// <param name="colorTargetPixelFormat">The pixel format of the color target.</param>
		/// <param name="depthTargetPixelFormat">The pixel format of the depth target.</param>
		/// <param name="debugName">The framebuffer textures names (Debug purposes).</param>
		/// <returns>The new framebuffer.</returns>
		public FrameBuffer CreateFrameBuffer(uint32 width, uint32 height, PixelFormat colorTargetPixelFormat = PixelFormat.R8G8B8A8_UNorm, PixelFormat depthTargetPixelFormat = PixelFormat.D24_UNorm_S8_UInt, String debugName = null)
		{
			TextureDescription colorTextureDescription = default(TextureDescription);
			colorTextureDescription.Format = colorTargetPixelFormat;
			colorTextureDescription.Width = width;
			colorTextureDescription.Height = height;
			colorTextureDescription.Depth = 1;
			colorTextureDescription.ArraySize = 1;
			colorTextureDescription.Faces = 1;
			colorTextureDescription.Flags = TextureFlags.ShaderResource | TextureFlags.RenderTarget;
			colorTextureDescription.CpuAccess = ResourceCpuAccess.None;
			colorTextureDescription.MipLevels = 1;
			colorTextureDescription.Type = TextureType.Texture2D;
			colorTextureDescription.Usage = ResourceUsage.Default;
			colorTextureDescription.SampleCount = TextureSampleCount.None;
			String colorDebugName = null;
			if(debugName != null)
			{
				colorDebugName = scope:: String(debugName);
				colorDebugName.Append("_Color");
			}
			Texture colorAttachment = CreateTexture(ref colorTextureDescription, colorDebugName);

			TextureDescription depthTextureDescription = default(TextureDescription);
			depthTextureDescription.Format = depthTargetPixelFormat;
			depthTextureDescription.Width = width;
			depthTextureDescription.Height = height;
			depthTextureDescription.Depth = 1;
			depthTextureDescription.ArraySize = 1;
			depthTextureDescription.Faces = 1;
			depthTextureDescription.Flags = TextureFlags.DepthStencil;
			depthTextureDescription.CpuAccess = ResourceCpuAccess.None;
			depthTextureDescription.MipLevels = 1;
			depthTextureDescription.Type = TextureType.Texture2D;
			depthTextureDescription.Usage = ResourceUsage.Default;
			depthTextureDescription.SampleCount = TextureSampleCount.None;
			String depthDebugName = null;
			if(debugName != null){
				depthDebugName = scope:: String(debugName);
				depthDebugName.Append("_Depth");
			}
			Texture depthAttachment = CreateTexture(ref depthTextureDescription, depthDebugName);

			FrameBufferAttachment value = FrameBufferAttachment(depthAttachment, 0, 1);
			FrameBufferAttachment[] colorTargets = new FrameBufferAttachment[1]
			(
				FrameBufferAttachment(colorAttachment, 0, 1)
			);
			return CreateFrameBuffer(value, colorTargets);
		}

		/// <summary>
		/// Create a <see cref="T:Sedulous.Graphics.FrameBuffer" /> instance.
		/// </summary>
		/// <param name="depthTarget">The depth <see cref="T:Sedulous.Graphics.FrameBufferAttachment" /> which must have been created with <see cref="F:Sedulous.Graphics.TextureFlags.DepthStencil" /> flag.</param>
		/// <param name="colorTargets">The array of color <see cref="T:Sedulous.Graphics.FrameBufferAttachment" /> , all of which must have been created with <see cref="F:Sedulous.Graphics.TextureFlags.RenderTarget" /> flags.</param>
		/// <param name="disposeAttachments">When this framebuffer is disposed, dispose the attachment textures too.</param>
		/// <returns>The new framebuffer.</returns>
		public FrameBuffer CreateFrameBuffer(FrameBufferAttachment? depthTarget, FrameBufferAttachment[] colorTargets, bool disposeAttachments = true)
		{
			return CreateFrameBufferInternal(depthTarget, colorTargets, disposeAttachments);
		}

		/// <summary>
		/// Create a <see cref="T:Sedulous.Graphics.FrameBuffer" /> instance.
		/// </summary>
		/// <param name="depthTarget">The depth <see cref="T:Sedulous.Graphics.FrameBufferAttachment" /> which must have been created with <see cref="F:Sedulous.Graphics.TextureFlags.DepthStencil" /> flag.</param>
		/// <param name="colorTargets">The array of color <see cref="T:Sedulous.Graphics.FrameBufferAttachment" /> , all of which must have been created with <see cref="F:Sedulous.Graphics.TextureFlags.RenderTarget" /> flags.</param>
		/// <param name="disposeAttachments">When this framebuffer is disposed, dispose the attachment textures too.</param>
		/// <returns>The new framebuffer.</returns>
		[Inline]
		protected abstract FrameBuffer CreateFrameBufferInternal(FrameBufferAttachment? depthTarget, FrameBufferAttachment[] colorTargets, bool disposeAttachments);

		/// <summary>
		/// Create a new <see cref="T:Sedulous.Graphics.ResourceLayout" />.
		/// </summary>
		/// <param name="description">The descriptions for all elements in this new resourceLayout.</param>
		/// <returns>A new resourceLayout Object.</returns>
		public ResourceLayout CreateResourceLayout(ref ResourceLayoutDescription description)
		{
			GraphicsContext.ValidationLayer?.CreateResourceLayoutValidation(ref description);
			return CreateResourceLayoutInternal(ref description);
		}

		/// <summary>
		/// Create a new <see cref="T:Sedulous.Graphics.ResourceLayout" />.
		/// </summary>
		/// <param name="description">The descriptions for all elements in this new resourceLayout.</param>
		/// <returns>A new resourceLayout Object.</returns>
		[Inline]
		protected abstract ResourceLayout CreateResourceLayoutInternal(ref ResourceLayoutDescription description);

		/// <summary>
		/// Create a new <see cref="T:Sedulous.Graphics.ResourceSet" />.
		/// </summary>
		/// <param name="description">The descriptions for all elements in this new resourceSet.</param>
		/// <returns>A new resourceSet Object.</returns>
		public ResourceSet CreateResourceSet(ref ResourceSetDescription description)
		{
			GraphicsContext.ValidationLayer?.CreateResourceSetValidation(ref description);
			return CreateResourceSetInternal(ref description);
		}

		/// <summary>
		/// Create a new <see cref="T:Sedulous.Graphics.ResourceSet" />.
		/// </summary>
		/// <param name="description">The descriptions for all elements in this new resourceSet.</param>
		/// <returns>A new resourceSet Object.</returns>
		[Inline]
		protected abstract ResourceSet CreateResourceSetInternal(ref ResourceSetDescription description);
	}
}

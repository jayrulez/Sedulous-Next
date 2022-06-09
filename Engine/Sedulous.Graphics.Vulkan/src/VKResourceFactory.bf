using System;
using Bulkan;
using Sedulous.Graphics;
using Sedulous.Graphics.Raytracing;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	/// <summary>
	/// The Vulkan version of the resource factory.
	/// </summary>
	public class VKResourceFactory : ResourceFactory
	{
		private VKGraphicsContext context;

		/// <inheritdoc />
		protected override GraphicsContext GraphicsContext => context;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKResourceFactory" /> class.
		/// </summary>
		/// <param name="graphicsContext">The Graphics Context.</param>
		public this(VKGraphicsContext graphicsContext)
		{
			context = graphicsContext;
		}

		/// <inheritdoc />
		protected override Sedulous.Graphics.Buffer CreateBufferInternal(void* data, ref BufferDescription description)
		{
			return new VKBuffer(context, data, ref description);
		}

		/// <inheritdoc />
		protected override CommandQueue CreateCommandQueueInternal(CommandQueueType queueType)
		{
			int32 num = -1;
			switch (queueType)
			{
			case CommandQueueType.Graphics:
				num = context.QueueIndices.GraphicsFamily;
				break;
			case CommandQueueType.Compute:
				num = context.QueueIndices.ComputeFamily;
				break;
			case CommandQueueType.Copy:
				num = context.QueueIndices.CopyFamily;
				break;
			}
			if (num >= 0)
			{
				return new VKCommandQueue(context, queueType);
			}
			if (context.ValidationLayer != null)
			{
				context.ValidationLayer.Notify("Vulkan", scope $"CommandQueue of type {queueType} is not supported.", ValidationLayer.Severity.Warning);
			}
			return null;
		}

		/// <inheritdoc />
		protected override ComputePipelineState CreateComputePipelineInternal(ref ComputePipelineDescription description)
		{
			return new VKComputePipelineState(context, ref description);
		}

		/// <inheritdoc />
		protected override RaytracingPipelineState CreateRaytracingPipelineInternal(ref RaytracingPipelineDescription description)
		{
			return new VKRaytracingPipelineState(context, ref description);
		}

		/// <inheritdoc />
		protected override FrameBuffer CreateFrameBufferInternal(FrameBufferAttachment? depthTarget, FrameBufferAttachment[] colorTargets, bool disposeAttachments)
		{
			return new VKFrameBuffer(context, depthTarget, colorTargets, disposeAttachments);
		}

		/// <inheritdoc />
		protected override GraphicsPipelineState CreateGraphicsPipelineInternal(ref GraphicsPipelineDescription description)
		{
			return new VKGraphicsPipelineState(context, ref description);
		}

		/// <inheritdoc />
		protected override ResourceLayout CreateResourceLayoutInternal(ref ResourceLayoutDescription description)
		{
			return new VKResourceLayout(context, ref description);
		}

		/// <inheritdoc />
		protected override ResourceSet CreateResourceSetInternal(ref ResourceSetDescription description)
		{
			return new VKResourceSet(context, ref description);
		}

		/// <inheritdoc />
		protected override SamplerState CreateSamplerStateInternal(ref SamplerStateDescription description)
		{
			return new VKSamplerState(context, ref description);
		}

		/// <inheritdoc />
		protected override Shader CreateShaderInternal(ref ShaderDescription description)
		{
			return new VKShader(context, ref description);
		}

		/// <inheritdoc />
		protected override Texture CreateTextureInternal(DataBox[] data, ref TextureDescription description, ref SamplerStateDescription samplerState)
		{
			return new VKTexture(context, data, ref description, ref samplerState);
		}

		/// <inheritdoc />
		protected override Texture GetTextureFromNativePointerInternal(void* texturePointer, ref TextureDescription textureDescription)
		{
			return VKTexture.FromVulkanImage(image: new VkImage((uint64)(int64)texturePointer), context: context, description: ref textureDescription);
		}

		/// <inheritdoc />
		public override QueryHeap CreateQueryHeap(ref QueryHeapDescription description)
		{
			return new VKQueryHeap(context, ref description);
		}
	}
}

using Bulkan;
using Sedulous.Graphics;
using System;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;
	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;
	/// <summary>
	/// This class represent the swapchain FrameBuffer on Vulkan.
	/// </summary>
	public class VKSwapChainFrameBuffer : VKFrameBufferBase
	{
		/// <summary>
		/// The colors texture array of this <see cref="T:Sedulous.Graphics.Vulkan.VKFrameBuffer" />.
		/// </summary>
		public VkImage[] BackBufferImages;

		/// <summary>
		/// The depth texture of this <see cref="T:Sedulous.Graphics.Vulkan.VKFrameBuffer" />.
		/// </summary>
		public VKTexture DepthTargetTexture;

		/// <summary>
		/// The array of frambuffers linked to this swapchain.
		/// </summary>
		public VKFrameBuffer[] FrameBuffers;

		private VKGraphicsContext vkContext;

		private String name;

		/// <summary>
		/// The active backBuffer index.
		/// </summary>
		public int32 CurrentBackBufferIndex;

		/// <inheritdoc />
		public override String Name
		{
			get
			{
				return name;
			}
			set
			{
				name = value;
			}
		}

		/// <inheritdoc />
		public override FrameBufferAttachment[] ColorTargets
		{
			get
			{
				return FrameBuffers[CurrentBackBufferIndex].ColorTargets;
			}
			protected set
			{
			}
		}

		/// <summary>
		/// Gets the current framebuffer based on CurrentBackBufferIndex.
		/// </summary>
		public VkFramebuffer CurrentBackBuffer => FrameBuffers[CurrentBackBufferIndex].NativeFrameBuffer;

		/// <inheritdoc />
		public override bool RequireFlipProjection => false;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKSwapChainFrameBuffer" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="swapchain">The swapchain to create from.</param>
		public  this(VKGraphicsContext context, VKSwapChain swapchain)
		{
			vkContext = context;
			SwapChainDescription swapChainDescription = swapchain.SwapChainDescription;
			base.Width = swapChainDescription.Width;
			base.Height = swapChainDescription.Height;
			base.IntermediateBufferAssociated = true;
			uint32 num = 0u;
			VulkanNative.vkGetSwapchainImagesKHR(context.VkDevice, swapchain.vkSwapChain, &num, null);
			BackBufferImages = new VkImage[num];
			VkImage* pSwapchainImages = BackBufferImages.Ptr;
			{
				VulkanNative.vkGetSwapchainImagesKHR(context.VkDevice, swapchain.vkSwapChain, &num, pSwapchainImages);
			}
			TextureSampleCount sampleCount = swapchain.SwapChainDescription.SampleCount;
			TextureDescription textureDescription = TextureDescription
			{
				Format = swapChainDescription.DepthStencilTargetFormat,
				ArraySize = 1u,
				Faces = 1u,
				MipLevels = 1u,
				Width = swapChainDescription.Width,
				Height = swapChainDescription.Height,
				Depth = 1u,
				SampleCount = TextureSampleCount.None,
				Flags = TextureFlags.DepthStencil
			};
			TextureDescription description = textureDescription;
			Texture texture = vkContext.Factory.CreateTexture(ref description);
			Texture resolvedTexture = null;
			if (sampleCount != 0)
			{
				description.SampleCount = sampleCount;
				resolvedTexture = texture;
				texture = vkContext.Factory.CreateTexture(ref description);
			}
			DepthStencilTarget = FrameBufferAttachment(texture, resolvedTexture);
			ColorTargets = new FrameBufferAttachment[1];
			FrameBuffers = new VKFrameBuffer[num];
			for (int i = 0; i < num; i++)
			{
				textureDescription = TextureDescription
				{
					Format = swapchain.vkSurfaceFormat.format.FromVulkan(),
					ArraySize = 1u,
					Faces = 1u,
					MipLevels = 1u,
					Depth = 1u,
					Width = swapchain.SwapChainDescription.Width,
					Height = swapchain.SwapChainDescription.Height,
					SampleCount = TextureSampleCount.None,
					Flags = TextureFlags.RenderTarget
				};
				TextureDescription description2 = textureDescription;
				Texture texture2 = VKTexture.FromVulkanImage(vkContext, ref description2, BackBufferImages[i]);
				Texture resolvedTexture2 = null;
				if (sampleCount != 0)
				{
					description2.SampleCount = sampleCount;
					resolvedTexture2 = texture2;
					texture2 = vkContext.Factory.CreateTexture(ref description2);
				}
				FrameBufferAttachment frameBufferAttachment = FrameBufferAttachment(texture2, resolvedTexture2);
				VKFrameBuffer vKFrameBuffer = new VKFrameBuffer(vkContext, DepthStencilTarget, new FrameBufferAttachment[1] ( frameBufferAttachment ), /*disposeAttachments:*/ true);
				FrameBuffers[i] = vKFrameBuffer;
			}
			base.OutputDescription = /*OutputDescription*/.CreateFromFrameBuffer(this);
		}

		/// <inheritdoc />
		public override void TransitionToIntermedialLayout(VkCommandBuffer cb)
		{
			FrameBufferAttachment[] colorTargets = FrameBuffers[CurrentBackBufferIndex].ColorTargets;
			for (int32 i = 0; i < colorTargets.Count; i++)
			{
				FrameBufferAttachment frameBufferAttachment = colorTargets[i];
				(frameBufferAttachment.Texture as VKTexture).SetImageLayout(0u, frameBufferAttachment.FirstSlice, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
			}
		}

		/// <inheritdoc />
		public override void TransitionToFinalLayout(VkCommandBuffer cb)
		{
			FrameBufferAttachment[] colorTargets = FrameBuffers[CurrentBackBufferIndex].ColorTargets;
			for (FrameBufferAttachment frameBufferAttachment in colorTargets)
			{
				(frameBufferAttachment.Texture as VKTexture).TransitionImageLayout(cb, VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, 0u, 1u, 0u, 1u);
			}
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
		protected override void Dispose(bool disposing)
		{
			if (!disposed && disposing)
			{
				DepthTargetTexture?.Dispose();
				for (int32 i = 0; i < FrameBuffers.Count; i++)
				{
					FrameBuffers[i]?.Dispose();
				}
			}
		}
	}
}

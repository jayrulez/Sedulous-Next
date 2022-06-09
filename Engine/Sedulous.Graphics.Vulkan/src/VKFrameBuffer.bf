using Bulkan;
using Sedulous.Graphics;
using System.Collections;
using System;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;
	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;

	/// <summary>
	/// This class represents a native FrameBuffer Object on Vulkan.
	/// </summary>
	public class VKFrameBuffer : VKFrameBufferBase
	{
		/// <summary>
		/// The Vulkan frameBuffer struct.
		/// </summary>
		public VkFramebuffer NativeFrameBuffer;

		/// <summary>
		/// Default Render Passes.
		/// </summary>
		public VkRenderPass[] defaultRenderPasses;

		private List<VkImageView> imageViews;

		private VKGraphicsContext vkContext;

		private String name;

		/// <inheritdoc />
		public override bool RequireFlipProjection => false;

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
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_FRAMEBUFFER, NativeFrameBuffer.Handle, name);
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKFrameBuffer" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="depthTarget">The depth texture which must have been created with <see cref="F:Sedulous.Graphics.TextureFlags.DepthStencil" /> flag.</param>
		/// <param name="colorTargets">The array of color textures, all of which must have been created with <see cref="F:Sedulous.Graphics.TextureFlags.RenderTarget" /> flags.</param>
		/// <param name="disposeAttachments">When this framebuffer is disposed, dispose the attachment textures too.</param>
		public  this(VKGraphicsContext context, FrameBufferAttachment? depthTarget, FrameBufferAttachment[] colorTargets, bool disposeAttachments)
			: base(depthTarget, colorTargets, disposeAttachments)
		{
			vkContext = context;
			CreateDefaultPasses();
			imageViews = new List<VkImageView>();
			for (int32 i = 0; i < colorTargets?.Count; i++)
			{
				FrameBufferAttachment frameBufferAttachment = ColorTargets[i];
				VKTexture vkTexture = frameBufferAttachment.AttachmentTexture as VKTexture;
				VkImageView item = CreateImageView(vkTexture, frameBufferAttachment.MipSlice, frameBufferAttachment.AttachedFirstSlice);
				imageViews.Add(item);
				VKTexture vKTexture = frameBufferAttachment.ResolvedTexture as VKTexture;
				if (vKTexture != null)
				{
					VkImageView item2 = CreateImageView(vKTexture, frameBufferAttachment.MipSlice, frameBufferAttachment.AttachedFirstSlice);
					imageViews.Add(item2);
				}
			}
			bool flag = false;
			if (depthTarget.HasValue)
			{
				VKTexture vKTexture2 = depthTarget.Value.AttachmentTexture as VKTexture;
				if (vKTexture2.Description.Format == PixelFormat.D24_UNorm_S8_UInt || vKTexture2.Description.Format == PixelFormat.D32_Float_S8X24_UInt)
				{
					flag = true;
				}
				VkImageAspectFlags flags = (flag ? (VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT) : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
				VkImageView item3 = CreateImageView(vKTexture2, depthTarget.Value.MipSlice, depthTarget.Value.AttachedFirstSlice, flags, /*depthTexture:*/ true);
				imageViews.Add(item3);
				VKTexture vKTexture3 = depthTarget.Value.ResolvedTexture as VKTexture;
				if (vKTexture3 != null)
				{
					VkImageView item4 = CreateImageView(vKTexture3, depthTarget.Value.MipSlice, depthTarget.Value.AttachedFirstSlice, flags);
					imageViews.Add(item4);
				}
			}
			VkFramebufferCreateInfo vkFramebufferCreateInfo = VkFramebufferCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
				width = base.Width,
				height = base.Height,
				attachmentCount = (uint32)imageViews.Count
			};
			VkImageView* pAttachments = imageViews.Ptr;
			{
				vkFramebufferCreateInfo.pAttachments = pAttachments;
			}
			vkFramebufferCreateInfo.layers = 1u;
			vkFramebufferCreateInfo.renderPass = defaultRenderPasses[7];
			VkFramebuffer nativeFrameBuffer = default(VkFramebuffer);
			VulkanNative.vkCreateFramebuffer(context.VkDevice, &vkFramebufferCreateInfo, null, &nativeFrameBuffer);
			NativeFrameBuffer = nativeFrameBuffer;
		}

		/// <summary>
		/// Generate a VKImageView from FrameBufferAttachment.
		/// </summary>
		/// <param name="vkTexture">Texture instance.</param>
		/// <param name="mipSlice">Miplevel slice.</param>
		/// <param name="firstSlice">First slice.</param>
		/// <param name="flags">Aspect flags.</param>
		/// <param name="depthTexture">This image view is a depth texture.</param>
		/// <returns>VkImageView instance.</returns>
		protected  VkImageView CreateImageView(VKTexture vkTexture, uint32 mipSlice, uint32 firstSlice, VkImageAspectFlags flags = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT, bool depthTexture = false)
		{
			VkImageViewCreateInfo vkImageViewCreateInfo = default(VkImageViewCreateInfo);
			vkImageViewCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
			vkImageViewCreateInfo.image = vkTexture.NativeImage;
			vkImageViewCreateInfo.format = vkTexture.Description.Format.ToVulkan(depthTexture);
			vkImageViewCreateInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
			if (flags == VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT)
			{
				vkImageViewCreateInfo.components.r = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
				vkImageViewCreateInfo.components.g = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
				vkImageViewCreateInfo.components.b = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
				vkImageViewCreateInfo.components.a = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
			}
			vkImageViewCreateInfo.subresourceRange = VkImageSubresourceRange
			{
				aspectMask = flags,
				baseMipLevel = mipSlice,
				levelCount = 1u,
				baseArrayLayer = firstSlice,
				layerCount = base.ArraySize
			};
			VkImageView result = default(VkImageView);
			VulkanNative.vkCreateImageView(vkContext.VkDevice, &vkImageViewCreateInfo, null, &result);
			return result;
		}

		private void CreateDefaultPasses()
		{
			defaultRenderPasses = new VkRenderPass[8];
			for (int32 i = 0; i < defaultRenderPasses.Count; i++)
			{
				ClearFlags clearFlags = (ClearFlags)i;
				VkAttachmentLoadOp targetLoadOp = (clearFlags.HasFlag(ClearFlags.Target) ? VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD);
				VkAttachmentLoadOp depthLoadOp = (clearFlags.HasFlag(ClearFlags.Depth) ? VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD);
				VkAttachmentLoadOp stencilLoadOp = (clearFlags.HasFlag(ClearFlags.Stencil) ? VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD);
				defaultRenderPasses[(int32)clearFlags] = CreateRenderPasses(targetLoadOp, depthLoadOp, stencilLoadOp);
			}
		}

		internal void GetRenderPass(ClearFlags clearFlags, out VkRenderPass renderPass)
		{
			renderPass = defaultRenderPasses[(int32)clearFlags];
		}

		private  VkRenderPass CreateRenderPasses(VkAttachmentLoadOp targetLoadOp, VkAttachmentLoadOp depthLoadOp, VkAttachmentLoadOp stencilLoadOp)
		{
			int32 num = ((ColorTargets != null) ? (.)ColorTargets.Count : 0);
			int32 num2 = num;
			if (DepthStencilTarget.HasValue)
			{
				num2++;
			}
			int32 num3 = num2 * 2;
			uint32 num4 = 0u;
			uint32 num5 = 0u;
			uint32 num6 = 0u;
			VkAttachmentDescription* ptr = scope VkAttachmentDescription[num3]*;
			VkAttachmentReference* ptr2 = scope VkAttachmentReference[num]*;
			VkAttachmentReference* ptr3 = scope VkAttachmentReference[num]*;
			if (ColorTargets != null)
			{
				for (int32 i = 0; i < num; i++)
				{
					FrameBufferAttachment frameBufferAttachment = ColorTargets[i];
					VKTexture vKTexture = frameBufferAttachment.AttachmentTexture as VKTexture;
					var (vkAttachmentDescription, vkAttachmentReference) = CreateAttachment(vKTexture.Description.Format.ToVulkan(/*depthFormat: */false), vKTexture.Description.SampleCount.ToVulkan(), num4, targetLoadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE, (targetLoadOp != VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE) ? VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL : VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
					ptr[num4++] = vkAttachmentDescription;
					ptr2[num5++] = vkAttachmentReference;
					VKTexture vKTexture2 = frameBufferAttachment.ResolvedTexture as VKTexture;
					if (vKTexture2 != null)
					{
						var (vkAttachmentDescription2, vkAttachmentReference2) = CreateAttachment(vKTexture2.Description.Format.ToVulkan(/*depthFormat:*/ false), vKTexture2.Description.SampleCount.ToVulkan(), num4, targetLoadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE, (targetLoadOp != VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE) ? VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL : VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
						ptr[num4++] = vkAttachmentDescription2;
						ptr3[num6++] = vkAttachmentReference2;
					}
				}
			}
			bool flag = false;
			VkAttachmentReference vkAttachmentReference4 = default(VkAttachmentReference);
			if (DepthStencilTarget.HasValue)
			{
				VKTexture vKTexture3 = DepthStencilTarget.Value.AttachmentTexture as VKTexture;
				if (vKTexture3.Description.Format == PixelFormat.D24_UNorm_S8_UInt || vKTexture3.Description.Format == PixelFormat.D32_Float_S8X24_UInt)
				{
					flag = true;
				}
				VkAttachmentDescription item = CreateAttachment(vKTexture3.Description.Format.ToVulkan(/*depthFormat:*/ true), vKTexture3.Description.SampleCount.ToVulkan(), num4, depthLoadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, flag ? stencilLoadOp : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE, (!flag) ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL).Item1;
				VkAttachmentReference vkAttachmentReference3 = default(VkAttachmentReference);
				vkAttachmentReference3.attachment = num4;
				vkAttachmentReference3.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
				vkAttachmentReference4 = vkAttachmentReference3;
				ptr[num4++] = item;
				VKTexture vKTexture4 = DepthStencilTarget.Value.ResolvedTexture as VKTexture;
				if (vKTexture4 != null)
				{
					VkAttachmentDescription item2 = CreateAttachment(vKTexture4.Description.Format.ToVulkan(/*depthFormat:*/ true), vKTexture4.Description.SampleCount.ToVulkan(), num4, depthLoadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, flag ? stencilLoadOp : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE, (!flag) ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL).Item1;
					vkAttachmentReference3 = default(VkAttachmentReference);
					vkAttachmentReference3.attachment = num4;
					vkAttachmentReference3.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
					ptr[num4++] = item2;
				}
			}
			VkSubpassDescription vkSubpassDescription = default(VkSubpassDescription);
			vkSubpassDescription.pipelineBindPoint = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;
			VkSubpassDescription vkSubpassDescription2 = vkSubpassDescription;
			if (num5 != 0)
			{
				vkSubpassDescription2.colorAttachmentCount = num5;
				vkSubpassDescription2.pColorAttachments = ptr2;
			}
			uint32 num7 = 1u;
			if (num6 != 0)
			{
				vkSubpassDescription2.pResolveAttachments = ptr3;
				num7++;
			}
			if (DepthStencilTarget.HasValue)
			{
				vkSubpassDescription2.pDepthStencilAttachment = &vkAttachmentReference4;
			}
			VkSubpassDependency* ptr4 = scope VkSubpassDependency[(int32)num7]*;
			VkSubpassDependency vkSubpassDependency;
			if (num6 == 0)
			{
				vkSubpassDependency = VkSubpassDependency
				{
					srcSubpass = uint32.MaxValue,
					dstSubpass = 0u,
					srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
					dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
					srcAccessMask = VkAccessFlags.VK_ACCESS_NONE,
					dstAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT)
				};
				*ptr4 = vkSubpassDependency;
			}
			else
			{
				vkSubpassDependency = VkSubpassDependency
				{
					srcSubpass = uint32.MaxValue,
					dstSubpass = 0u,
					srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
					dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
					srcAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT,
					dstAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
					dependencyFlags = VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT
				};
				*ptr4 = vkSubpassDependency;
				VkSubpassDependency* intPtr = ptr4 + 1;
				vkSubpassDependency = VkSubpassDependency
				{
					srcSubpass = 0u,
					dstSubpass = uint32.MaxValue,
					srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
					dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
					srcAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
					dstAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT,
					dependencyFlags = VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT
				};
				*intPtr = vkSubpassDependency;
			}
			VkRenderPassCreateInfo vkRenderPassCreateInfo = default(VkRenderPassCreateInfo);
			vkRenderPassCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
			vkRenderPassCreateInfo.attachmentCount = num4;
			vkRenderPassCreateInfo.pAttachments = ptr;
			vkRenderPassCreateInfo.subpassCount = 1u;
			vkRenderPassCreateInfo.pSubpasses = &vkSubpassDescription2;
			vkRenderPassCreateInfo.dependencyCount = num7;
			vkRenderPassCreateInfo.pDependencies = ptr4;
			VkRenderPassCreateInfo vkRenderPassCreateInfo2 = vkRenderPassCreateInfo;
			VkRenderPassMultiviewCreateInfo vkRenderPassMultiviewCreateInfo = default(VkRenderPassMultiviewCreateInfo);
			if (ColorTargets != null && ColorTargets[0].SliceCount > 1 && vkContext.Capabilities.MultiviewStrategy == MultiviewStrategy.ViewIndex)
			{
				uint32 num8 = (uint32)((1 << (int32)ColorTargets[0].SliceCount) - 1);
				vkRenderPassMultiviewCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_MULTIVIEW_CREATE_INFO;
				vkRenderPassMultiviewCreateInfo.subpassCount = 1u;
				vkRenderPassMultiviewCreateInfo.pViewMasks = &num8;
				vkRenderPassMultiviewCreateInfo.correlationMaskCount = 1u;
				vkRenderPassMultiviewCreateInfo.pCorrelationMasks = &num8;
				vkRenderPassCreateInfo2.pNext = &vkRenderPassMultiviewCreateInfo;
			}
			VkRenderPass result = default(VkRenderPass);
			VulkanNative.vkCreateRenderPass(vkContext.VkDevice, &vkRenderPassCreateInfo2, null, &result);
			return result;
		}

		private (VkAttachmentDescription, VkAttachmentReference) CreateAttachment(VkFormat format, VkSampleCountFlags samples, uint32 index, VkAttachmentLoadOp loadOp, VkAttachmentStoreOp storeOp, VkAttachmentLoadOp stencilLoadOp, VkAttachmentStoreOp stencilStoreOp, VkImageLayout initialLayout, VkImageLayout finalLayout)
		{
			VkAttachmentDescription vkAttachmentDescription = default(VkAttachmentDescription);
			vkAttachmentDescription.format = format;
			vkAttachmentDescription.samples = samples;
			vkAttachmentDescription.loadOp = loadOp;
			vkAttachmentDescription.storeOp = storeOp;
			vkAttachmentDescription.stencilLoadOp = stencilLoadOp;
			vkAttachmentDescription.stencilStoreOp = stencilStoreOp;
			vkAttachmentDescription.initialLayout = initialLayout;
			vkAttachmentDescription.finalLayout = finalLayout;
			VkAttachmentDescription item = vkAttachmentDescription;
			VkAttachmentReference item2 = VkAttachmentReference
			{
				attachment = index,
				layout = finalLayout
			};
			return (item, item2);
		}

		/// <inheritdoc />
		public override void TransitionToIntermedialLayout(VkCommandBuffer cb)
		{
			for (int32 i = 0; i < ColorTargets?.Count; i++)
			{
				FrameBufferAttachment frameBufferAttachment = ColorTargets[i];
				(frameBufferAttachment.Texture as VKTexture).SetImageLayout(frameBufferAttachment.MipSlice, frameBufferAttachment.FirstSlice, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
			}
			if (DepthStencilTarget.HasValue)
			{
				(DepthStencilTarget.Value.Texture as VKTexture).SetImageLayout(DepthStencilTarget.Value.MipSlice, DepthStencilTarget.Value.FirstSlice, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL);
			}
		}

		/// <inheritdoc />
		public override void TransitionToFinalLayout(VkCommandBuffer cb)
		{
			for (int32 i = 0; i < ColorTargets?.Count; i++)
			{
				FrameBufferAttachment frameBufferAttachment = ColorTargets[i];
				VKTexture vKTexture = frameBufferAttachment.Texture as VKTexture;
				if ((vKTexture.Description.Flags & TextureFlags.ShaderResource) != 0)
				{
					vKTexture.TransitionImageLayout(cb, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, frameBufferAttachment.MipSlice, 1u, frameBufferAttachment.FirstSlice, frameBufferAttachment.SliceCount);
				}
			}
			if (DepthStencilTarget.HasValue)
			{
				VKTexture vKTexture2 = DepthStencilTarget.Value.Texture as VKTexture;
				if ((vKTexture2.Description.Flags & TextureFlags.ShaderResource) != 0)
				{
					vKTexture2.TransitionImageLayout(cb, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, DepthStencilTarget.Value.MipSlice, 1u, DepthStencilTarget.Value.FirstSlice, 1u);
				}
			}
		}

		/// <inheritdoc />
		protected  override void Dispose(bool disposing)
		{
			if (disposed)
			{
				return;
			}
			if (disposing)
			{
				VulkanNative.vkDestroyFramebuffer(vkContext.VkDevice, NativeFrameBuffer, null);
				for (int32 i = 0; i < defaultRenderPasses.Count; i++)
				{
					VulkanNative.vkDestroyRenderPass(vkContext.VkDevice, defaultRenderPasses[i], null);
				}
				for (VkImageView imageView in imageViews)
				{
					VulkanNative.vkDestroyImageView(vkContext.VkDevice, imageView, null);
				}
			}
			disposed = true;
		}
	}
}

using System;
using Bulkan;
using Sedulous.Graphics;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;
	using internal Sedulous.Graphics.Vulkan;
	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;
	using static Sedulous.Graphics.Vulkan.VKHelpers;

	/// <summary>
	/// This class represents a native texture Object on Metal.
	/// </summary>
	public class VKTexture : Texture
	{
		/// <summary>
		/// The native Vulkan image Object.
		/// </summary>
		public VkImage NativeImage;

		/// <summary>
		/// The native vulkan memory linked with native image.
		/// </summary>
		public VkDeviceMemory ImageMemory;

		/// <summary>
		/// The native Vulkan buffer Object used for staging textures.
		/// </summary>
		public VkBuffer NativeBuffer;

		/// <summary>
		/// The native buffer memory linked with native buffer.
		/// </summary>
		public VkDeviceMemory BufferMemory;

		/// <summary>
		/// The memory requirements for this texture.
		/// </summary>
		public VkMemoryRequirements MemoryRequirements;

		/// <summary>
		/// The native Image layouts for this texture.
		/// </summary>
		public VkImageLayout[] ImageLayouts;

		/// <summary>
		/// The native pixel format for this texture.
		/// </summary>
		public VkFormat Format;

		private VKGraphicsContext vkContext;

		private VkImageView imageView;

		private String name;

		/// <inheritdoc />
		public override String Name
		{
			get
			{
				return name;
			}
			set
			{
				if (!String.IsNullOrEmpty(value))
				{
					name = value;
					vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_IMAGE, NativeImage.Handle, name);
				}
			}
		}

		/// <inheritdoc />
		public override void* NativePointer
		{
			get
			{
				if (Description.Usage == ResourceUsage.Staging)
				{
					return (void*)(int)NativeBuffer.Handle;
				}
				return (void*)(int)NativeImage.Handle;
			}
		}

		/// <summary>
		/// Gets the vulkan image view.
		/// </summary>
		public VkImageView ImageView
		{
			get
			{
				if (imageView.Handle == 0L)
				{
					imageView = GetImageView();
				}
				return imageView;
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKTexture" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="data">The data pointer.</param>
		/// <param name="description">The texture description.</param>
		/// <param name="samplerState">the sampler state description for this texture.</param>
		public  this(VKGraphicsContext context, DataBox[] data, ref TextureDescription description, ref SamplerStateDescription samplerState)
			: base(context, ref description)
		{
			vkContext = context;
			bool flag = description.Usage == ResourceUsage.Staging;
			if (flag)
			{
				uint32 num = Helpers.ComputeTextureSize(description);
				VkBufferCreateInfo vkBufferCreateInfo = VkBufferCreateInfo
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
					usage = (VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_DST_BIT),
					size = num,
					sharingMode = (context.CopyQueueSupported ? VkSharingMode.VK_SHARING_MODE_CONCURRENT : VkSharingMode.VK_SHARING_MODE_EXCLUSIVE)
				};
				int32 num2 = ((!context.CopyQueueSupported) ? 1 : 2);
				uint32* ptr = scope uint32[num2]*;
				*ptr = (uint32)context.QueueIndices.GraphicsFamily;
				if (context.CopyQueueSupported)
				{
					ptr[1] = (uint32)context.QueueIndices.CopyFamily;
				}
				vkBufferCreateInfo.pQueueFamilyIndices = ptr;
				vkBufferCreateInfo.queueFamilyIndexCount = (uint32)num2;
				VkBuffer nativeBuffer = default(VkBuffer);
				VulkanNative.vkCreateBuffer(context.VkDevice, &vkBufferCreateInfo, null, &nativeBuffer);
				NativeBuffer = nativeBuffer;
				VkMemoryRequirements memoryRequirements = default(VkMemoryRequirements);
				VulkanNative.vkGetBufferMemoryRequirements(context.VkDevice, NativeBuffer, &memoryRequirements);
				MemoryRequirements = memoryRequirements;
				VkMemoryAllocateInfo vkMemoryAllocateInfo = VkMemoryAllocateInfo
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
					allocationSize = MemoryRequirements.size
				};
				int32 num3 = VKHelpers.FindMemoryType(context, MemoryRequirements.memoryTypeBits, VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
				if (num3 == -1)
				{
					vkContext.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
				}
				vkMemoryAllocateInfo.memoryTypeIndex = (uint32)num3;
				VkDeviceMemory bufferMemory = default(VkDeviceMemory);
				VulkanNative.vkAllocateMemory(context.VkDevice, &vkMemoryAllocateInfo, null, &bufferMemory);
				BufferMemory = bufferMemory;
				VulkanNative.vkBindBufferMemory(context.VkDevice, NativeBuffer, BufferMemory, 0uL);
				uint32 num4 = description.MipLevels * description.ArraySize * description.Faces * description.Depth;
				ImageLayouts = new VkImageLayout[num4];
				for (int i = 0; i < num4; i++)
				{
					ImageLayouts[i] = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
				}
				return;
			}
			bool flag2 = (description.Flags & TextureFlags.DepthStencil) != 0;
			VkImageUsageFlags vkImageUsageFlags = VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_SRC_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT;
			if (flag2)
			{
				vkImageUsageFlags |= VkImageUsageFlags.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;
			}
			if ((description.Flags & TextureFlags.RenderTarget) != 0)
			{
				vkImageUsageFlags |= VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
			}
			if ((description.Flags & TextureFlags.UnorderedAccess) != 0)
			{
				vkImageUsageFlags |= VkImageUsageFlags.VK_IMAGE_USAGE_STORAGE_BIT;
			}
			if ((description.Flags & TextureFlags.ShaderResource) != 0)
			{
				vkImageUsageFlags |= VkImageUsageFlags.VK_IMAGE_USAGE_SAMPLED_BIT;
			}
			Format = description.Format.ToVulkan(flag2);
			VkImageCreateInfo vkImageCreateInfo = VkImageCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
				mipLevels = description.MipLevels,
				arrayLayers = description.ArraySize * description.Faces,
				extent = .()
				{
					width = description.Width,
					height = description.Height,
					depth = description.Depth
				},
				initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED,
				usage = vkImageUsageFlags,
				tiling = (flag ? VkImageTiling.VK_IMAGE_TILING_LINEAR : VkImageTiling.VK_IMAGE_TILING_OPTIMAL),
				samples = description.SampleCount.ToVulkan(),
				format = Format
			};
			switch (description.Type)
			{
			case TextureType.Texture1D:
			case TextureType.Texture1DArray:
				vkImageCreateInfo.imageType = VkImageType.VK_IMAGE_TYPE_1D;
				break;
			case TextureType.Texture2D:
			case TextureType.Texture2DArray:
				vkImageCreateInfo.imageType = VkImageType.VK_IMAGE_TYPE_2D;
				break;
			case TextureType.TextureCube:
			case TextureType.TextureCubeArray:
				vkImageCreateInfo.imageType = VkImageType.VK_IMAGE_TYPE_2D;
				vkImageCreateInfo.flags |= VkImageCreateFlags.VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT;
				break;
			case TextureType.Texture3D:
				vkImageCreateInfo.imageType = VkImageType.VK_IMAGE_TYPE_3D;
				break;
			default:
				Context.ValidationLayer?.Notify("Vulkan", "Invalid textureType.");
				break;
			}
			VkImage nativeImage = default(VkImage);
			VulkanNative.vkCreateImage(context.VkDevice, &vkImageCreateInfo, null, &nativeImage);
			NativeImage = nativeImage;
			VkMemoryRequirements memoryRequirements2 = default(VkMemoryRequirements);
			VulkanNative.vkGetImageMemoryRequirements(context.VkDevice, NativeImage, &memoryRequirements2);
			MemoryRequirements = memoryRequirements2;
			VkMemoryAllocateInfo vkMemoryAllocateInfo2 = VkMemoryAllocateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
				allocationSize = MemoryRequirements.size
			};
			int32 num5 = VKHelpers.FindMemoryType(context, MemoryRequirements.memoryTypeBits, VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
			if (num5 == -1)
			{
				vkContext.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
			}
			vkMemoryAllocateInfo2.memoryTypeIndex = (uint32)num5;
			VkDeviceMemory imageMemory = default(VkDeviceMemory);
			VulkanNative.vkAllocateMemory(context.VkDevice, &vkMemoryAllocateInfo2, null, &imageMemory);
			ImageMemory = imageMemory;
			VulkanNative.vkBindImageMemory(context.VkDevice, NativeImage, ImageMemory, 0uL);
			uint32 num6 = description.MipLevels * description.ArraySize * description.Faces * description.Depth;
			ImageLayouts = new VkImageLayout[num6];
			for (int j = 0; j < num6; j++)
			{
				ImageLayouts[j] = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
			}
			if (data == null)
			{
				return;
			}
			uint32 num7 = Helpers.ComputeTextureSize(description);
			uint64 num8 = context.TextureUploader.Allocate(num7);
			uint32 num9 = description.ArraySize * description.Faces * description.MipLevels;
			VkBufferImageCopy* ptr2 = scope VkBufferImageCopy[(int32)num9]*;
			uint32 num10 = 0u;
			for (uint32 num11 = 0u; num11 < description.ArraySize; num11++)
			{
				for (uint32 num12 = 0u; num12 < description.Faces; num12++)
				{
					uint32 num13 = description.Width;
					uint32 num14 = description.Height;
					uint32 num15 = description.Depth;
					for (uint32 num16 = 0u; num16 < description.MipLevels; num16++)
					{
						uint32 num17 = num11 * description.Faces * description.MipLevels + num12 * description.MipLevels + num16;
						uint64 num18 = num8 + num10;
						DataBox dataBox = data[num17];
						Internal.MemCpy((void*)(int)num18, (void*)dataBox.DataPointer, dataBox.SlicePitch * description.Depth);
						num10 += dataBox.SlicePitch;
						ptr2[num17] = VkBufferImageCopy
						{
							bufferOffset = context.TextureUploader.CalculateOffset(num18),
							bufferRowLength = 0u,
							bufferImageHeight = 0u,
							imageSubresource = .()
							{
								aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
								mipLevel = num16,
								baseArrayLayer = num11 * description.Faces + num12,
								layerCount = 1u
							},
							imageOffset = default(VkOffset3D),
							imageExtent = VkExtent3D
							{
								width = num13,
								height = num14,
								depth = num15
							}
						};
						num13 = Math.Max(1, num13 / 2);
						num14 = Math.Max(1, num14 / 2);
						num15 = Math.Max(1, num15 / 2);
					}
				}
			}
			VkImageMemoryBarrier vkImageMemoryBarrier = VkImageMemoryBarrier
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
				image = NativeImage,
				oldLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED,
				newLayout = VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
				srcAccessMask = VkAccessFlags.VK_ACCESS_NONE,
				dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT,
				subresourceRange = .()
				{
					aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
					baseArrayLayer = 0u,
					layerCount = description.ArraySize * description.Faces,
					baseMipLevel = 0u,
					levelCount = description.MipLevels
				},
				srcQueueFamilyIndex = uint32.MaxValue,
				dstQueueFamilyIndex = uint32.MaxValue
			};
			VulkanNative.vkCmdPipelineBarrier(context.copyCommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkDependencyFlags.None, 0u, null, 0u, null, 1u, &vkImageMemoryBarrier);
			VulkanNative.vkCmdCopyBufferToImage(context.copyCommandBuffer, context.TextureUploader.NativeBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, num9, ptr2);
			if ((Description.Flags & TextureFlags.ShaderResource) != 0)
			{
				vkImageMemoryBarrier.oldLayout = VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
				vkImageMemoryBarrier.newLayout = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
				vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
				vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT | VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT;
				VulkanNative.vkCmdPipelineBarrier(context.copyCommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.None, 0u, null, 0u, null, 1u, &vkImageMemoryBarrier);
				for (int k = 0; k < num6; k++)
				{
					ImageLayouts[k] = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
				}
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKTexture" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="data">The data pointer.</param>
		/// <param name="description">The texture description.</param>
		public this(VKGraphicsContext context, DataBox[] data, ref TextureDescription description)
			: base(context, ref description)
		{
		}

		/// <summary>
		/// Create a new texture from a VKImage.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The texture description.</param>
		/// <param name="image">The vulkan image already created.</param>
		/// <returns>A new VKTexture.</returns>
		public static VKTexture FromVulkanImage(VKGraphicsContext context, ref TextureDescription description, VkImage image)
		{
			VKTexture vKTexture = new VKTexture(context, null, ref description);
			vKTexture.vkContext = context;
			vKTexture.NativeImage = image;
			vKTexture.ImageLayouts = new VkImageLayout[description.ArraySize]..Fill(VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED);
			if (description.Usage != ResourceUsage.Staging)
			{
				bool depthFormat = (description.Flags & TextureFlags.DepthStencil) != 0;
				vKTexture.Format = description.Format.ToVulkan(depthFormat);
			}
			return vKTexture;
		}

		/// <summary>
		/// Transition the images linked with this texture to a VKImageLayout state.
		/// </summary>
		/// <param name="command">The command buffer to execute.</param>
		/// <param name="newLayout">The new state layout.</param>
		/// <param name="baseMiplevel">The start mip level.</param>
		/// <param name="levelCount">The number of mip levels.</param>
		/// <param name="baseArrayLayer">The start array layer.</param>
		/// <param name="layerCount">The number of array layers.</param>
		public  void TransitionImageLayout(VkCommandBuffer command, VkImageLayout newLayout, uint32 baseMiplevel, uint32 levelCount, uint32 baseArrayLayer, uint32 layerCount)
		{
			uint32 num = Helpers.CalculateSubResource(Description, baseMiplevel, baseArrayLayer);
			VkImageLayout vkImageLayout = ImageLayouts[num];
			if (vkImageLayout == newLayout)
			{
				return;
			}
			VkImageAspectFlags vkImageAspectFlags = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
			if ((Description.Flags & TextureFlags.DepthStencil) != 0)
			{
				vkImageAspectFlags = VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
				if (Helpers.IsStencilFormat(Description.Format))
				{
					vkImageAspectFlags |= VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT;
				}
			}
			VkImageMemoryBarrier vkImageMemoryBarrier = default(VkImageMemoryBarrier);
			vkImageMemoryBarrier.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
			vkImageMemoryBarrier.oldLayout = vkImageLayout;
			vkImageMemoryBarrier.newLayout = newLayout;
			vkImageMemoryBarrier.srcQueueFamilyIndex = uint32.MaxValue;
			vkImageMemoryBarrier.dstQueueFamilyIndex = uint32.MaxValue;
			vkImageMemoryBarrier.image = NativeImage;
			vkImageMemoryBarrier.subresourceRange.aspectMask = vkImageAspectFlags;
			vkImageMemoryBarrier.subresourceRange.baseMipLevel = baseMiplevel;
			vkImageMemoryBarrier.subresourceRange.levelCount = levelCount;
			vkImageMemoryBarrier.subresourceRange.baseArrayLayer = baseArrayLayer;
			vkImageMemoryBarrier.subresourceRange.layerCount = layerCount;
			VkPipelineStageFlags srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;
			VkPipelineStageFlags dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;
			switch (vkImageLayout)
			{
			case VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED:
			case VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED:
				vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
				vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
				vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
				vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_GENERAL:
			case VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
				vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
				vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR:
				vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT;
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL:
				break;
			default:
				Runtime.FatalError("Source Image layout not supported.");
			}
			switch (newLayout)
			{
			case VkImageLayout.VK_IMAGE_LAYOUT_GENERAL:
				vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
				vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
				vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
				vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
				vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
				vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR:
				vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT;
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL:
				break;
			default:
				Runtime.FatalError("Destination Image layout not supported.");
			}
			VulkanNative.vkCmdPipelineBarrier(command, srcStageMask, dstStageMask, VkDependencyFlags.None, 0, null, 0u, null, 1u, &vkImageMemoryBarrier);
			uint32 num2 = baseArrayLayer + layerCount;
			uint32 num3 = baseMiplevel + levelCount;
			for (uint32 num4 = baseArrayLayer; num4 < num2; num4++)
			{
				for (uint32 num5 = baseMiplevel; num5 < num3; num5++)
				{
					ImageLayouts[Helpers.CalculateSubResource(Description, num5, num4)] = newLayout;
				}
			}
		}

		/// <summary>
		/// Copy a pixel region from source to destination texture.
		/// </summary>
		/// <param name="commandBuffer">The commandbuffer where execute.</param>
		/// <param name="sourceX">U coord source texture.</param>
		/// <param name="sourceY">V coord source texture.</param>
		/// <param name="sourceZ">W coord source texture.</param>
		/// <param name="sourceMipLevel">Source mip level.</param>
		/// <param name="sourceBaseArray">Source array index.</param>
		/// <param name="destination">Destination texture.</param>
		/// <param name="destinationX">U coord destination texture.</param>
		/// <param name="destinationY">V coord destination texture.</param>
		/// <param name="destinationZ">W coord destination texture.</param>
		/// <param name="destinationMipLevel">Destination mip level.</param>
		/// <param name="destinationBasedArray">Destination array index.</param>
		/// <param name="width">Destination width.</param>
		/// <param name="height">Destination heigh.</param>
		/// <param name="depth">Destination depth.</param>
		/// <param name="layerCount">Destination layer count.</param>
		public  void CopyTo(VkCommandBuffer commandBuffer, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBaseArray, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArray, uint32 width, uint32 height, uint32 depth, uint32 layerCount)
		{
			bool flag = Description.Usage == ResourceUsage.Staging;
			bool flag2 = destination.Description.Usage == ResourceUsage.Staging;
			VKTexture vKTexture = destination as VKTexture;
			VkImageSubresourceLayers vkImageSubresourceLayers;
			VkOffset3D vkOffset3D;
			VkExtent3D vkExtent3D;
			if (!flag && !flag2)
			{
				TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, sourceMipLevel, 1, sourceBaseArray, layerCount);
				vkImageSubresourceLayers = default(VkImageSubresourceLayers);
				vkImageSubresourceLayers.aspectMask = (((Description.Flags & TextureFlags.DepthStencil) == 0) ? VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
				vkImageSubresourceLayers.layerCount = layerCount;
				vkImageSubresourceLayers.mipLevel = sourceMipLevel;
				vkImageSubresourceLayers.baseArrayLayer = sourceBaseArray;
				VkImageSubresourceLayers srcSubresource = vkImageSubresourceLayers;
				vKTexture.TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, destinationMipLevel, 1u, destinationBasedArray, layerCount);
				vkImageSubresourceLayers = default(VkImageSubresourceLayers);
				vkImageSubresourceLayers.aspectMask = (((destination.Description.Flags & TextureFlags.DepthStencil) == 0) ? VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
				vkImageSubresourceLayers.layerCount = layerCount;
				vkImageSubresourceLayers.mipLevel = destinationMipLevel;
				vkImageSubresourceLayers.baseArrayLayer = destinationBasedArray;
				VkImageSubresourceLayers dstSubresource = vkImageSubresourceLayers;
				VkImageCopy vkImageCopy = default(VkImageCopy);
				vkOffset3D = (vkImageCopy.srcOffset = VkOffset3D
				{
					x = (int32)sourceX,
					y = (int32)sourceY,
					z = (int32)sourceZ
				});
				vkOffset3D = (vkImageCopy.dstOffset = VkOffset3D
				{
					x = (int32)destinationX,
					y = (int32)destinationY,
					z = (int32)destinationZ
				});
				vkImageCopy.srcSubresource = srcSubresource;
				vkImageCopy.dstSubresource = dstSubresource;
				vkExtent3D = (vkImageCopy.extent = VkExtent3D
				{
					width = Description.Width,
					height = Description.Height,
					depth = Description.Depth
				});
				VkImageCopy vkImageCopy2 = vkImageCopy;
				VulkanNative.vkCmdCopyImage(commandBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vKTexture.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1u, &vkImageCopy2);
				return;
			}
			VkBufferImageCopy vkBufferImageCopy;
			if (flag && !flag2)
			{
				vKTexture.TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, destinationMipLevel, 1u, destinationBasedArray, layerCount);
				vkImageSubresourceLayers = default(VkImageSubresourceLayers);
				vkImageSubresourceLayers.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
				vkImageSubresourceLayers.layerCount = layerCount;
				vkImageSubresourceLayers.mipLevel = destinationMipLevel;
				vkImageSubresourceLayers.baseArrayLayer = destinationBasedArray;
				VkImageSubresourceLayers imageSubresource = vkImageSubresourceLayers;
				uint32 subResource = Helpers.CalculateSubResource(Description, sourceMipLevel, sourceBaseArray);
				Helpers.GetMipDimensions(Description, sourceMipLevel, var width2, var height2, ?);
				uint32 num = ((!Helpers.IsCompressedFormat(Description.Format)) ? 1u : 4u);
				uint32 num2 = Math.Max(width2, num);
				uint32 num3 = Math.Max(height2, num);
				uint32 num4 = sourceX / num;
				uint32 num5 = sourceY / num;
				uint32 num6 = ((num == 1) ? Helpers.GetSizeInBytes(Description.Format) : Helpers.GetBlockSizeInBytes(Description.Format));
				uint32 rowPitch = Helpers.GetRowPitch(num2, Description.Format);
				uint32 slicePitch = Helpers.GetSlicePitch(rowPitch, num3, Description.Format);
				uint64 bufferOffset = Helpers.ComputeSubResourceOffset(vKTexture.Description, subResource) + sourceZ * slicePitch + num5 * rowPitch + num4 * num6;
				vkBufferImageCopy = default(VkBufferImageCopy);
				vkBufferImageCopy.imageSubresource = imageSubresource;
				vkExtent3D = (vkBufferImageCopy.imageExtent = VkExtent3D
				{
					width = width,
					height = height,
					depth = depth
				});
				vkOffset3D = (vkBufferImageCopy.imageOffset = VkOffset3D
				{
					x = (int32)destinationX,
					y = (int32)destinationY,
					z = (int32)destinationZ
				});
				vkBufferImageCopy.bufferRowLength = num2;
				vkBufferImageCopy.bufferImageHeight = num3;
				vkBufferImageCopy.bufferOffset = bufferOffset;
				VkBufferImageCopy vkBufferImageCopy2 = vkBufferImageCopy;
				VulkanNative.vkCmdCopyBufferToImage(commandBuffer, NativeBuffer, vKTexture.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1u, &vkBufferImageCopy2);
				return;
			}
			if (!flag && flag2)
			{
				TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, sourceMipLevel, 1u, sourceBaseArray, layerCount);
				vkImageSubresourceLayers = default(VkImageSubresourceLayers);
				vkImageSubresourceLayers.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
				vkImageSubresourceLayers.layerCount = layerCount;
				vkImageSubresourceLayers.mipLevel = sourceMipLevel;
				vkImageSubresourceLayers.baseArrayLayer = sourceBaseArray;
				VkImageSubresourceLayers imageSubresource2 = vkImageSubresourceLayers;
				uint32 subResource2 = Helpers.CalculateSubResource(vKTexture.Description, destinationMipLevel, destinationBasedArray);
				Helpers.GetMipDimensions(vKTexture.Description, destinationMipLevel, var width3, var height3, ?);
				uint32 num7 = ((!Helpers.IsCompressedFormat(vKTexture.Description.Format)) ? 1u : 4u);
				uint32 num8 = Math.Max(width3, num7);
				uint32 num9 = Math.Max(height3, num7);
				uint32 num10 = sourceX / num7;
				uint32 num11 = sourceY / num7;
				uint32 num12 = ((num7 == 1) ? Helpers.GetSizeInBytes(vKTexture.Description.Format) : Helpers.GetBlockSizeInBytes(vKTexture.Description.Format));
				uint32 rowPitch2 = Helpers.GetRowPitch(num8, vKTexture.Description.Format);
				uint32 slicePitch2 = Helpers.GetSlicePitch(rowPitch2, num9, vKTexture.Description.Format);
				uint64 bufferOffset2 = Helpers.ComputeSubResourceOffset(vKTexture.Description, subResource2) + sourceZ * slicePitch2 + num11 * rowPitch2 + num10 * num12;
				vkBufferImageCopy = default(VkBufferImageCopy);
				vkBufferImageCopy.imageSubresource = imageSubresource2;
				vkExtent3D = (vkBufferImageCopy.imageExtent = VkExtent3D
				{
					width = width,
					height = height,
					depth = depth
				});
				vkOffset3D = (vkBufferImageCopy.imageOffset = VkOffset3D
				{
					x = (int32)sourceX,
					y = (int32)sourceY,
					z = (int32)sourceZ
				});
				vkBufferImageCopy.bufferRowLength = num8;
				vkBufferImageCopy.bufferImageHeight = num9;
				vkBufferImageCopy.bufferOffset = bufferOffset2;
				VkBufferImageCopy vkBufferImageCopy3 = vkBufferImageCopy;
				VulkanNative.vkCmdCopyImageToBuffer(commandBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vKTexture.NativeBuffer, 1u, &vkBufferImageCopy3);
				return;
			}
			uint32 subResource3 = Helpers.CalculateSubResource(Description, sourceMipLevel, sourceBaseArray);
			SubResourceInfo subResourceInfo = Helpers.GetSubResourceInfo(Description, subResource3);
			uint32 subResource4 = Helpers.CalculateSubResource(destination.Description, destinationMipLevel, destinationBasedArray);
			SubResourceInfo subResourceInfo2 = Helpers.GetSubResourceInfo(destination.Description, subResource4);
			uint32 num13 = Math.Max(depth, layerCount);
			VkBufferCopy vkBufferCopy;
			if (!Helpers.IsCompressedFormat(Description.Format))
			{
				uint32 sizeInBytes = Helpers.GetSizeInBytes(Description.Format);
				for (uint32 num14 = 0u; num14 < num13; num14++)
				{
					for (uint32 num15 = 0u; num15 < height; num15++)
					{
						vkBufferCopy = default(VkBufferCopy);
						vkBufferCopy.srcOffset = subResourceInfo.Offset + subResourceInfo.SlicePitch * (num14 + sourceZ) + subResourceInfo.RowPitch * (num15 + sourceY) + sizeInBytes * sourceX;
						vkBufferCopy.dstOffset = subResourceInfo2.Offset + subResourceInfo2.SlicePitch * (num14 + destinationX) + subResourceInfo2.RowPitch * (num15 + destinationY) + sizeInBytes * destinationZ;
						vkBufferCopy.size = width * sizeInBytes;
						VkBufferCopy vkBufferCopy2 = vkBufferCopy;
						VulkanNative.vkCmdCopyBuffer(commandBuffer, NativeBuffer, vKTexture.NativeBuffer, 1u, &vkBufferCopy2);
					}
				}
				return;
			}
			uint32 rowPitch3 = Helpers.GetRowPitch(width, Description.Format);
			uint32 numRows = Helpers.GetNumRows(height, Description.Format);
			uint32 num16 = sourceX / 4u;
			uint32 num17 = sourceY / 4u;
			uint32 num18 = destinationX / 4u;
			uint32 num19 = destinationY / 4u;
			uint32 blockSizeInBytes = Helpers.GetBlockSizeInBytes(Description.Format);
			for (uint32 num20 = 0u; num20 < num13; num20++)
			{
				for (uint32 num21 = 0u; num21 < numRows; num21++)
				{
					vkBufferCopy = default(VkBufferCopy);
					vkBufferCopy.srcOffset = subResourceInfo.Offset + subResourceInfo.SlicePitch * (num20 + sourceZ) + subResourceInfo.RowPitch * (num21 + num17) + blockSizeInBytes * num16;
					vkBufferCopy.dstOffset = subResourceInfo2.Offset + subResourceInfo2.SlicePitch * (num20 + destinationZ) + subResourceInfo2.RowPitch * (num21 + num19) + blockSizeInBytes * num18;
					vkBufferCopy.size = rowPitch3;
					VkBufferCopy vkBufferCopy3 = vkBufferCopy;
					VulkanNative.vkCmdCopyBuffer(commandBuffer, NativeBuffer, vKTexture.NativeBuffer, 1u, &vkBufferCopy3);
				}
			}
		}

		/// <summary>
		/// Copy a pixel region from source to destination texture with format conversion and preparing to present in swapchain.
		/// </summary>
		/// <param name="commandBuffer">The commandbuffer where execute.</param>
		/// <param name="sourceX">U coord source texture.</param>
		/// <param name="sourceY">V coord source texture.</param>
		/// <param name="sourceZ">W coord source texture.</param>
		/// <param name="sourceMipLevel">Source mip level.</param>
		/// <param name="sourceBaseArray">Source array index.</param>
		/// <param name="destination">Destination texture.</param>
		/// <param name="destinationX">U coord destination texture.</param>
		/// <param name="destinationY">V coord destination texture.</param>
		/// <param name="destinationZ">W coord destination texture.</param>
		/// <param name="destinationMipLevel">Destination mip level.</param>
		/// <param name="destinationBasedArray">Destination array index.</param>
		/// <param name="layerCount">Destination layer count.</param>
		public  void Blit(VkCommandBuffer commandBuffer, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBaseArray, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArray, uint32 layerCount)
		{
			VKTexture vKTexture = destination as VKTexture;
			TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, sourceMipLevel, 1u, sourceBaseArray, layerCount);
			VkImageSubresourceLayers vkImageSubresourceLayers = default(VkImageSubresourceLayers);
			vkImageSubresourceLayers.aspectMask = (((Description.Flags & TextureFlags.DepthStencil) == 0) ? VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
			vkImageSubresourceLayers.layerCount = layerCount;
			vkImageSubresourceLayers.mipLevel = sourceMipLevel;
			vkImageSubresourceLayers.baseArrayLayer = sourceBaseArray;
			VkImageSubresourceLayers srcSubresource = vkImageSubresourceLayers;
			vKTexture.TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, destinationMipLevel, 1u, destinationBasedArray, layerCount);
			vkImageSubresourceLayers = default(VkImageSubresourceLayers);
			vkImageSubresourceLayers.aspectMask = (((destination.Description.Flags & TextureFlags.DepthStencil) == 0) ? VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
			vkImageSubresourceLayers.layerCount = layerCount;
			vkImageSubresourceLayers.mipLevel = destinationMipLevel;
			vkImageSubresourceLayers.baseArrayLayer = destinationBasedArray;
			VkImageSubresourceLayers dstSubresource = vkImageSubresourceLayers;
			VkImageBlit vkImageBlit = default(VkImageBlit);
			VkOffset3D vkOffset3D = (vkImageBlit.srcOffsets[0] = VkOffset3D
			{
				x = (int32)sourceX,
				y = (int32)sourceY,
				z = (int32)sourceZ
			});
			vkOffset3D = (vkImageBlit.srcOffsets[1] = VkOffset3D
			{
				x = (int32)Description.Width,
				y = (int32)Description.Height,
				z = (int32)Description.Depth
			});
			vkOffset3D = (vkImageBlit.dstOffsets[0] = VkOffset3D
			{
				x = (int32)destinationX,
				y = (int32)destinationY,
				z = (int32)destinationZ
			});
			vkOffset3D = (vkImageBlit.dstOffsets[1] = VkOffset3D
			{
				x = (int32)Description.Width,
				y = (int32)Description.Height,
				z = (int32)Description.Depth
			});
			vkImageBlit.srcSubresource = srcSubresource;
			vkImageBlit.dstSubresource = dstSubresource;
			VkImageBlit vkImageBlit2 = vkImageBlit;
			VulkanNative.vkCmdBlitImage(commandBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vKTexture.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1u, &vkImageBlit2, VkFilter.VK_FILTER_LINEAR);
			vKTexture.TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, destinationMipLevel, 1u, destinationBasedArray, layerCount);
		}

		/// <summary>
		/// The a new image layout.
		/// </summary>
		/// <param name="mipLevel">The mipLevel of this texture.</param>
		/// <param name="arrayLevel">The arraylelvel of this texture.</param>
		/// <param name="layout">The new layout to set.</param>
		public void SetImageLayout(uint32 mipLevel, uint32 arrayLevel, VkImageLayout layout)
		{
			uint32 num = Helpers.CalculateSubResource(Description, mipLevel, arrayLevel);
			ImageLayouts[num] = layout;
		}

		/// <summary>
		/// The a new image layout based on subResource.
		/// </summary>
		/// <param name="subResource">The subResource index.</param>
		/// <param name="layout">The new layout state.</param>
		public void SetImageLayout(uint32 subResource, VkImageLayout layout)
		{
			ImageLayouts[subResource] = layout;
		}

		/// <summary>
		/// Fill the buffer from a pointer.
		/// </summary>
		/// <param name="commandBuffer">The commandbuffer.</param>
		/// <param name="source">The data pointer.</param>
		/// <param name="sourceSizeInBytes">The size in bytes.</param>
		/// <param name="subResource">The subresource index.</param>
		public  void SetData(VkCommandBuffer commandBuffer, void* source, uint32 sourceSizeInBytes, uint32 subResource = 0u)
		{
			VKGraphicsContext vKGraphicsContext = Context as VKGraphicsContext;
			bool num = Description.Usage == ResourceUsage.Staging;
			SubResourceInfo subResourceInfo = Helpers.GetSubResourceInfo(Description, subResource);
			if (sourceSizeInBytes > subResourceInfo.SizeInBytes)
			{
				Context.ValidationLayer?.Notify("Vulkan", scope $"The sourceSizeInBytes: {sourceSizeInBytes} is bigger than the subResource size: {subResourceInfo.SizeInBytes}");
			}
			if (num)
			{
				void* destination = default(void*);
				VulkanNative.vkMapMemory(vKGraphicsContext.VkDevice, BufferMemory, subResourceInfo.Offset, subResourceInfo.SizeInBytes, 0, &destination);
				Internal.MemCpy(destination, (void*)source, sourceSizeInBytes);
				VulkanNative.vkUnmapMemory(vKGraphicsContext.VkDevice, BufferMemory);
				return;
			}
			uint64 num2 = vKGraphicsContext.TextureUploader.Allocate(sourceSizeInBytes);
			uint32 num3 = 1u;
			VkBufferImageCopy* ptr = scope VkBufferImageCopy[(int32)num3]*;
			Internal.MemCpy((void*)(int)num2, (void*)source, sourceSizeInBytes);
			VkBufferImageCopy vkBufferImageCopy = default(VkBufferImageCopy);
			vkBufferImageCopy.bufferOffset = vKGraphicsContext.TextureUploader.CalculateOffset(num2);
			vkBufferImageCopy.bufferRowLength = 0u;
			vkBufferImageCopy.bufferImageHeight = 0u;
			vkBufferImageCopy.imageSubresource.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
			vkBufferImageCopy.imageSubresource.mipLevel = subResourceInfo.MipLevel;
			vkBufferImageCopy.imageSubresource.baseArrayLayer = subResourceInfo.ArrayLayer;
			vkBufferImageCopy.imageSubresource.layerCount = 1u;
			vkBufferImageCopy.imageOffset = default(VkOffset3D);
			vkBufferImageCopy.imageExtent = VkExtent3D
			{
				width = subResourceInfo.MipWidth,
				height = subResourceInfo.MipHeight,
				depth = subResourceInfo.MipDepth
			};
			*ptr = vkBufferImageCopy;
			TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, subResourceInfo.MipLevel, 1u, subResourceInfo.ArrayLayer, Description.ArraySize * Description.Faces);
			VulkanNative.vkCmdCopyBufferToImage(vKGraphicsContext.copyCommandBuffer, vKGraphicsContext.TextureUploader.NativeBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, num3, ptr);
			if ((Description.Flags & TextureFlags.ShaderResource) != 0)
			{
				TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, subResourceInfo.MipLevel, 1u, subResourceInfo.ArrayLayer, Description.ArraySize * Description.Faces);
			}
		}

		/// <summary>
		/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
		/// </summary>
		public override void Dispose()
		{
			/*Dispose(disposing: true);
			GC.SuppressFinalize(this);*/
		}

		private  VkImageView GetImageView()
		{
			VkImageViewCreateInfo vkImageViewCreateInfo = default(VkImageViewCreateInfo);
			vkImageViewCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
			vkImageViewCreateInfo.image = NativeImage;
			vkImageViewCreateInfo.format = Format;
			VkImageAspectFlags aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
			if ((Description.Flags & TextureFlags.DepthStencil) != 0)
			{
				aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
			}
			vkImageViewCreateInfo.subresourceRange = VkImageSubresourceRange
			{
				aspectMask = aspectMask,
				baseMipLevel = 0u,
				levelCount = Description.MipLevels,
				baseArrayLayer = 0u,
				layerCount = Description.ArraySize * Description.Faces
			};
			switch (Description.Type)
			{
			case TextureType.Texture1D:
				vkImageViewCreateInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_1D;
				break;
			case TextureType.Texture1DArray:
				vkImageViewCreateInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_1D_ARRAY;
				break;
			case TextureType.Texture2D:
				vkImageViewCreateInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
				break;
			case TextureType.Texture2DArray:
				vkImageViewCreateInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D_ARRAY;
				break;
			case TextureType.TextureCube:
				vkImageViewCreateInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_CUBE;
				break;
			case TextureType.TextureCubeArray:
				vkImageViewCreateInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_CUBE_ARRAY;
				break;
			case TextureType.Texture3D:
				vkImageViewCreateInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_3D;
				break;
			}
			VkImageView result = default(VkImageView);
			VulkanNative.vkCreateImageView((Context as VKGraphicsContext).VkDevice, &vkImageViewCreateInfo, null, &result);
			return result;
		}

		private  void Dispose(bool disposing)
		{
			base.Dispose();
			if (disposed)
			{
				return;
			}
			if (disposing)
			{
				if (Description.Usage == ResourceUsage.Staging)
				{
					VulkanNative.vkDestroyBuffer(vkContext.VkDevice, NativeBuffer, null);
					VulkanNative.vkFreeMemory(vkContext.VkDevice, BufferMemory, null);
				}
				else
				{
					VulkanNative.vkDestroyImage(vkContext.VkDevice, NativeImage, null);
					VulkanNative.vkFreeMemory(vkContext.VkDevice, ImageMemory, null);
				}
			}
			disposed = true;
		}
	}
}

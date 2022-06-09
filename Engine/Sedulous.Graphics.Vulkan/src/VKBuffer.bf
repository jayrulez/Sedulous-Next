using System;
using Bulkan;
using Sedulous.Graphics;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics.Vulkan;

	/// <summary>
	/// Represents a Vulkan buffer Object.
	/// </summary>
	public class VKBuffer : Sedulous.Graphics.Buffer
	{
		/// <summary>
		/// The Vulkan buffer Object.
		/// </summary>
		public VkBuffer NativeBuffer;

		/// <summary>
		/// The Vulkan buffer memory.
		/// </summary>
		public VkDeviceMemory BufferMemory;

		internal VkDeviceOrHostAddressConstKHR BufferAddress;

		private VKGraphicsContext vkContext;

		private VkBufferUsageFlags vkUsage;

		private String name;

		/// <inheritdoc />
		public override void* NativePointer => (void*)(int)NativeBuffer.Handle;

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
					vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_BUFFER, NativeBuffer.Handle, name);
				}
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKBuffer" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="data">The data pointer.</param>
		/// <param name="description">A buffer description.</param>
		public  this(VKGraphicsContext context, void* data, ref BufferDescription description)
			: base(context, ref description)
		{
			vkContext = context;
			vkUsage = VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_DST_BIT;
			if ((description.Flags & BufferFlags.VertexBuffer) != 0)
			{
				vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT;
			}
			if ((description.Flags & BufferFlags.IndexBuffer) != 0)
			{
				vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_INDEX_BUFFER_BIT;
			}
			if ((description.Flags & BufferFlags.ConstantBuffer) != 0)
			{
				vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
			}
			if ((description.Flags & BufferFlags.ShaderResource) != 0)
			{
				vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT;
			}
			if ((description.Flags & BufferFlags.UnorderedAccess) != 0)
			{
				vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT;
			}
			if ((description.Flags & BufferFlags.IndirectBuffer) != 0)
			{
				vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT;
			}
			if ((bool)vkContext.features_1_2.bufferDeviceAddress)
			{
				vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT;
			}
			if ((description.Flags & BufferFlags.AccelerationStructure) != 0)
			{
				vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR;
			}
			VkBufferCreateInfo vkBufferCreateInfo = VkBufferCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
				size = description.SizeInBytes,
				usage = vkUsage,
				sharingMode = (context.CopyQueueSupported ? VkSharingMode.VK_SHARING_MODE_CONCURRENT : VkSharingMode.VK_SHARING_MODE_EXCLUSIVE)
			};
			int32 num = ((!context.CopyQueueSupported) ? 1 : 2);
			uint32* ptr = scope uint32[num]*;
			*ptr = (uint32)context.QueueIndices.GraphicsFamily;
			if (context.CopyQueueSupported)
			{
				ptr[1] = (uint32)context.QueueIndices.CopyFamily;
			}
			vkBufferCreateInfo.pQueueFamilyIndices = ptr;
			vkBufferCreateInfo.queueFamilyIndexCount = (uint32)num;
			VkBuffer vkBuffer = default(VkBuffer);
			VulkanNative.vkCreateBuffer(context.VkDevice, &vkBufferCreateInfo, null, &vkBuffer);
			NativeBuffer = vkBuffer;
			VkMemoryRequirements vkMemoryRequirements = default(VkMemoryRequirements);
			VulkanNative.vkGetBufferMemoryRequirements(context.VkDevice, NativeBuffer, &vkMemoryRequirements);
			VkMemoryPropertyFlags properties = (((description.Usage & ResourceUsage.Dynamic) != ResourceUsage.Dynamic && (description.Usage & ResourceUsage.Staging) != ResourceUsage.Staging) ? VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT : (VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT));
			VkMemoryAllocateInfo vkMemoryAllocateInfo = VkMemoryAllocateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
				allocationSize = vkMemoryRequirements.size
			};
			if ((bool)vkContext.features_1_2.bufferDeviceAddress)
			{
				VkMemoryAllocateFlagsInfo vkMemoryAllocateFlagsInfo = VkMemoryAllocateFlagsInfo
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO,
					flags = VkMemoryAllocateFlags.VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT
				};
				vkMemoryAllocateInfo.pNext = &vkMemoryAllocateFlagsInfo;
			}
			int32 num2 = VKHelpers.FindMemoryType(context, vkMemoryRequirements.memoryTypeBits, properties);
			if (num2 == -1)
			{
				vkContext.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
			}
			vkMemoryAllocateInfo.memoryTypeIndex = (uint32)num2;
			VkDeviceMemory bufferMemory = default(VkDeviceMemory);
			VulkanNative.vkAllocateMemory(context.VkDevice, &vkMemoryAllocateInfo, null, &bufferMemory);
			BufferMemory = bufferMemory;
			VulkanNative.vkBindBufferMemory(context.VkDevice, NativeBuffer, BufferMemory, 0uL);
			if (vkBufferCreateInfo.usage.HasFlag(VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT))
			{
				VkBufferDeviceAddressInfo vkBufferDeviceAddressInfo = VkBufferDeviceAddressInfo
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
					buffer = vkBuffer
				};
				uint64 deviceAddress = VulkanNative.vkGetBufferDeviceAddress(context.VkDevice, &vkBufferDeviceAddressInfo);
				BufferAddress = VkDeviceOrHostAddressConstKHR
				{
					deviceAddress = deviceAddress
				};
			}
			if (data != null)
			{
				SetData(context.copyCommandBuffer, data, description.SizeInBytes);
			}
		}

		/// <summary>
		/// Fill the buffer from a pointer.
		/// </summary>
		/// <param name="commandBuffer">The commandbuffer.</param>
		/// <param name="source">The data pointer.</param>
		/// <param name="sourceSizeInBytes">The size in bytes.</param>
		/// <param name="destinationOffsetInBytes">The offset in bytes.</param>
		public  void SetData(VkCommandBuffer commandBuffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0u)
		{
			if (sourceSizeInBytes == 0 || Description.SizeInBytes < sourceSizeInBytes)
			{
				Context.ValidationLayer?.Notify("Vulkan", "invalid source size in bytes.");
			}
			if ((Description.Usage & ResourceUsage.Dynamic) == ResourceUsage.Dynamic || (Description.Usage & ResourceUsage.Staging) == ResourceUsage.Staging)
			{
				void* destination = null;
				VulkanNative.vkMapMemory(vkContext.VkDevice, BufferMemory, destinationOffsetInBytes, sourceSizeInBytes, 0, &destination);
				Internal.MemCpy(destination, (void*)source, sourceSizeInBytes);
				VulkanNative.vkUnmapMemory(vkContext.VkDevice, BufferMemory);
				return;
			}
			uint64 num = vkContext.BufferUploader.Allocate(sourceSizeInBytes);
			Internal.MemCpy((void*)(int)num, (void*)source, sourceSizeInBytes);
			VkBufferCopy vkBufferCopy = default(VkBufferCopy);
			vkBufferCopy.size = sourceSizeInBytes;
			vkBufferCopy.srcOffset = vkContext.BufferUploader.CalculateOffset(num);
			vkBufferCopy.dstOffset = destinationOffsetInBytes;
			VkBufferMemoryBarrier vkBufferMemoryBarrier = default(VkBufferMemoryBarrier);
			vkBufferMemoryBarrier.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
			vkBufferMemoryBarrier.buffer = NativeBuffer;
			vkBufferMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
			vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
			vkBufferMemoryBarrier.srcQueueFamilyIndex = uint32.MaxValue;
			vkBufferMemoryBarrier.dstQueueFamilyIndex = uint32.MaxValue;
			vkBufferMemoryBarrier.size = uint64.MaxValue;
			VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkDependencyFlags.None, 0u, null, 1u, &vkBufferMemoryBarrier, 0u, null);
			VulkanNative.vkCmdCopyBuffer(commandBuffer, vkContext.BufferUploader.NativeBuffer, NativeBuffer, 1u, &vkBufferCopy);
			vkBufferMemoryBarrier.srcAccessMask = vkBufferMemoryBarrier.dstAccessMask;
			if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT) != 0)
			{
				vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_UNIFORM_READ_BIT;
			}
			else if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) != 0)
			{
				vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_INDEX_READ_BIT;
			}
			else if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_INDEX_BUFFER_BIT) != 0)
			{
				vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_INDEX_READ_BIT;
			}
			else
			{
				vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
			}
			VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.None, 0u, null, 1u, &vkBufferMemoryBarrier, 0u, null);
		}

		/// <summary>
		/// Copy this buffer in the destination buffer.
		/// </summary>
		/// <param name="commandBuffer">The commandbuffer.</param>
		/// <param name="queueType">The commandqueue type of the commandBuffer.</param>
		/// <param name="destination">The destination buffer.</param>
		/// <param name="sizeInBytes">The data size in bytes to copy.</param>
		/// <param name="sourceOffset">The source buffer offset in bytes.</param>
		/// <param name="destinationOffset">The destination buffer offset in bytes.</param>
		public  void CopyTo(VkCommandBuffer commandBuffer, CommandQueueType queueType, Sedulous.Graphics.Buffer destination, uint32 sizeInBytes, uint32 sourceOffset, uint32 destinationOffset)
		{
			VKBuffer vKBuffer = destination as VKBuffer;
			VkBufferCopy vkBufferCopy = default(VkBufferCopy);
			vkBufferCopy.srcOffset = sourceOffset;
			vkBufferCopy.dstOffset = destinationOffset;
			vkBufferCopy.size = sizeInBytes;
			VkBufferCopy vkBufferCopy2 = vkBufferCopy;
			VkPipelineStageFlags vkPipelineStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;
			VkBufferMemoryBarrier vkBufferMemoryBarrier = default(VkBufferMemoryBarrier);
			vkBufferMemoryBarrier.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
			vkBufferMemoryBarrier.buffer = NativeBuffer;
			vkBufferMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
			if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT) != 0)
			{
				vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_UNIFORM_READ_BIT;
				if ((queueType & CommandQueueType.Graphics) != 0)
				{
					vkPipelineStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT;
				}
				vkPipelineStageFlags |= VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
			}
			else if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) != 0)
			{
				vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_INDEX_READ_BIT;
				vkPipelineStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT;
			}
			else if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_INDEX_BUFFER_BIT) != 0)
			{
				vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_INDEX_READ_BIT;
				vkPipelineStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT;
			}
			else
			{
				vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
				if ((queueType & CommandQueueType.Graphics) != 0)
				{
					vkPipelineStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT;
				}
				vkPipelineStageFlags |= VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
			}
			vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
			vkBufferMemoryBarrier.srcQueueFamilyIndex = uint32.MaxValue;
			vkBufferMemoryBarrier.dstQueueFamilyIndex = uint32.MaxValue;
			vkBufferMemoryBarrier.size = uint64.MaxValue;
			VulkanNative.vkCmdPipelineBarrier(commandBuffer, vkPipelineStageFlags, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT, 0u, null, 1u, &vkBufferMemoryBarrier, 0u, null);
			VulkanNative.vkCmdCopyBuffer(commandBuffer, NativeBuffer, vKBuffer.NativeBuffer, 1u, &vkBufferCopy2);
			VkAccessFlags srcAccessMask = vkBufferMemoryBarrier.srcAccessMask;
			vkBufferMemoryBarrier.srcAccessMask = vkBufferMemoryBarrier.dstAccessMask;
			vkBufferMemoryBarrier.dstAccessMask = srcAccessMask;
			VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, vkPipelineStageFlags, VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT, 0u, null, 1u, &vkBufferMemoryBarrier, 0u, null);
		}

		public ~this(){
			OnDestroy();
			
			VKGraphicsContext obj = Context as VKGraphicsContext;
			VulkanNative.vkDestroyBuffer(obj.VkDevice, NativeBuffer, null);
			VulkanNative.vkFreeMemory(obj.VkDevice, BufferMemory, null);
		}
	}
}

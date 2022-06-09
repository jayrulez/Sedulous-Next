using System;
using Bulkan;

namespace Sedulous.Graphics.Vulkan
{
	/// <summary>
	/// Raytracing helpers.
	/// </summary>
	public static class VKRaytracingHelpers
	{
		/// <summary>
		/// Buffer data.
		/// </summary>
		public struct BufferData
		{
			/// <summary>
			/// Buffer vulkan resource.
			/// </summary>
			public VkBuffer Buffer;

			/// <summary>
			/// Device memory resource.
			/// </summary>
			public VkDeviceMemory Memory;
		}

		/// <summary>
		/// Create Acceleration Structure buffer.
		/// </summary>
		/// <param name="context">The vulkan context.</param>
		/// <param name="bufferSize">The buffer size.</param>
		/// <param name="usage">The buffer usage.</param>
		/// <returns>The buffer memory address.</returns>
		public  static BufferData CreateBuffer(VKGraphicsContext context, uint64 bufferSize, VkBufferUsageFlags usage)
		{
			VkBufferCreateInfo vkBufferCreateInfo = default(VkBufferCreateInfo);
			vkBufferCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
			vkBufferCreateInfo.size = bufferSize;
			vkBufferCreateInfo.usage = usage;
			vkBufferCreateInfo.flags = VkBufferCreateFlags.None;
			vkBufferCreateInfo.sharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
			VkBufferCreateInfo vkBufferCreateInfo2 = vkBufferCreateInfo;
			VkBuffer buffer = default(VkBuffer);
			VulkanNative.vkCreateBuffer(context.VkDevice, &vkBufferCreateInfo2, null, &buffer);
			VkMemoryRequirements vkMemoryRequirements = default(VkMemoryRequirements);
			VulkanNative.vkGetBufferMemoryRequirements(context.VkDevice, buffer, &vkMemoryRequirements);
			VkMemoryAllocateFlagsInfo vkMemoryAllocateFlagsInfo = default(VkMemoryAllocateFlagsInfo);
			vkMemoryAllocateFlagsInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO;
			vkMemoryAllocateFlagsInfo.flags = VkMemoryAllocateFlags.VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT;
			VkMemoryAllocateFlagsInfo vkMemoryAllocateFlagsInfo2 = vkMemoryAllocateFlagsInfo;
			VkMemoryAllocateInfo vkMemoryAllocateInfo = default(VkMemoryAllocateInfo);
			vkMemoryAllocateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
			vkMemoryAllocateInfo.pNext = &vkMemoryAllocateFlagsInfo2;
			vkMemoryAllocateInfo.allocationSize = vkMemoryRequirements.size;
			vkMemoryAllocateInfo.memoryTypeIndex = (uint32)VKHelpers.FindMemoryType(context, vkMemoryRequirements.memoryTypeBits, VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
			VkMemoryAllocateInfo vkMemoryAllocateInfo2 = vkMemoryAllocateInfo;
			VkDeviceMemory memory = default(VkDeviceMemory);
			VulkanNative.vkAllocateMemory(context.VkDevice, &vkMemoryAllocateInfo2, null, &memory);
			VulkanNative.vkBindBufferMemory(context.VkDevice, buffer, memory, 0uL);
			BufferData result = default(BufferData);
			result.Buffer = buffer;
			result.Memory = memory;
			return result;
		}

		/// <summary>
		/// Create a stagging buffer from data.
		/// </summary>
		/// <param name="context">The vulkan context.</param>
		/// <param name="data">The source data pointer.</param>
		/// <param name="bufferSize">The buffer size.</param>
		/// <param name="usage">The buffer usage.</param>
		/// <returns>The buffer memory address.</returns>
		public  static BufferData CreateMappedBuffer(VKGraphicsContext context, void* data, uint64 bufferSize, VkBufferUsageFlags usage)
		{
			VkBufferCreateInfo vkBufferCreateInfo = default(VkBufferCreateInfo);
			vkBufferCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
			vkBufferCreateInfo.size = bufferSize;
			vkBufferCreateInfo.usage = usage;
			vkBufferCreateInfo.flags = VkBufferCreateFlags.None;
			vkBufferCreateInfo.sharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
			VkBufferCreateInfo vkBufferCreateInfo2 = vkBufferCreateInfo;
			VkBuffer buffer = default(VkBuffer);
			VulkanNative.vkCreateBuffer(context.VkDevice, &vkBufferCreateInfo2, null, &buffer);
			VkMemoryRequirements vkMemoryRequirements = default(VkMemoryRequirements);
			VulkanNative.vkGetBufferMemoryRequirements(context.VkDevice, buffer, &vkMemoryRequirements);
			VkMemoryAllocateFlagsInfo vkMemoryAllocateFlagsInfo = default(VkMemoryAllocateFlagsInfo);
			vkMemoryAllocateFlagsInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO;
			vkMemoryAllocateFlagsInfo.flags = VkMemoryAllocateFlags.VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT;
			VkMemoryAllocateFlagsInfo vkMemoryAllocateFlagsInfo2 = vkMemoryAllocateFlagsInfo;
			VkMemoryAllocateInfo vkMemoryAllocateInfo = default(VkMemoryAllocateInfo);
			vkMemoryAllocateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
			vkMemoryAllocateInfo.pNext = &vkMemoryAllocateFlagsInfo2;
			vkMemoryAllocateInfo.allocationSize = vkMemoryRequirements.size;
			vkMemoryAllocateInfo.memoryTypeIndex = (uint32)VKHelpers.FindMemoryType(context, vkMemoryRequirements.memoryTypeBits, VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
			VkMemoryAllocateInfo vkMemoryAllocateInfo2 = vkMemoryAllocateInfo;
			VkDeviceMemory memory = default(VkDeviceMemory);
			VulkanNative.vkAllocateMemory(context.VkDevice, &vkMemoryAllocateInfo2, null, &memory);
			VulkanNative.vkBindBufferMemory(context.VkDevice, buffer, memory, 0uL);
			if (data != null)
			{
				void* destination = default(void*);
				VulkanNative.vkMapMemory(context.VkDevice, memory, 0uL, bufferSize, 0u, &destination);
				Internal.MemCpy(destination, (void*)data, (uint32)bufferSize);
				VulkanNative.vkUnmapMemory(context.VkDevice, memory);
			}
			BufferData result = default(BufferData);
			result.Buffer = buffer;
			result.Memory = memory;
			return result;
		}
	}
}

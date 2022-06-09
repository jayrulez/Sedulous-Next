using Bulkan;
using Sedulous.Graphics;

namespace Sedulous.Graphics.Vulkan
{
	internal class VKUploadBuffer : UploadBuffer
	{
		/// <summary>
		/// The Vulkan texture instance.
		/// </summary>
		public VkBuffer NativeBuffer;

		public VkDeviceMemory BufferMemory;

		public VKUploadBuffer(VKGraphicsContext context, uint64 size, uint32 align = 512u)
			: base(context, size, align)
		{
		}

		protected  override void RefreshBuffer(uint64 size)
		{
			VKGraphicsContext vKGraphicsContext = (VKGraphicsContext)context;
			VkBufferCreateInfo vkBufferCreateInfo = default(VkBufferCreateInfo);
			vkBufferCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
			vkBufferCreateInfo.size = size;
			vkBufferCreateInfo.usage = VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
			vkBufferCreateInfo.sharingMode = (vKGraphicsContext.CopyQueueSupported ? VkSharingMode.VK_SHARING_MODE_CONCURRENT : VkSharingMode.VK_SHARING_MODE_EXCLUSIVE);
			int32 num = ((!vKGraphicsContext.CopyQueueSupported) ? 1 : 2);
			uint32* ptr = scope uint32[num];
			*ptr = (uint32)vKGraphicsContext.QueueIndices.GraphicsFamily;
			if (vKGraphicsContext.CopyQueueSupported)
			{
				ptr[1] = (uint32)vKGraphicsContext.QueueIndices.CopyFamily;
			}
			vkBufferCreateInfo.pQueueFamilyIndices = ptr;
			vkBufferCreateInfo.queueFamilyIndexCount = (uint32)num;
			VkBuffer nativeBuffer = default(VkBuffer);
			VulkanNative.vkCreateBuffer(vKGraphicsContext.VkDevice, &vkBufferCreateInfo, null, &nativeBuffer);
			NativeBuffer = nativeBuffer;
			VkMemoryRequirements vkMemoryRequirements = default(VkMemoryRequirements);
			VulkanNative.vkGetBufferMemoryRequirements(vKGraphicsContext.VkDevice, NativeBuffer, &vkMemoryRequirements);
			VkMemoryPropertyFlags properties = VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
			VkMemoryAllocateInfo vkMemoryAllocateInfo = default(VkMemoryAllocateInfo);
			vkMemoryAllocateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
			vkMemoryAllocateInfo.allocationSize = vkMemoryRequirements.size;
			int32 num2 = VKHelpers.FindMemoryType(vKGraphicsContext, vkMemoryRequirements.memoryTypeBits, properties);
			if (num2 == -1)
			{
				vKGraphicsContext.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
			}
			vkMemoryAllocateInfo.memoryTypeIndex = (uint32)num2;
			VkDeviceMemory bufferMemory = default(VkDeviceMemory);
			VulkanNative.vkAllocateMemory(vKGraphicsContext.VkDevice, &vkMemoryAllocateInfo, null, &bufferMemory);
			BufferMemory = bufferMemory;
			VulkanNative.vkBindBufferMemory(vKGraphicsContext.VkDevice, NativeBuffer, BufferMemory, 0uL);
			void* ptr2 = null;
			VulkanNative.vkMapMemory(vKGraphicsContext.VkDevice, BufferMemory, 0uL, (uint32)size, 0u, &ptr2);
			DataCurrent = (DataBegin = (uint64)ptr2);
			TotalSize = size;
			DataEnd = DataBegin + size;
		}

		public  override void Dispose()
		{
			VKGraphicsContext obj = (VKGraphicsContext)context;
			VulkanNative.vkUnmapMemory(obj.VkDevice, BufferMemory);
			VulkanNative.vkDestroyBuffer(obj.VkDevice, NativeBuffer, null);
			VulkanNative.vkFreeMemory(obj.VkDevice, BufferMemory, null);
		}
	}
}

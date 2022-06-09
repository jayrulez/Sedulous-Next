using Bulkan;

namespace Sedulous.Graphics.Vulkan
{
	internal struct VKQueueFamilyIndices
	{
		public int32 GraphicsFamily;

		public int32 Presentfamily;

		public int32 CopyFamily;

		public int32 ComputeFamily;

		/// <summary>
		/// Find the queue families supported.
		/// </summary>
		/// <param name="context">The graphics context Object.</param>
		/// <param name="physicalDevice">The physical device Object.</param>
		/// <param name="surface">The desired suface type.</param>
		/// <returns>The supported queue family indices.</returns>
		public  static VKQueueFamilyIndices FindQueueFamilies(VKGraphicsContext context, VkPhysicalDevice physicalDevice, VkSurfaceKHR? surface)
		{
			VKQueueFamilyIndices result = default(VKQueueFamilyIndices);
			result.GraphicsFamily = -1;
			result.Presentfamily = -1;
			result.CopyFamily = -1;
			result.ComputeFamily = -1;
			uint32 num = 0u;
			VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &num, null);
			VkQueueFamilyProperties* ptr = scope VkQueueFamilyProperties[(int32)num];
			VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &num, ptr);
			VkBool32 vkBool = default(VkBool32);
			for (int32 i = 0; i < num; i++)
			{
				VkQueueFamilyProperties vkQueueFamilyProperties = ptr[i];
				if (surface.HasValue)
				{
					VulkanNative.vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice, (uint32)i, surface.Value, &vkBool);
					if (result.Presentfamily < 0 && vkQueueFamilyProperties.queueCount != 0 && (bool)vkBool)
					{
						result.Presentfamily = i;
					}
				}
				if (vkQueueFamilyProperties.queueCount != 0 && (vkQueueFamilyProperties.queueFlags & VkQueueFlags.VK_QUEUE_GRAPHICS_BIT) != 0)
				{
					result.GraphicsFamily = i;
				}
				if (vkQueueFamilyProperties.queueCount != 0 && (vkQueueFamilyProperties.queueFlags & VkQueueFlags.VK_QUEUE_TRANSFER_BIT) != 0)
				{
					result.CopyFamily = i;
				}
				if (vkQueueFamilyProperties.queueCount != 0 && (vkQueueFamilyProperties.queueFlags & VkQueueFlags.VK_QUEUE_COMPUTE_BIT) != 0)
				{
					result.ComputeFamily = i;
				}
			}
			return result;
		}
	}
}

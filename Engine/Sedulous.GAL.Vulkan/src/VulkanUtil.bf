using System;
using System.Diagnostics;
using Bulkan;
using System.Collections;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.Vulkan
{
    public  static class VulkanUtil
    {
#if !DEBUG
        [SkipCall]
#endif
        public static void CheckResult(VkResult result)
        {
            if (result != VkResult.VK_SUCCESS)
            {
                Runtime.FatalError(scope $"Unsuccessful VkResult: {result}.");
            }
        }

        public static bool TryFindMemoryType(VkPhysicalDeviceMemoryProperties memProperties, uint32 typeFilter, VkMemoryPropertyFlags properties, out uint32 typeIndex)
        {
            typeIndex = 0;

            for (int i = 0; i < memProperties.memoryTypeCount; i++)
            {
                if (((typeFilter & (1 << i)) != 0)
                    && (memProperties.memoryTypes[i].propertyFlags & properties) == properties)
                {
                    typeIndex = (uint32)i;
                    return true;
                }
            }

            return false;
        }

        public static void EnumerateInstanceLayers(out List<String> availableInstanceLayers)
        {
			availableInstanceLayers = new List<String>();
            uint32 propCount = 0;
            VkResult result = vkEnumerateInstanceLayerProperties(&propCount, null);
            CheckResult(result);
            if (propCount == 0)
            {
                return;
            }

            VkLayerProperties[] props = scope VkLayerProperties[propCount];
            vkEnumerateInstanceLayerProperties(&propCount, props.Ptr);

            for (int i = 0; i < propCount; i++)
            {
				availableInstanceLayers.Add(new String(&props[i].layerName));
            }
        }

        public static void EnumerateInstanceExtensions(out List<String> availableInstanceExtensions)
        {
			availableInstanceExtensions = new List<String>();
            uint32 propCount = 0;
            VkResult result = vkEnumerateInstanceExtensionProperties(null, & propCount, null);
            if (result != VkResult.VK_SUCCESS)
            {
                return;
            }

            if (propCount == 0)
            {
                return;
            }

            VkExtensionProperties[] props = scope VkExtensionProperties[propCount];
            vkEnumerateInstanceExtensionProperties(null, &propCount, props.Ptr);

            for (int i = 0; i < propCount; i++)
            {
				availableInstanceExtensions.Add(new String(&props[i].extensionName));
            }
        }

        public static void EnumerateDeviceExtensions(VkPhysicalDevice physicalDevice, out List<String> deviceExtensions)
        {
			deviceExtensions = new List<String>();
            uint32 propertyCount = 0;
            VkResult result = vkEnumerateDeviceExtensionProperties(physicalDevice, null, &propertyCount, null);
            CheckResult(result);
			if(propertyCount == 0)
				return;
            VkExtensionProperties[] props = scope VkExtensionProperties[(int32)propertyCount];
            result = vkEnumerateDeviceExtensionProperties(physicalDevice, null, &propertyCount, props.Ptr);
                CheckResult(result);

			for(int i = 0; i < propertyCount; i++){
				deviceExtensions.Add(new String(&props[i].extensionName));
			}
        }

        public static void TransitionImageLayout(
            VkCommandBuffer cb,
            VkImage image,
            uint32 baseMipLevel,
            uint32 levelCount,
            uint32 baseArrayLayer,
            uint32 layerCount,
            VkImageAspectFlags aspectMask,
            VkImageLayout oldLayout,
            VkImageLayout newLayout)
        {
            Debug.Assert(oldLayout != newLayout);
            VkImageMemoryBarrier barrier = VkImageMemoryBarrier();
            barrier.oldLayout = oldLayout;
            barrier.newLayout = newLayout;
            barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
            barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
            barrier.image = image;
            barrier.subresourceRange.aspectMask = aspectMask;
            barrier.subresourceRange.baseMipLevel = baseMipLevel;
            barrier.subresourceRange.levelCount = levelCount;
            barrier.subresourceRange.baseArrayLayer = baseArrayLayer;
            barrier.subresourceRange.layerCount = layerCount;

            VkPipelineStageFlags srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;
            VkPipelineStageFlags dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;

            if ((oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED || oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED) && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_GENERAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_GENERAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_GENERAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
            }

            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_GENERAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_GENERAL && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else if (oldLayout == VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR && newLayout == VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL)
            {
                barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT;
                barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
                srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
                dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
            }
            else
            {
                Debug.FatalError("Invalid image layout transition.");
            }

            vkCmdPipelineBarrier(
                cb,
                srcStageFlags,
                dstStageFlags,
                VkDependencyFlags.None,
                0, null,
                0, null,
                1, &barrier);
        }
    }

    internal  static class VkPhysicalDeviceMemoryPropertiesEx
    {
        public static VkMemoryType GetMemoryType(this VkPhysicalDeviceMemoryProperties memoryProperties, uint32 index)
        {
            return memoryProperties.memoryTypes[index];
        }
    }
}

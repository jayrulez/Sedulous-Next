using System;
using Bulkan;
using Sedulous.Graphics;

namespace Sedulous.Graphics.Vulkan
{
	/// <summary>
	/// Represents a Vulkan queryheap Object.
	/// </summary>
	public class VKQueryHeap : QueryHeap
	{
		/// <summary>
		/// The vulkan native Object.
		/// </summary>
		public VkQueryPool nativeQueryHeap;

		private VKGraphicsContext vkContext;

		/// <inheritdoc />
		public override void* NativePointer => (void*)(int)nativeQueryHeap.Handle;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKQueryHeap" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The queryheap description.</param>
		public  this(VKGraphicsContext context, ref QueryHeapDescription description)
			: base(context, ref description)
		{
			vkContext = context;
			VkQueryPoolCreateInfo vkQueryPoolCreateInfo = VkQueryPoolCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO,
				queryCount = description.QueryCount
			};
			switch (description.Type)
			{
			case QueryType.Timestamp:
				vkQueryPoolCreateInfo.queryType = VkQueryType.VK_QUERY_TYPE_TIMESTAMP;
				break;
			case QueryType.Occlusion: fallthrough;
			case QueryType.BinaryOcclusion:
				vkQueryPoolCreateInfo.queryType = VkQueryType.VK_QUERY_TYPE_OCCLUSION;
				break;
			}
			VkQueryPool vkQueryPool = default(VkQueryPool);
			VulkanNative.vkCreateQueryPool(vkContext.VkDevice, &vkQueryPoolCreateInfo, null, &vkQueryPool);
			nativeQueryHeap = vkQueryPool;
			VulkanNative.vkResetQueryPool(vkContext.VkDevice, nativeQueryHeap, 0u, vkQueryPoolCreateInfo.queryCount);
		}

		/// <inheritdoc />
		public  override bool ReadData(uint32 startIndex, uint32 count, uint64[] results)
		{
			uint64 stride = 8uL;
			uint32 num = 8 * count;
			VkResult num2 = VulkanNative.vkGetQueryPoolResults(vkContext.VkDevice, nativeQueryHeap, startIndex, count, (.)(int)(void*)&num, (.)(int)(void*)results.Ptr, stride, VkQueryResultFlags.VK_QUERY_RESULT_64_BIT);
			VulkanNative.vkResetQueryPool(vkContext.VkDevice, nativeQueryHeap, startIndex, count);
			return num2 == VkResult.VK_SUCCESS;
		}

		public ~this()
		{
			OnDestroy();
			VulkanNative.vkDestroyQueryPool((Context as VKGraphicsContext).VkDevice, nativeQueryHeap, null);
		}
	}
}

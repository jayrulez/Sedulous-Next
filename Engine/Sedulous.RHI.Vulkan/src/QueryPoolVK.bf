using Bulkan;
using System;
using static Bulkan.VulkanNative;
using static Sedulous.RHI.Vulkan.VulkanUtils;
namespace Sedulous.RHI.Vulkan
{
	class QueryPoolVK : QueryPool
	{
		private VkQueryPool[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
		private uint32 m_Stride = 0;
		private VkQueryType m_Type = (VkQueryType)0;
		private DeviceVK m_Device;
		private bool m_OwnsNativeObjects = false;

		 //////////////////////////////Private Methods//////////////////////////////

		 ///////////////////////////////////////////////////////////////////////////

		 /////////////////////////////Internal Methods//////////////////////////////

		public VkQueryPool GetHandle(uint32 physicalDeviceIndex) => m_Handles[physicalDeviceIndex];

		public readonly ref DeviceVK GetDevice() => ref m_Device;

		public uint32 GetStride() => m_Stride;

		public VkQueryType GetQueryType() => m_Type;

		public Result Create(in QueryPoolDesc queryPoolDesc)
		{
			m_OwnsNativeObjects = true;
			m_Type = VulkanUtils.GetVkQueryType(queryPoolDesc.queryType);

			VkQueryPoolCreateInfo poolInfo = .()
				{
					sType = .VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO,
					pNext = null,
					flags = (. /*VkQueryPoolCreateFlags*/)0,
					queryType = m_Type,
					queryCount = queryPoolDesc.capacity,
					pipelineStatistics = VulkanUtils.GetQueryPipelineStatisticsFlags(queryPoolDesc.pipelineStatsMask)
				};

			readonly uint32 physicalDeviceMask = (queryPoolDesc.physicalDeviceMask == WHOLE_DEVICE_GROUP) ? 0xff : queryPoolDesc.physicalDeviceMask;

			for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
			{
				if ((1 << i) & physicalDeviceMask != 0)
				{
					readonly VkResult result = vkCreateQueryPool(m_Device, &poolInfo, m_Device.GetAllocationCallbacks(), &m_Handles[i]);

					RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
						"Can't create a query pool: vkCreateQueryPool returned {0}.", (int32)result);
				}
			}

			m_Stride = GetQuerySize();

			return Result.SUCCESS;
		}

		public Result Create(in QueryPoolVulkanDesc queryPoolDesc)
		{
			m_OwnsNativeObjects = false;
			m_Type = (VkQueryType)queryPoolDesc.vkQueryType;

			readonly VkQueryPool handle = (VkQueryPool)queryPoolDesc.vkQueryPool;
			readonly uint32 physicalDeviceMask = GetPhysicalDeviceGroupMask(queryPoolDesc.physicalDeviceMask);

			for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
			{
				if ((1 << i) & physicalDeviceMask != 0)
					m_Handles[i] = handle;
			}

			m_Stride = GetQuerySize();

			return Result.SUCCESS;
		}
		 ///////////////////////////////////////////////////////////////////////////



		public this(DeviceVK device)
		{
			m_Device = device;
		}

		public ~this()
		{
			if (!m_OwnsNativeObjects)
				return;

			for (uint32 i = 0; i < m_Handles.Count; i++)
			{
				if (m_Handles[i] != .Null)
					vkDestroyQueryPool(m_Device, m_Handles[i], m_Device.GetAllocationCallbacks());
			}
		}

		public override void SetDebugName(in StringView name)
		{
			uint64[PHYSICAL_DEVICE_GROUP_MAX_SIZE] handles = .();
			for (int i = 0; i < handles.Count; i++)
				handles[i] = (uint64)m_Handles[i].Handle;

			m_Device.SetDebugNameToDeviceGroupObject(.VK_OBJECT_TYPE_QUERY_POOL, &handles, name);
		}

		public override uint32 GetQuerySize()
		{
			readonly uint32 highestBitInPipelineStatsBits = 11;

			switch (m_Type)
			{
			case .VK_QUERY_TYPE_TIMESTAMP:
				return sizeof(uint64);
			case .VK_QUERY_TYPE_OCCLUSION:
				return sizeof(uint64);
			case .VK_QUERY_TYPE_PIPELINE_STATISTICS:
				return highestBitInPipelineStatsBits * sizeof(uint64);
			default:
				CHECK!(m_Device.GetLogger(), false, "unexpected query type in GetQuerySize: {0}", (uint32)m_Type);
				return 0;
			}
		}
	}
}
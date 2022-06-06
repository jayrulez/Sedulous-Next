using Bulkan;
namespace Sedulous.RHI.Vulkan
{
	class QueryPoolVK : QueryPool
	{
       private  VkQueryPool[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
       private  uint32 m_Stride = 0;
       private  VkQueryType m_Type = (VkQueryType)0;
       private  DeviceVK m_Device;
       private  bool m_OwnsNativeObjects = false;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////
	}
}
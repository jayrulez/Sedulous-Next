using Bulkan;
namespace Sedulous.RHI.Vulkan
{
	class DescriptorSetVK : DescriptorSet
	{
       private  VkDescriptorSet[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
       private  uint32 m_DynamicConstantBufferNum = 0;
       private  readonly DescriptorSetDesc* m_SetDesc = null;
       private  DeviceVK m_Device;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////
	}
}
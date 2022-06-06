using Bulkan;
namespace Sedulous.RHI.Vulkan
{
	class CommandBufferVK : CommandBuffer
	{
       private  VkCommandBuffer m_Handle = .Null;
       private  uint32 m_PhysicalDeviceIndex = 0;
       private  DeviceVK m_Device;
       private  CommandQueueType m_Type = (CommandQueueType)0;
       private  VkPipelineBindPoint m_CurrentPipelineBindPoint = (.)uint32.MaxValue;
       private  VkPipelineLayout m_CurrentPipelineLayoutHandle = .Null;
       private  PipelineVK m_CurrentPipeline = null;
       private  PipelineLayoutVK m_CurrentPipelineLayout = null;
       private  FrameBufferVK m_CurrentFrameBuffer = null;
       private  VkCommandPool m_CommandPool = .Null;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////

		/////////////////////////////Internal Methods//////////////////////////////
		///////////////////////////////////////////////////////////////////////////
	}
}
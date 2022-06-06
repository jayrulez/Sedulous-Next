using Bulkan;
namespace Sedulous.RHI.Vulkan
{
	class FrameBufferVK : FrameBuffer
	{
		private const uint32 ATTACHMENT_MAX_NUM = 8;

		private VkFramebuffer[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
		private VkRenderPass m_RenderPassWithClear = .Null;
		private VkRenderPass m_RenderPass = .Null;
		private ClearValueDesc[ATTACHMENT_MAX_NUM] m_ClearValues = .();
		private VkRect2D m_RenderArea = .();
		private uint32 m_AttachmentNum = 0;
		private DeviceVK m_Device;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////

		/////////////////////////////Internal Methods//////////////////////////////
		///////////////////////////////////////////////////////////////////////////
	}
}
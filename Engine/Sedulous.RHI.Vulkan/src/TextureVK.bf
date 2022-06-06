using Bulkan;
namespace Sedulous.RHI.Vulkan
{
	class TextureVK : Texture
	{
		private VkImage[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
		private VkImageAspectFlags m_ImageAspectFlags = (VkImageAspectFlags)0;
		private VkExtent3D m_Extent = .();
		private uint16 m_MipNum = 0;
		private uint16 m_ArraySize = 0;
		private Format m_Format = Format.UNKNOWN;
		private TextureType m_TextureType = (TextureType)0;
		private VkSampleCountFlags m_SampleCount = (VkSampleCountFlags)0;
		private DeviceVK m_Device;
		private bool m_OwnsNativeObjects = false;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////
	}
}
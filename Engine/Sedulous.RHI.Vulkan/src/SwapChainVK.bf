using Bulkan;
using System.Collections;
namespace Sedulous.RHI.Vulkan
{
	class SwapChainVK : SwapChain
	{
		private VkSwapchainKHR m_Handle = .Null;
		private readonly CommandQueueVK m_CommandQueue = null;
		private uint32 m_TextureIndex = uint32.MaxValue;
		private VkSurfaceKHR m_Surface = .Null;
		private List<TextureVK> m_Textures;
		private Format m_Format = Format.UNKNOWN;
		private DeviceVK m_Device;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////
	}
}
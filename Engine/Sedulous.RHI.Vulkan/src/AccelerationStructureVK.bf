using Bulkan;
namespace Sedulous.RHI.Vulkan
{
	class AccelerationStructureVK : AccelerationStructure
	{
		private VkAccelerationStructureKHR[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
		private VkDeviceAddress[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_DeviceAddresses = .();
		private BufferVK m_Buffer = null;
		private DeviceVK m_Device;
		private uint64 m_BuildScratchSize = 0;
		private uint64 m_UpdateScratchSize = 0;
		private uint64 m_AccelerationStructureSize = 0;
		private uint32 m_PhysicalDeviceMask = 0;
		private VkAccelerationStructureTypeKHR m_Type = (VkAccelerationStructureTypeKHR)0;
		private VkBuildAccelerationStructureFlagsKHR m_BuildFlags = (VkBuildAccelerationStructureFlagsKHR)0;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////

		/////////////////////////////Internal Methods//////////////////////////////
		///////////////////////////////////////////////////////////////////////////
	}
}
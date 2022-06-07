namespace Sedulous.RHI
{
	static class DeviceFactory
	{
		public static Result GetPhysicalDevices(PhysicalDeviceGroup* physicalDeviceGroups, ref uint32 physicalDeviceGroupNum)
		{
			return .SUCCESS;
		}

		public static Result CreateDevice(in DeviceCreationDesc deviceCreationDesc, DeviceAllocator allocator, out Device device)
		{
			device = ?;
			return .SUCCESS;
		}

		public static void DestroyDevice(DeviceAllocator allocator, ref Device device)
		{
			Deallocate!(allocator, device);
		}
	}
}
using System;
namespace Sedulous.RHI
{
	abstract class AccelerationStructure
	{
		public abstract void SetDebugName(StringView name);

		
		public abstract void GetMemoryInfo(ref MemoryDesc memoryDesc);
		public abstract uint64 GetUpdateScratchBufferSize();
		public abstract uint64 GetBuildScratchBufferSize();
		public abstract uint64 GetNativeHandle(uint32 physicalDeviceIndex);
		public abstract Result CreateDescriptor(uint32 physicalDeviceMask, out Descriptor descriptor);
	}
}
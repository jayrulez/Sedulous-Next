using System;
namespace Sedulous.RHI.Validation
{
	class AccelerationStructureValidator : AccelerationStructure
	{
		private readonly DeviceValidator mDevice;
		private AccelerationStructure mAccelerationStructure;
		private MemoryValidator m_Memory = null;

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, AccelerationStructure accelerationStructure)
		{
			mDevice = device;
			mAccelerationStructure = accelerationStructure;
		}

		public ~this()
		{
			if (m_Memory != null)
				m_Memory.UnbindAccelerationStructure(this);

			mDevice.DestroyAccelerationStructure(ref mAccelerationStructure);
		}

		public AccelerationStructure GetImpl() => mAccelerationStructure;

		public void SetBoundToMemory(MemoryValidator memory)
		{
			m_Memory = memory;
		}

		public bool IsBoundToMemory()
		{
			return m_Memory != null;
		}

		public override void SetDebugName(StringView name)
		{
			mDebugName.Set(name);
			mAccelerationStructure.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override void GetMemoryInfo(ref MemoryDesc memoryDesc)
		{
			mAccelerationStructure.GetMemoryInfo(ref memoryDesc);
			mDevice.RegisterMemoryType(memoryDesc.type, MemoryLocation.DEVICE);
		}

		public override uint64 GetUpdateScratchBufferSize()
		{
			return mAccelerationStructure.GetUpdateScratchBufferSize();
		}

		public override uint64 GetBuildScratchBufferSize()
		{
			return mAccelerationStructure.GetBuildScratchBufferSize();
		}

		public override uint64 GetNativeHandle(uint32 physicalDeviceIndex)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_Memory != null, 0,
				"Can't get AccelerationStructure handle: AccelerationStructure is not bound to memory.");

			return mAccelerationStructure.GetNativeHandle(physicalDeviceIndex);
		}

		public override Result CreateDescriptor(uint32 physicalDeviceIndex, out Descriptor descriptor)
		{
			descriptor = ?;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), physicalDeviceIndex < mDevice.GetPhysicalDeviceNum(), Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'physicalDeviceIndex' is invalid.");

			Descriptor descriptorImpl = null;
			readonly Result result = mAccelerationStructure.CreateDescriptor(physicalDeviceIndex, out descriptorImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(mDevice.GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is nullptr.");
				descriptor = (Descriptor)Allocate!<DescriptorValidator>(mDevice.GetDeviceAllocator(), mDevice, descriptorImpl, ResourceType.ACCELERATION_STRUCTURE);
			}

			return result;
		}
	}
}
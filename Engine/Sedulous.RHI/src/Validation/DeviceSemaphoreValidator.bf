namespace Sedulous.RHI.Validation
{
	using Sedulous.RHI;
	using System;

	class DeviceSemaphoreValidator : DeviceSemaphore
	{
		private readonly DeviceValidator mDevice;
		private DeviceSemaphore mDeviceSemaphore;

		private readonly String mDebugName = new .() ~ delete _;

		private uint64 m_Value = 0;

		public this(DeviceValidator device, DeviceSemaphore deviceSemaphore)
		{
			mDevice = device;
			mDeviceSemaphore = deviceSemaphore;
		}

		public ref DeviceSemaphore GetImpl() => ref mDeviceSemaphore;

		public void Create(bool signaled)
		{
			m_Value = signaled ? 1 : 0;
		}

		public bool IsUnsignaled()
		{
			return (m_Value & 0x1) == 0;
		}

		public void Signal()
		{
			if (!IsUnsignaled())
				REPORT_ERROR(mDevice.GetLogger(), "Semaphore is already in signaled state!");

			m_Value++;
		}

		public void Wait()
		{
			if (IsUnsignaled())
				REPORT_ERROR(mDevice.GetLogger(), "Semaphore is already in unsignaled state!");

			m_Value++;
		}

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mDeviceSemaphore.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;
	}
}
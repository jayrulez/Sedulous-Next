namespace Sedulous.RHI.Validation
{
	using Sedulous.RHI;
	using System;

	class QueueSemaphoreValidator : QueueSemaphore
	{
		private readonly DeviceValidator mDevice;
		private QueueSemaphore mQueueSemaphore;

		private readonly String mDebugName = new .() ~ delete _;

		private bool m_isSignaled = false;

		public this(DeviceValidator device, QueueSemaphore queueSemaphore)
		{
			mDevice = device;
			mQueueSemaphore = queueSemaphore;
		}

		public ref QueueSemaphore GetImpl() => ref mQueueSemaphore;

		public void Signal()
		{
			if (m_isSignaled)
				REPORT_ERROR(mDevice.GetLogger(), "Can't signal QueueSemaphore: it's already in signaled state.");

			m_isSignaled = true;
		}

		public void Wait()
		{
			if (!m_isSignaled)
				REPORT_ERROR(mDevice.GetLogger(), "Can't wait for QueueSemaphore: it's already in unsignaled state.");

			m_isSignaled = false;
		}

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mQueueSemaphore.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;
	}
}
namespace Sedulous.RHI.Helpers
{
	class ResourceStateChangeHelper
	{
		private Device m_Device;
		private CommandQueue m_CommandQueue;
		private CommandAllocator m_CommandAllocator = null;
		private CommandBuffer m_CommandBuffer = null;
		private WaitIdleHelper m_WaitIdleHelper;

		public this(Device device, CommandQueue commandQueue)
		{
			m_Device = device;
			m_CommandQueue = commandQueue;
			m_WaitIdleHelper = Allocate!<WaitIdleHelper>(m_Device.GetDeviceAllocator(), ref m_Device, ref m_CommandQueue);

			if (m_Device.CreateCommandAllocator(m_CommandQueue, WHOLE_DEVICE_GROUP, out m_CommandAllocator) == .SUCCESS)
			{
				m_CommandAllocator.CreateCommandBuffer(out m_CommandBuffer);
			}
		}

		public ~this()
		{
			if (m_CommandBuffer != null)
				m_Device.DestroyCommandBuffer(ref m_CommandBuffer);
			m_CommandBuffer = null;

			if (m_CommandAllocator != null)
				m_Device.DestroyCommandAllocator(ref m_CommandAllocator);
			m_CommandAllocator = null;

			Deallocate!(m_Device.GetDeviceAllocator(), m_WaitIdleHelper);
		}

		public Result ChangeStates(in TransitionBarrierDesc transitionBarriers)
		{
			if (m_CommandBuffer == null)
				return Result.FAILURE;

			readonly uint32 physicalDeviceNum = m_Device.GetDesc().phyiscalDeviceGroupSize;

			for (uint32 i = 0; i < physicalDeviceNum; i++)
			{
				m_CommandBuffer.Begin(null, i);
				m_CommandBuffer.PipelineBarrier(&transitionBarriers, null, BarrierDependency.ALL_STAGES);
				m_CommandBuffer.End();

				WorkSubmissionDesc workSubmissionDesc = .()
					{
						physicalDeviceIndex = i,
						commandBufferNum = 1,
						commandBuffers = &m_CommandBuffer
					};

				m_CommandQueue.Submit(workSubmissionDesc, null);
			}

			return m_WaitIdleHelper.WaitIdle();
		}
	}
}
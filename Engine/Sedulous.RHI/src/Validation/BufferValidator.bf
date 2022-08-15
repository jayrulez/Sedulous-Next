using System;
namespace Sedulous.RHI.Validation
{
	class BufferValidator : Buffer
	{
		private readonly DeviceValidator mDevice;
		private Buffer mBuffer;
		private MemoryValidator m_Memory = null;
		private readonly BufferDesc m_BufferDesc = .();
		private bool m_IsBoundToMemory = false;
		private bool m_IsMapped = false;

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, Buffer buffer, BufferDesc bufferDesc)
		{
			mDevice = device;
			mBuffer = buffer;

			m_BufferDesc = bufferDesc;
		}

		public ~this()
		{
			if (m_Memory != null)
				m_Memory.UnbindBuffer(this);
		}

		public ref Buffer GetImpl() => ref mBuffer;

		public void SetBoundToMemory()
		{
			m_IsBoundToMemory = true;
		}

		public void SetBoundToMemory(MemoryValidator memory)
		{
			m_Memory = memory;
			m_IsBoundToMemory = true;
		}

		public bool IsBoundToMemory()
		{
			return m_IsBoundToMemory;
		}

		public BufferUsageBits GetUsageMask() => m_BufferDesc.usageMask;

		public readonly ref BufferDesc GetDesc() => ref m_BufferDesc;

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mBuffer.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc)
		{
			mBuffer.GetMemoryInfo(memoryLocation, ref memoryDesc);
			mDevice.RegisterMemoryType(memoryDesc.type, memoryLocation);
		}

		public override void* Map(uint64 offset, uint64 size)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsBoundToMemory, (void*)null,
				"Can't map Buffer: Buffer is not bound to memory.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), !m_IsMapped, (void*)null,
				"Can't map Buffer: the buffer is already mapped.");

			m_IsMapped = true;

			return mBuffer.Map(offset, size);
		}

		public override void Unmap()
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsMapped, void(),
				"Can't unmap Buffer: the buffer is not mapped.");

			m_IsMapped = false;

			mBuffer.Unmap();
		}
	}
}
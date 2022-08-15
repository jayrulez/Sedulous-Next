using System.Collections;
using System.Threading;
using System;
namespace Sedulous.RHI.Validation
{
	class MemoryValidator : Memory
	{
		private readonly DeviceValidator mDevice;
		private Memory mMemory;

		private List<BufferValidator> m_Buffers = new .() ~ delete _;
		private List<TextureValidator> m_Textures = new .() ~ delete _;
		private List<AccelerationStructureValidator> m_AccelerationStructures = new .() ~ delete _;
		private Monitor m_Lock = new .() ~ delete _;

		private readonly String mDebugName = new .() ~ delete _;

		uint64 m_Size = 0;
		MemoryLocation m_MemoryLocation = MemoryLocation.MAX_NUM;

		public this(DeviceValidator device, Memory memory, uint64 size, MemoryLocation memoryLocation)
		{
			mDevice = device;
			mMemory = memory;
			m_Size = size;
			m_MemoryLocation = memoryLocation;
		}

		public ref Memory GetImpl() => ref mMemory;

		public uint64 GetSize() => m_Size;

		public MemoryLocation GetMemoryLocation() => m_MemoryLocation;

		public bool HasBoundResources()
		{
			using (m_Lock.Enter())
			{
				return !m_Buffers.IsEmpty || !m_Textures.IsEmpty || !m_AccelerationStructures.IsEmpty;
			}
		}

		public void ReportBoundResources()
		{
			using (m_Lock.Enter())
			{
				for (int i = 0; i < m_Buffers.Count; i++)
				{
					BufferValidator buffer = m_Buffers[i];
					REPORT_ERROR(mDevice.GetLogger(), "Buffer ({} '{}') is still bound to the memory.",
						&buffer, buffer.GetDebugName());
				}

				for (int i = 0; i < m_Textures.Count; i++)
				{
					TextureValidator texture = m_Textures[i];
					REPORT_ERROR(mDevice.GetLogger(), "Texture ({} '{}') is still bound to the memory.",
						&texture, texture.GetDebugName());
				}

				for (int i = 0; i < m_AccelerationStructures.Count; i++)
				{
					AccelerationStructureValidator accelerationStructure = m_AccelerationStructures[i];
					REPORT_ERROR(mDevice.GetLogger(), "AccelerationStructure ({} '{}') is still bound to the memory.",
						&accelerationStructure, accelerationStructure.GetDebugName());
				}
			}
		}

		public void BindBuffer(BufferValidator buffer)
		{
			using (m_Lock.Enter())
			{
				m_Buffers.Add(buffer);
				buffer.SetBoundToMemory(this);
			}
		}

		public void BindTexture(TextureValidator texture)
		{
			using (m_Lock.Enter())
			{
				m_Textures.Add(texture);
				texture.SetBoundToMemory(this);
			}
		}

		public void BindAccelerationStructure(AccelerationStructureValidator accelerationStructure)
		{
			using (m_Lock.Enter())
			{
				m_AccelerationStructures.Add(accelerationStructure);
				accelerationStructure.SetBoundToMemory(this);
			}
		}

		public void UnbindBuffer(BufferValidator buffer)
		{
			using (m_Lock.Enter())
			{
				if (!m_Buffers.Contains(buffer))
				{
					REPORT_ERROR(mDevice.GetLogger(), "Unexpected error: Can't find the buffer in the list of bound resources.");
					return;
				}

				m_Buffers.Remove(buffer);
			}
		}

		public void UnbindTexture(TextureValidator texture)
		{
			using (m_Lock.Enter())
			{
				if (!m_Textures.Contains(texture))
				{
					REPORT_ERROR(mDevice.GetLogger(), "Unexpected error: Can't find the texture in the list of bound resources.");
					return;
				}

				m_Textures.Remove(texture);
			}
		}

		public void UnbindAccelerationStructure(AccelerationStructureValidator accelerationStructure)
		{
			using (m_Lock.Enter())
			{
				if (!m_AccelerationStructures.Contains(accelerationStructure))
				{
					REPORT_ERROR(mDevice.GetLogger(), "Unexpected error: Can't find the acceleration structure in the list of bound resources.");
					return;
				}

				m_AccelerationStructures.Remove(accelerationStructure);
			}
		}

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mMemory.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;
	}
}
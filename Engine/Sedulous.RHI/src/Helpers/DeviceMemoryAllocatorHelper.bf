using System;
using System.Collections;
namespace Sedulous.RHI.Helpers
{
	class DeviceMemoryAllocatorHelper
	{
		struct MemoryTypeGroup : IDisposable
		{
			private DeviceAllocator m_Allocator;

			public this(DeviceAllocator allocator)
			{
				m_Allocator = allocator;

				buffers = Allocate!<List<Buffer>>(m_Allocator);
				bufferOffsets = Allocate!<List<uint64>>(m_Allocator);
				textures = Allocate!<List<Texture>>(m_Allocator);
				textureOffsets = Allocate!<List<uint64>>(m_Allocator);
				memoryOffset = 0;
			}

			public List<Buffer> buffers;
			public List<uint64> bufferOffsets;
			public List<Texture> textures;
			public List<uint64> textureOffsets;
			public uint64 memoryOffset;

			public void Dispose()
			{
				Deallocate!(m_Allocator, textureOffsets);
				Deallocate!(m_Allocator, textures);
				Deallocate!(m_Allocator, bufferOffsets);
				Deallocate!(m_Allocator, buffers);
			}
		}

		private Device m_Device;
		private DeviceAllocator m_Allocator;

		private Dictionary<MemoryType, MemoryTypeGroup> m_Map;
		private List<Buffer> m_DedicatedBuffers;
		private List<Texture> m_DedicatedTextures;
		private List<BufferMemoryBindingDesc> m_BufferBindingDescs;
		private List<TextureMemoryBindingDesc> m_TextureBindingDescs;

		//////////////////////////////Private Methods//////////////////////////////

		private Result TryToAllocateAndBindMemory(ResourceGroupDesc resourceGroupDesc, Memory* allocations, ref int allocationNum)
		{
			GroupByMemoryType(resourceGroupDesc.memoryLocation, resourceGroupDesc.buffers, resourceGroupDesc.bufferNum);
			GroupByMemoryType(resourceGroupDesc.memoryLocation, resourceGroupDesc.textures, resourceGroupDesc.textureNum);

			Result result = Result.SUCCESS;

			for (var it = m_Map.GetEnumerator(); it.MoveNext() && result == Result.SUCCESS; )
			    result = ProcessMemoryTypeGroup(it.CurrentRef.key, ref *it.CurrentRef.valueRef, allocations, ref allocationNum);

			if (result != Result.SUCCESS)
			    return result;

			result = ProcessDedicatedResources(resourceGroupDesc.memoryLocation, allocations, ref allocationNum);

			if (result != Result.SUCCESS)
			    return result;

			result = m_Device.BindBufferMemory(m_BufferBindingDescs.Ptr, (uint32)m_BufferBindingDescs.Count);

			if (result != Result.SUCCESS)
			    return result;

			result = m_Device.BindTextureMemory(m_TextureBindingDescs.Ptr, (uint32)m_TextureBindingDescs.Count);

			return result;
		}

		private Result ProcessMemoryTypeGroup(MemoryType memoryType, ref MemoryTypeGroup group, Memory* allocations, ref int allocationNum)
		{
			ref Memory memory = ref allocations[allocationNum];

			readonly uint64 allocationSize = group.memoryOffset;

			readonly Result result = m_Device.AllocateMemory(WHOLE_DEVICE_GROUP, memoryType, allocationSize, out memory);
			if (result != Result.SUCCESS)
			    return result;

			FillMemoryBindingDescs(group.buffers.Ptr, group.bufferOffsets.Ptr, (uint32)group.buffers.Count, memory);
			FillMemoryBindingDescs(group.textures.Ptr, group.textureOffsets.Ptr, (uint32)group.textures.Count, memory);
			allocationNum++;

			return Result.SUCCESS;
		}

		private Result ProcessDedicatedResources(MemoryLocation memoryLocation, Memory* allocations, ref int allocationNum)
		{
			/*const*/ uint64 zeroOffset = 0;
			MemoryDesc memoryDesc = .(){};

			for (int i = 0; i < m_DedicatedBuffers.Count; i++)
			{
			    m_DedicatedBuffers[i].GetMemoryInfo(memoryLocation, ref memoryDesc);

			    ref Memory memory = ref allocations[allocationNum];

			    readonly Result result = m_Device.AllocateMemory(WHOLE_DEVICE_GROUP, memoryDesc.type, memoryDesc.size, out memory);
			    if (result != Result.SUCCESS)
			        return result;

			    FillMemoryBindingDescs(m_DedicatedBuffers.Ptr + i, &zeroOffset, 1, memory);
			    allocationNum++;
			}

			for (int i = 0; i < m_DedicatedTextures.Count; i++)
			{
			    m_DedicatedTextures[i].GetMemoryInfo(memoryLocation, ref memoryDesc);

			    ref Memory memory = ref allocations[allocationNum];

			    readonly Result result = m_Device.AllocateMemory(WHOLE_DEVICE_GROUP, memoryDesc.type, memoryDesc.size, out memory);
			    if (result != Result.SUCCESS)
			        return result;

			    FillMemoryBindingDescs(m_DedicatedTextures.Ptr + i, &zeroOffset, 1, memory);
			    allocationNum++;
			}

			return Result.SUCCESS;
		}

		private void GroupByMemoryType(MemoryLocation memoryLocation, Buffer* buffers, uint32 bufferNum)
		{
			MemoryDesc memoryDesc = .(){};

			for (uint32 i = 0; i < bufferNum; i++)
			{
			    Buffer buffer = buffers[i];
			    buffer.GetMemoryInfo(memoryLocation, ref memoryDesc);

			    if (memoryDesc.mustBeDedicated)
			        m_DedicatedBuffers.Add(buffer);
			    else
			    {
			        if(!m_Map.ContainsKey(memoryDesc.type)){
						m_Map.Add(memoryDesc.type, .(m_Device.GetDeviceAllocator()));
					}
					var group = ref m_Map[memoryDesc.type];

			        readonly uint64 offset = Align(group.memoryOffset, memoryDesc.alignment);

			        group.buffers.Add(buffer);
			        group.bufferOffsets.Add(offset);
			        group.memoryOffset = offset + memoryDesc.size;
			    }
			}
		}

		private void GroupByMemoryType(MemoryLocation memoryLocation, Texture* textures, uint32 textureNum)
		{
			readonly ref DeviceDesc deviceDesc = ref m_Device.GetDesc();

			MemoryDesc memoryDesc = .(){};

			for (uint32 i = 0; i < textureNum; i++)
			{
			    Texture texture = textures[i];
			    texture.GetMemoryInfo(memoryLocation, ref memoryDesc);

			    if (memoryDesc.mustBeDedicated)
			        m_DedicatedTextures.Add(texture);
			    else
			    {
			        if(!m_Map.ContainsKey(memoryDesc.type)){
						m_Map.Add(memoryDesc.type, .(m_Device.GetDeviceAllocator()));
					}
					var group = ref m_Map[memoryDesc.type];

			        if (group.textures.IsEmpty && group.memoryOffset > 0)
			            group.memoryOffset = Align(group.memoryOffset, deviceDesc.bufferTextureGranularity);

			        readonly uint64 offset = Align(group.memoryOffset, memoryDesc.alignment);

			        group.textures.Add(texture);
			        group.textureOffsets.Add(offset);
			        group.memoryOffset = offset + memoryDesc.size;
			    }
			}
		}

		private void FillMemoryBindingDescs(Buffer* buffers, uint64* bufferOffsets, uint32 bufferNum, Memory memory)
		{
			for (uint32 i = 0; i < bufferNum; i++)
			{
			    BufferMemoryBindingDesc desc = .(){};
			    desc.memory = memory;
			    desc.buffer = buffers[i];
			    desc.offset = bufferOffsets[i];
			    desc.physicalDeviceMask = WHOLE_DEVICE_GROUP;

			    m_BufferBindingDescs.Add(desc);
			}
		}

		private void FillMemoryBindingDescs(Texture* textures, uint64* textureOffsets, uint32 textureNum, Memory memory)
		{
			for (uint32 i = 0; i < textureNum; i++)
			{
			    TextureMemoryBindingDesc desc = .(){};
			    desc.memory = memory;
			    desc.texture = textures[i];
			    desc.offset = textureOffsets[i];
			    desc.physicalDeviceMask = WHOLE_DEVICE_GROUP;

			    m_TextureBindingDescs.Add(desc);
			}
		}

		///////////////////////////////////////////////////////////////////////////

		public this(Device device, DeviceAllocator allocator)
		{
			m_Device = device;
			m_Allocator = allocator;

			m_Map = Allocate!<Dictionary<MemoryType, MemoryTypeGroup>>(m_Allocator);
			m_DedicatedBuffers = Allocate!<List<Buffer>>(m_Allocator);
			m_DedicatedTextures = Allocate!<List<Texture>>(m_Allocator);
			m_BufferBindingDescs = Allocate!<List<BufferMemoryBindingDesc>>(m_Allocator);
			m_TextureBindingDescs = Allocate!<List<TextureMemoryBindingDesc>>(m_Allocator);
		}

		public ~this()
		{
			Deallocate!(m_Allocator, m_TextureBindingDescs);
			Deallocate!(m_Allocator, m_BufferBindingDescs);
			Deallocate!(m_Allocator, m_DedicatedTextures);
			Deallocate!(m_Allocator, m_DedicatedBuffers);

			for (var entry in ref m_Map)
			{
				entry.valueRef.Dispose();
			}
			Deallocate!(m_Allocator, m_Map);
		}

		public uint32 CalculateAllocationNumber(ResourceGroupDesc resourceGroupDesc)
		{
			for (var entry in ref m_Map)
			{
				entry.valueRef.Dispose();
			}
			m_Map.Clear();
			m_DedicatedBuffers.Clear();
			m_DedicatedTextures.Clear();

			GroupByMemoryType(resourceGroupDesc.memoryLocation, resourceGroupDesc.buffers, resourceGroupDesc.bufferNum);
			GroupByMemoryType(resourceGroupDesc.memoryLocation, resourceGroupDesc.textures, resourceGroupDesc.textureNum);

			return uint32(m_Map.Count) + uint32(m_DedicatedBuffers.Count) + uint32(m_DedicatedTextures.Count);
		}

		public Result AllocateAndBindMemory(ResourceGroupDesc resourceGroupDesc, Memory* allocations)
		{
			for (var entry in ref m_Map)
			{
				entry.valueRef.Dispose();
			}
			m_Map.Clear();
			m_DedicatedBuffers.Clear();
			m_DedicatedTextures.Clear();
			m_BufferBindingDescs.Clear();
			m_TextureBindingDescs.Clear();

			int allocationNum = 0;

			readonly Result result = TryToAllocateAndBindMemory(resourceGroupDesc, allocations, ref allocationNum);

			if (result != Result.SUCCESS)
			{
				for (int i = 0; i < allocationNum; i++)
				{
					m_Device.FreeMemory(allocations[i]);
					allocations[i] = null;
				}
			}

			return result;
		}
	}
}
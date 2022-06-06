using System;
namespace Sedulous.RHI
{
	abstract class Buffer
	{
		public abstract void SetDebugName(in StringView name);
		
		public abstract void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc);
		public abstract void* Map(uint64 offset, uint64 size);
		public abstract void Unmap();
	}
}
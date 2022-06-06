using System;
namespace Sedulous.RHI
{
	abstract class Texture
	{
		public abstract void SetDebugName(in StringView name);
		
		public abstract void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc);
	}
}
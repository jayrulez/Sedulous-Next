using System;
namespace Sedulous.RHI
{
	abstract class CommandAllocator
	{
		public abstract void SetDebugName(in StringView name);
        public abstract Result CreateCommandBuffer(out CommandBuffer commandBuffer);
        public abstract void Reset();
	}
}
using System;
namespace Sedulous.RHI
{
	abstract class CommandPool
	{
		public struct Description
		{
		}
		public abstract CommandQueue Queue {get;}

		public abstract Result<void> CreateCommandBuffer(in CommandBuffer.Description description, out CommandBuffer commandBuffer);
		public abstract void DestroyCommandBuffer(in CommandBuffer commandBuffer);

		public abstract void Reset();
	}
}
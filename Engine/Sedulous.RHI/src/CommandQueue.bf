using System;
namespace Sedulous.RHI
{
	typealias CommandQueueIndex = uint32;
	abstract class CommandQueue
	{
		public struct SubmitDescription
		{
		}

		public struct PresentDescription
		{
		}

		public abstract Device Device {get;}
		public abstract CommandQueueType CommandQueueType {get;}
		public abstract CommandQueueIndex Index {get;}

		public abstract void Submit(in SubmitDescription description);

		public abstract void Present(in PresentDescription description);

		public abstract void WaitIdle();

		public abstract float GetTimestampPeriodNS();

		public abstract Result<void> CreateCommandPool(in CommandPool.Description description, out CommandPool commandPool);
		public abstract void DestroyCommandPool(in CommandPool commandPool);
	}
}
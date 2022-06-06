using System;
namespace Sedulous.RHI
{
	abstract class QueueSemaphore
	{
		public abstract void SetDebugName(in StringView name);
	}
}
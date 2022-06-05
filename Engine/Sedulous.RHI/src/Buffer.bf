using System;
namespace Sedulous.RHI
{
	abstract class Buffer
	{
		public struct Description
		{
		}

		public struct Range
		{
		}

		public abstract Device Device { get; }

		/**
		 * CPU address of the mapped buffer.
		 * Applicable to buffers created in CPU accessible heaps (CPU, CPU_TO_GPU, GPU_TO_CPU)
		 */
		public abstract void* CpuMappedAddress { get; }
		public abstract uint64 Size { get; }
		public abstract uint64 Descriptors { get; }
		public abstract uint64 MemoryUsage { get; }

		public abstract Result<void> Map(in Range range);
		public abstract void Unmap();
	}
}
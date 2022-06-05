using System;
namespace Sedulous.RHI
{
	abstract class SwapChain
	{
		public struct Description
		{
		}
		public abstract Device Device {get;}

		public abstract Span<Texture> BackBuffers {get;}

		public struct AcquireNextDescription
		{
		}

		public abstract uint32 AcquireNextImage(in AcquireNextDescription description);
	}
}
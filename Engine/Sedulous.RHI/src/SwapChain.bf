using System;
namespace Sedulous.RHI
{
	abstract class SwapChain
	{
		public abstract void SetDebugName(StringView name);
		
		public abstract Texture* GetTextures(ref uint32 textureNum, ref Format format);
		public abstract uint32 AcquireNextTexture(ref QueueSemaphore textureReadyForRender);
		public abstract Result Present(ref QueueSemaphore textureReadyForPresent);
		public abstract Result SetHdrMetadata(HdrMetadata hdrMetadata);
	}
}
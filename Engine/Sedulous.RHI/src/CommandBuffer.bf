using System;
namespace Sedulous.RHI
{
	abstract class CommandBuffer
	{
		public struct Description
		{
		}

		public struct QueryDescription
		{
		}

		public struct ResourceBarrierDescription
		{
		}

		public struct BufferToBufferTransferDescription
		{
		}

		public struct TextureToTextureTransferDescription
		{
		}

		public struct BufferToTextureTransferDescription
		{
		}

		public struct ComputePassDescription
		{
		}

		public struct RenderPassDescription
		{
		}

		
		public abstract Device Device {get;}
		
		public abstract CommandPool CommandPool {get;}
		
		public abstract PipelineType CurrentDispatch {get;}

		public abstract void Begin();
		public abstract void End();

		public abstract void TransferBufferToBuffer(in BufferToBufferTransferDescription description);
		public abstract void TransferTextureToTexture(in TextureToTextureTransferDescription description);
		public abstract void TransferBufferToTexture(in BufferToTextureTransferDescription description);
		public abstract void ResourceBarrier(in ResourceBarrierDescription description);
		public abstract void BeginQuery(in QueryPool queryPool, in QueryDescription description);
		public abstract void EndQuery(in QueryPool queryPool, in QueryDescription description);
		public abstract void ResetQueryPool(in QueryPool queryPool, uint32 startQuery, uint32 queryCount);
		public abstract void ResolveQuery(in QueryPool queryPool, in Buffer readback, uint32 startQuery, uint32 queryCount);

		public abstract Result<void> BeginComputePass(in ComputePassDescription description, out ComputePassEncoder encoder);
		public abstract void EndComputePass(in ComputePassEncoder encoder);

		public abstract Result<void> BeginRenderPass(in RenderPassDescription description, out RenderPassEncoder encoder);
		public abstract void EndRenderPass(in RenderPassEncoder encoder);

		public struct EventInfo
		{
			public char8* Name;
			public float[4] Color;
		}

		public struct MarkerInfo
		{
			public char8* Name;
			public float[4] Color;
		}

		public abstract void BeginEvent(in EventInfo info);
		public abstract void SetMarker(in MarkerInfo info);
		public abstract void EndEvent();
	}
}
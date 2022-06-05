namespace Sedulous.RHI
{
	abstract class ComputePassEncoder
	{
		
		public abstract Device Device {get;}

		public abstract void BindDescriptorSet(in DescriptorSet descriptorSet);
		public abstract void BindPipeline(in ComputePipeline pipeline);
		public abstract void PushConstants(in RootSignature rootSignature, char8* name, void* data);
		public abstract void Dispatch(uint32 x, uint32 y, uint32 z);
	}
}
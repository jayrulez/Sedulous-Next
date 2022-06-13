using System;
namespace Sedulous.RHI
{
	abstract class DescriptorPool
	{
		public abstract void SetDebugName(StringView name);

        public abstract Result AllocateDescriptorSets(in PipelineLayout pipelineLayout, uint32 setIndex, DescriptorSet* descriptorSets,
            uint32 numberOfCopies, uint32 physicalDeviceMask, uint32 variableDescriptorNum);

        public abstract void Reset();
	}
}
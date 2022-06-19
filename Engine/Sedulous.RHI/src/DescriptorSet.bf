using System;
namespace Sedulous.RHI
{
	abstract class DescriptorSet
	{
		public abstract void SetDebugName(StringView name);
		
		public abstract void UpdateDescriptorRanges(uint32 physicalDeviceMask, uint32 rangeOffset, uint32 rangeNum, DescriptorRangeUpdateDesc* rangeUpdateDescs);
		public abstract void UpdateDynamicConstantBuffers(uint32 physicalDeviceMask, uint32 bufferOffset, uint32 descriptorNum, Descriptor* descriptors);
		public abstract void Copy(DescriptorSetCopyDesc descriptorSetCopyDesc);
	}
}
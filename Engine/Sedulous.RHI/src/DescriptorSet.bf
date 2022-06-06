using System;
namespace Sedulous.RHI
{
	abstract class DescriptorSet
	{
		public abstract void SetDebugName(in StringView name);
		
		public abstract void UpdateDescriptorRanges(uint32 physicalDeviceMask, uint32 rangeOffset, uint32 rangeNum, in DescriptorRangeUpdateDesc* rangeUpdateDescs);
		public abstract void UpdateDynamicConstantBuffers(uint32 physicalDeviceMask, uint32 bufferOffset, uint32 descriptorNum, in Descriptor* descriptors);
		public abstract void Copy(in DescriptorSetCopyDesc descriptorSetCopyDesc);
	}
}
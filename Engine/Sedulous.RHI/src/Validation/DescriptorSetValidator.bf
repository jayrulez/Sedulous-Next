using System;
using System.Collections;
namespace Sedulous.RHI.Validation
{
	class DescriptorSetValidator : DescriptorSet
	{
		private readonly DeviceValidator mDevice;
		private DescriptorSet mDescriptorSet;
		private readonly DescriptorSetDesc m_DescriptorSetDesc;

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, DescriptorSet descriptorSet, DescriptorSetDesc descriptorSetDesc)
		{
			mDevice = device;
			mDescriptorSet = descriptorSet;

			m_DescriptorSetDesc = descriptorSetDesc;
		}

		public ref DescriptorSet GetImpl() => ref mDescriptorSet;

		public readonly ref DescriptorSetDesc GetDesc() => ref m_DescriptorSetDesc;

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mDescriptorSet.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override void UpdateDescriptorRanges(uint32 physicalDeviceMask, uint32 rangeOffset, uint32 rangeNum, DescriptorRangeUpdateDesc* rangeUpdateDescs)
		{
			if (rangeNum == 0)
				return;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), mDevice.IsPhysicalDeviceMaskValid(physicalDeviceMask), void(),
				"Can't update descriptor ranges: 'physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), rangeUpdateDescs != null, void(),
				"Can't update descriptor ranges: 'rangeUpdateDescs' is invalid.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), rangeOffset < m_DescriptorSetDesc.rangeNum, void(),
				"Can't update descriptor ranges: 'rangeOffset' is out of bounds. (rangeOffset={}, rangeNum={})", rangeOffset, m_DescriptorSetDesc.rangeNum);

			RETURN_ON_FAILURE!(mDevice.GetLogger(), rangeOffset + rangeNum <= m_DescriptorSetDesc.rangeNum, void(),
				"Can't update descriptor ranges: 'rangeOffset' + 'rangeNum' is greater than the number of ranges. (rangeOffset={}, rangeNum={}, rangeNum={})",
				rangeOffset, rangeNum, m_DescriptorSetDesc.rangeNum);

			DescriptorRangeUpdateDesc* rangeUpdateDescsImpl = STACK_ALLOC!<DescriptorRangeUpdateDesc>(rangeNum);
			for (uint32 i = 0; i < rangeNum; i++)
			{
				readonly ref DescriptorRangeUpdateDesc updateDesc = ref rangeUpdateDescs[i];
				readonly ref DescriptorRangeDesc rangeDesc = ref m_DescriptorSetDesc.ranges[rangeOffset + i];

				RETURN_ON_FAILURE!(mDevice.GetLogger(), updateDesc.descriptorNum != 0, void(),
					"Can't update descriptor ranges: 'rangeUpdateDescs[{}].descriptorNum' is zero.", i);

				RETURN_ON_FAILURE!(mDevice.GetLogger(), updateDesc.offsetInRange < rangeDesc.descriptorNum, void(),
					"Can't update descriptor ranges: 'rangeUpdateDescs[{}].offsetInRange' is greater than the number of descriptors. (offsetInRange={}, rangeDescriptorNum={}, descriptorType={})",
					i, updateDesc.offsetInRange, rangeDesc.descriptorNum, GetDescriptorTypeName(rangeDesc.descriptorType));

				RETURN_ON_FAILURE!(mDevice.GetLogger(), updateDesc.offsetInRange + updateDesc.descriptorNum <= rangeDesc.descriptorNum, void(),
					"Can't update descriptor ranges: 'rangeUpdateDescs[{}].offsetInRange' + 'rangeUpdateDescs[{}].descriptorNum' is greater than the number of descriptors. (offsetInRange={}, descriptorNum={}, rangeDescriptorNum={}, descriptorType={})",
					i, i, updateDesc.offsetInRange, updateDesc.descriptorNum, rangeDesc.descriptorNum, GetDescriptorTypeName(rangeDesc.descriptorType));

				RETURN_ON_FAILURE!(mDevice.GetLogger(), updateDesc.descriptors != null, void(),
					"Can't update descriptor ranges: 'rangeUpdateDescs[{}].descriptors' is invalid.", i);

				ref DescriptorRangeUpdateDesc dstDesc = ref rangeUpdateDescsImpl[i];

				dstDesc = updateDesc;
				dstDesc.descriptors = scope:: List<Descriptor>() { Count = updateDesc.descriptorNum }.Ptr; //STACK_ALLOC!<Descriptor>(updateDesc.descriptorNum);
				Descriptor* descriptors = dstDesc.descriptors;

				for (uint32 j = 0; j < updateDesc.descriptorNum; j++)
				{
					RETURN_ON_FAILURE!(mDevice.GetLogger(), updateDesc.descriptors[j] != null, void(),
						"Can't update descriptor ranges: 'rangeUpdateDescs[{}].descriptors[{}]' is invalid.", i, j);

					descriptors[j] = ((DescriptorValidator)updateDesc.descriptors[j]).GetImpl();
				}
			}

			mDescriptorSet.UpdateDescriptorRanges(physicalDeviceMask, rangeOffset, rangeNum, rangeUpdateDescsImpl);
		}

		public override void UpdateDynamicConstantBuffers(uint32 physicalDeviceMask, uint32 baseBuffer, uint32 bufferNum, Descriptor* descriptors)
		{
			if (bufferNum == 0)
				return;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), mDevice.IsPhysicalDeviceMaskValid(physicalDeviceMask), void(),
				"Can't update dynamic constant buffers: 'physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), baseBuffer < m_DescriptorSetDesc.dynamicConstantBufferNum, void(),
				"Can't update dynamic constant buffers: 'baseBuffer' is invalid. (baseBuffer={}, dynamicConstantBufferNum={})",
				baseBuffer, m_DescriptorSetDesc.dynamicConstantBufferNum);

			RETURN_ON_FAILURE!(mDevice.GetLogger(), baseBuffer + bufferNum <= m_DescriptorSetDesc.dynamicConstantBufferNum, void(),
				"Can't update dynamic constant buffers: 'baseBuffer' + 'bufferNum' is greater than the number of buffers. (baseBuffer={}, bufferNum={}, dynamicConstantBufferNum={})",
				baseBuffer, bufferNum, m_DescriptorSetDesc.dynamicConstantBufferNum);

			RETURN_ON_FAILURE!(mDevice.GetLogger(), descriptors != null, void(),
				"Can't update dynamic constant buffers: 'descriptors' is invalid.");

			Descriptor* descriptorsImpl = scope:: List<Descriptor>() { Count = bufferNum }.Ptr; //STACK_ALLOC(Descriptor*, bufferNum);
			for (uint32 i = 0; i < bufferNum; i++)
			{
				RETURN_ON_FAILURE!(mDevice.GetLogger(), descriptors[i] != null, void(),
					"Can't update dynamic constant buffers: 'descriptors[{}]' is invalid.", i);

				descriptorsImpl[i] = ((DescriptorValidator)descriptors[i]).GetImpl();
			}

			mDescriptorSet.UpdateDynamicConstantBuffers(physicalDeviceMask, baseBuffer, bufferNum, descriptorsImpl);
		}

		public override void Copy(DescriptorSetCopyDesc descriptorSetCopyDesc)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), mDevice.IsPhysicalDeviceMaskValid(descriptorSetCopyDesc.physicalDeviceMask), void(),
				"Can't copy descriptor set: 'physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), descriptorSetCopyDesc.srcDescriptorSet != null, void(),
				"Can't copy descriptor set: 'descriptorSetCopyDesc.srcDescriptorSet' is invalid.");

			DescriptorSetValidator srcDescriptorSetVal = (DescriptorSetValidator)descriptorSetCopyDesc.srcDescriptorSet;
			readonly ref DescriptorSetDesc srcDesc = ref srcDescriptorSetVal.GetDesc();

			RETURN_ON_FAILURE!(mDevice.GetLogger(), descriptorSetCopyDesc.baseSrcRange < srcDesc.rangeNum, void(),
				"Can't copy descriptor set: 'descriptorSetCopyDesc.baseSrcRange' is invalid.");

			bool srcRangeValid = descriptorSetCopyDesc.baseSrcRange + descriptorSetCopyDesc.rangeNum < srcDesc.rangeNum;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), srcRangeValid, void(),
				"Can't copy descriptor set: 'descriptorSetCopyDesc.rangeNum' is invalid.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), descriptorSetCopyDesc.baseDstRange < m_DescriptorSetDesc.rangeNum, void(),
				"Can't copy descriptor set: 'descriptorSetCopyDesc.baseDstRange' is invalid.");

			bool dstRangeValid = descriptorSetCopyDesc.baseDstRange + descriptorSetCopyDesc.rangeNum < m_DescriptorSetDesc.rangeNum;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dstRangeValid, void(),
				"Can't copy descriptor set: 'descriptorSetCopyDesc.rangeNum' is invalid.");

			readonly bool srcOffsetValid = descriptorSetCopyDesc.baseSrcDynamicConstantBuffer < srcDesc.dynamicConstantBufferNum;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), srcOffsetValid, void(),
				"Can't copy descriptor set: 'descriptorSetCopyDesc.baseSrcDynamicConstantBuffer' is invalid.");

			srcRangeValid = descriptorSetCopyDesc.baseSrcDynamicConstantBuffer +
				descriptorSetCopyDesc.dynamicConstantBufferNum < srcDesc.dynamicConstantBufferNum;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), srcRangeValid, void(),
				"Can't copy descriptor set: source range of dynamic constant buffers is invalid.");

			readonly bool dstOffsetValid = descriptorSetCopyDesc.baseDstDynamicConstantBuffer < m_DescriptorSetDesc.dynamicConstantBufferNum;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dstOffsetValid, void(),
				"Can't copy descriptor set: 'descriptorSetCopyDesc.baseDstDynamicConstantBuffer' is invalid.");

			dstRangeValid = descriptorSetCopyDesc.baseDstDynamicConstantBuffer +
				descriptorSetCopyDesc.dynamicConstantBufferNum < m_DescriptorSetDesc.dynamicConstantBufferNum;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dstRangeValid, void(),
				"Can't copy descriptor set: destination range of dynamic constant buffers is invalid.");

			var descriptorSetCopyDescImpl = descriptorSetCopyDesc;
			descriptorSetCopyDescImpl.srcDescriptorSet = ((DescriptorSetValidator)descriptorSetCopyDesc.srcDescriptorSet).GetImpl();

			mDescriptorSet.Copy(descriptorSetCopyDescImpl);
		}
	}
}
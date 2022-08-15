using System;
using System.Collections;
namespace Sedulous.RHI.Validation
{
	class PipelineLayoutValidator : PipelineLayout
	{
		private readonly DeviceValidator mDevice;
		private readonly PipelineLayout mPipelineLayout;

		private readonly PipelineLayoutDesc m_PipelineLayoutDesc;
		private List<DescriptorSetDesc> m_DescriptorSets;
		private List<PushConstantDesc> m_PushConstants;
		private List<DescriptorRangeDesc> m_DescriptorRangeDescs;
		private List<StaticSamplerDesc> m_StaticSamplerDescs;
		private List<DynamicConstantBufferDesc> m_DynamicConstantBufferDescs;

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, PipelineLayout pipelineLayout, PipelineLayoutDesc pipelineLayoutDesc)
		{
			mDevice = device;
			mPipelineLayout = pipelineLayout;

			m_DescriptorSets = Allocate!<List<DescriptorSetDesc>>(mDevice.GetDeviceAllocator());
			m_PushConstants = Allocate!<List<PushConstantDesc>>(mDevice.GetDeviceAllocator());
			m_DescriptorRangeDescs = Allocate!<List<DescriptorRangeDesc>>(mDevice.GetDeviceAllocator());
			m_StaticSamplerDescs = Allocate!<List<StaticSamplerDesc>>(mDevice.GetDeviceAllocator());
			m_DynamicConstantBufferDescs = Allocate!<List<DynamicConstantBufferDesc>>(mDevice.GetDeviceAllocator());

			uint32 descriptorRangeDescNum = 0;
			uint32 staticSamplerDescNum = 0;
			uint32 dynamicConstantBufferDescNum = 0;

			for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
			{
				descriptorRangeDescNum += pipelineLayoutDesc.descriptorSets[i].rangeNum;
				staticSamplerDescNum += pipelineLayoutDesc.descriptorSets[i].staticSamplerNum;
				dynamicConstantBufferDescNum += pipelineLayoutDesc.descriptorSets[i].dynamicConstantBufferNum;
			}

			m_DescriptorSets.Insert(0, Span<DescriptorSetDesc>(pipelineLayoutDesc.descriptorSets, pipelineLayoutDesc.descriptorSetNum));

			m_PushConstants.Insert(0, Span<PushConstantDesc>(pipelineLayoutDesc.pushConstants, pipelineLayoutDesc.pushConstantNum));

			m_DescriptorRangeDescs.Reserve(descriptorRangeDescNum);
			m_StaticSamplerDescs.Reserve(staticSamplerDescNum);
			m_DynamicConstantBufferDescs.Reserve(dynamicConstantBufferDescNum);

			for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
			{
				readonly ref DescriptorSetDesc descriptorSetDesc = ref pipelineLayoutDesc.descriptorSets[i];

				m_DescriptorSets[i].ranges = m_DescriptorRangeDescs.Ptr + m_DescriptorRangeDescs.Count;
				m_DescriptorSets[i].staticSamplers = m_StaticSamplerDescs.Ptr + m_StaticSamplerDescs.Count;
				m_DescriptorSets[i].dynamicConstantBuffers = m_DynamicConstantBufferDescs.Ptr + m_DynamicConstantBufferDescs.Count;

				m_DescriptorRangeDescs.AddRange(Span<DescriptorRangeDesc>(descriptorSetDesc.ranges, descriptorSetDesc.rangeNum));

				m_StaticSamplerDescs.AddRange(Span<StaticSamplerDesc>(descriptorSetDesc.staticSamplers, descriptorSetDesc.staticSamplerNum));

				m_DynamicConstantBufferDescs.AddRange(Span<DynamicConstantBufferDesc>(descriptorSetDesc.dynamicConstantBuffers, descriptorSetDesc.dynamicConstantBufferNum));
			}

			m_PipelineLayoutDesc = pipelineLayoutDesc;
			m_PipelineLayoutDesc.descriptorSets = m_DescriptorSets.Ptr;
			m_PipelineLayoutDesc.pushConstants = m_PushConstants.Ptr;
		}

		public ~this()
		{
			Deallocate!(mDevice.GetDeviceAllocator(), m_DescriptorSets);
			Deallocate!(mDevice.GetDeviceAllocator(), m_PushConstants);
			Deallocate!(mDevice.GetDeviceAllocator(), m_DescriptorRangeDescs);
			Deallocate!(mDevice.GetDeviceAllocator(), m_StaticSamplerDescs);
			Deallocate!(mDevice.GetDeviceAllocator(), m_DynamicConstantBufferDescs);
		}

		public readonly ref PipelineLayoutDesc GetPipelineLayoutDesc() => ref m_PipelineLayoutDesc;

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mPipelineLayout.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;
	}
}
using System;
using System.Collections;
namespace Sedulous.RHI.Validation
{
	class DescriptorPoolValidator : DescriptorPool
	{
		private readonly DeviceValidator mDevice;
		private DescriptorPool mDescriptorPool;

		private List<DescriptorSetValidator> m_DescriptorSets;
		DescriptorPoolDesc m_Desc = .();
		uint32 m_DescriptorSetNum = 0;
		uint32 m_SamplerNum = 0;
		uint32 m_StaticSamplerNum = 0;
		uint32 m_ConstantBufferNum = 0;
		uint32 m_DynamicConstantBufferNum = 0;
		uint32 m_TextureNum = 0;
		uint32 m_StorageTextureNum = 0;
		uint32 m_BufferNum = 0;
		uint32 m_StorageBufferNum = 0;
		uint32 m_StructuredBufferNum = 0;
		uint32 m_StorageStructuredBufferNum = 0;
		uint32 m_AccelerationStructureNum = 0;
		bool m_SkipValidation = false;

		private readonly String mDebugName = new .() ~ delete _;

		private bool CheckDescriptorRange(DescriptorRangeDesc rangeDesc, uint32 variableDescriptorNum)
		{
			readonly uint32 descriptorNum = rangeDesc.isDescriptorNumVariable ? variableDescriptorNum : rangeDesc.descriptorNum;

			if (descriptorNum > rangeDesc.descriptorNum)
			{
				REPORT_ERROR(mDevice.GetLogger(), "variableDescriptorNum ({}) is greater than DescriptorRangeDesc.descriptorNum ({}).",
					variableDescriptorNum, rangeDesc.descriptorNum);

				return false;
			}

			switch (rangeDesc.descriptorType)
			{
			case DescriptorType.SAMPLER:
				return m_SamplerNum + descriptorNum <= m_Desc.samplerMaxNum;
			case DescriptorType.CONSTANT_BUFFER:
				return m_ConstantBufferNum + descriptorNum <= m_Desc.constantBufferMaxNum;
			case DescriptorType.TEXTURE:
				return m_TextureNum + descriptorNum <= m_Desc.textureMaxNum;
			case DescriptorType.STORAGE_TEXTURE:
				return m_StorageTextureNum + descriptorNum <= m_Desc.storageTextureMaxNum;
			case DescriptorType.BUFFER:
				return m_BufferNum + descriptorNum <= m_Desc.bufferMaxNum;
			case DescriptorType.STORAGE_BUFFER:
				return m_StorageBufferNum + descriptorNum <= m_Desc.storageBufferMaxNum;
			case DescriptorType.STRUCTURED_BUFFER:
				return m_StructuredBufferNum + descriptorNum <= m_Desc.structuredBufferMaxNum;
			case DescriptorType.STORAGE_STRUCTURED_BUFFER:
				return m_StorageStructuredBufferNum + descriptorNum <= m_Desc.storageStructuredBufferMaxNum;
			case DescriptorType.ACCELERATION_STRUCTURE:
				return m_AccelerationStructureNum + descriptorNum <= m_Desc.accelerationStructureMaxNum;
			default:
				REPORT_ERROR(mDevice.GetLogger(), "Unknown descriptor range type: {}", (uint32)rangeDesc.descriptorType);
				return false;
			}
		}

		private void IncrementDescriptorNum(DescriptorRangeDesc rangeDesc, uint32 variableDescriptorNum)
		{
			readonly uint32 descriptorNum = rangeDesc.isDescriptorNumVariable ? variableDescriptorNum : rangeDesc.descriptorNum;

			switch (rangeDesc.descriptorType)
			{
			case DescriptorType.SAMPLER:
				m_SamplerNum += descriptorNum;
				return;
			case DescriptorType.CONSTANT_BUFFER:
				m_ConstantBufferNum += descriptorNum;
				return;
			case DescriptorType.TEXTURE:
				m_TextureNum += descriptorNum;
				return;
			case DescriptorType.STORAGE_TEXTURE:
				m_StorageTextureNum += descriptorNum;
				return;
			case DescriptorType.BUFFER:
				m_BufferNum += descriptorNum;
				return;
			case DescriptorType.STORAGE_BUFFER:
				m_StorageBufferNum += descriptorNum;
				return;
			case DescriptorType.STRUCTURED_BUFFER:
				m_StructuredBufferNum += descriptorNum;
				return;
			case DescriptorType.STORAGE_STRUCTURED_BUFFER:
				m_StorageStructuredBufferNum += descriptorNum;
				return;
			case DescriptorType.ACCELERATION_STRUCTURE:
				m_AccelerationStructureNum += descriptorNum;
				return;
			default:
				REPORT_ERROR(mDevice.GetLogger(), "Unknown descriptor range type: {}", (uint32)rangeDesc.descriptorType);
				return;
			}
		}

		public this(DeviceValidator device, DescriptorPool descriptorPool)
		{
			mDevice = device;
			mDescriptorPool = descriptorPool;
			m_SkipValidation = true;

			m_DescriptorSets = Allocate!<List<DescriptorSetValidator>>(mDevice.GetDeviceAllocator());
		}

		public this(DeviceValidator device, DescriptorPool descriptorPool, DescriptorPoolDesc descriptorPoolDesc)
		{
			mDevice = device;
			mDescriptorPool = descriptorPool;

			m_Desc = descriptorPoolDesc;

			m_DescriptorSets = Allocate!<List<DescriptorSetValidator>>(mDevice.GetDeviceAllocator());
		}

		public ~this()
		{
			for (int i = 0; i < m_DescriptorSets.Count; i++)
				Deallocate!(mDevice.GetDeviceAllocator(), m_DescriptorSets[i]);

			Deallocate!(mDevice.GetDeviceAllocator(), m_DescriptorSets);
		}

		public ref DescriptorPool GetImpl() => ref mDescriptorPool;

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mDescriptorPool.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override Result AllocateDescriptorSets(PipelineLayout pipelineLayout, uint32 setIndex, DescriptorSet* descriptorSets, uint32 instanceNum, uint32 physicalDeviceMask, uint32 variableDescriptorNum)
		{
			readonly PipelineLayoutValidator pipelineLayoutVal = (PipelineLayoutValidator)pipelineLayout;
			readonly ref PipelineLayoutDesc pipelineLayoutDesc = ref pipelineLayoutVal.GetPipelineLayoutDesc();

			if (!m_SkipValidation)
			{
				RETURN_ON_FAILURE!(mDevice.GetLogger(), instanceNum != 0, Result.INVALID_ARGUMENT,
					"Can't allocate DescriptorSet: 'instanceNum' is 0.");

				RETURN_ON_FAILURE!(mDevice.GetLogger(), mDevice.IsPhysicalDeviceMaskValid(physicalDeviceMask), Result.INVALID_ARGUMENT,
					"Can't create DescriptorSet: 'physicalDeviceMask' is invalid.");

				RETURN_ON_FAILURE!(mDevice.GetLogger(), m_DescriptorSetNum + instanceNum <= m_Desc.descriptorSetMaxNum, Result.INVALID_ARGUMENT,
					"Can't allocate DescriptorSet: the maximum number of descriptor sets exceeded.");

				RETURN_ON_FAILURE!(mDevice.GetLogger(), setIndex < pipelineLayoutDesc.descriptorSetNum, Result.INVALID_ARGUMENT,
					"Can't allocate DescriptorSet: 'setIndex' is invalid.");

				readonly ref DescriptorSetDesc descriptorSetDesc = ref pipelineLayoutDesc.descriptorSets[setIndex];

				for (uint32 i = 0; i < descriptorSetDesc.rangeNum; i++)
				{
					readonly ref DescriptorRangeDesc rangeDesc = ref descriptorSetDesc.ranges[i];
					bool enoughDescriptors = CheckDescriptorRange(rangeDesc, variableDescriptorNum);

					RETURN_ON_FAILURE!(mDevice.GetLogger(), enoughDescriptors, Result.INVALID_ARGUMENT,
						"Can't allocate DescriptorSet: the maximum number of descriptors exceeded ('%s').", GetDescriptorTypeName(rangeDesc.descriptorType));
				}

				bool enoughDescriptors = m_DynamicConstantBufferNum + descriptorSetDesc.dynamicConstantBufferNum <= m_Desc.dynamicConstantBufferMaxNum;

				RETURN_ON_FAILURE!(mDevice.GetLogger(), enoughDescriptors, Result.INVALID_ARGUMENT,
					"Can't allocate DescriptorSet: the maximum number of descriptors exceeded ('DYNAMIC_CONSTANT_BUFFER').");

				enoughDescriptors = m_StaticSamplerNum + descriptorSetDesc.staticSamplerNum <= m_Desc.staticSamplerMaxNum;

				RETURN_ON_FAILURE!(mDevice.GetLogger(), enoughDescriptors, Result.INVALID_ARGUMENT,
					"Can't allocate DescriptorSet: the maximum number of descriptors exceeded ('STATIC_SAMPLER').");
			}

			PipelineLayout pipelineLayoutImpl = ((PipelineLayoutValidator)pipelineLayout).GetImpl();

			Result result = mDescriptorPool.AllocateDescriptorSets(pipelineLayoutImpl, setIndex, descriptorSets, instanceNum,
				physicalDeviceMask, variableDescriptorNum);

			if (result != Result.SUCCESS)
				return result;

			readonly ref DescriptorSetDesc descriptorSetDesc = ref pipelineLayoutDesc.descriptorSets[setIndex];

			if (!m_SkipValidation)
			{
				m_DescriptorSetNum += instanceNum;
				m_DynamicConstantBufferNum += descriptorSetDesc.dynamicConstantBufferNum;
				m_StaticSamplerNum += descriptorSetDesc.staticSamplerNum;
				for (uint32 i = 0; i < descriptorSetDesc.rangeNum; i++)
					IncrementDescriptorNum(descriptorSetDesc.ranges[i], variableDescriptorNum);
			}

			for (uint32 i = 0; i < instanceNum; i++)
			{
				DescriptorSetValidator descriptorSetVal = Allocate!<DescriptorSetValidator>(mDevice.GetDeviceAllocator(), mDevice, descriptorSets[i], descriptorSetDesc);
				descriptorSets[i] = descriptorSetVal;
				m_DescriptorSets.Add(descriptorSetVal);
			}

			return result;
		}

		public override void Reset()
		{
			for (uint32 i = 0; i < m_DescriptorSets.Count; i++)
				Deallocate!(mDevice.GetDeviceAllocator(), m_DescriptorSets[i]);
			m_DescriptorSets.Clear();

			m_DescriptorSetNum = 0;
			m_SamplerNum = 0;
			m_StaticSamplerNum = 0;
			m_ConstantBufferNum = 0;
			m_DynamicConstantBufferNum = 0;
			m_TextureNum = 0;
			m_StorageTextureNum = 0;
			m_BufferNum = 0;
			m_StorageBufferNum = 0;
			m_StructuredBufferNum = 0;
			m_StorageStructuredBufferNum = 0;
			m_AccelerationStructureNum = 0;

			mDescriptorPool.Reset();
		}
	}
}
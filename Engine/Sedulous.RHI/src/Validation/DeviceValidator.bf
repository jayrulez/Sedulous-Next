using Sedulous.Foundation.Logging.Abstractions;
using System;
using System.Collections;
using System.Threading;
namespace Sedulous.RHI.Validation
{
	public static
	{
		public static Result CreateDeviceValidation(DeviceCreationDesc deviceCreationDesc, Device device, DeviceAllocator allocator, ILogger logger, out Device validationDevice)
		{
			uint32 physicalDeviceNum = 1;
			if (deviceCreationDesc.physicalDeviceGroup != null)
				physicalDeviceNum = deviceCreationDesc.physicalDeviceGroup.physicalDeviceGroupSize;

			validationDevice = Allocate!<DeviceValidator>(allocator, device, logger, allocator, physicalDeviceNum);

			return .SUCCESS;
		}
	}

	class DeviceValidator : Device
	{
		private Device mDevice;
		private uint32 m_PhysicalDeviceNum = 0;
		private uint32 m_PhysicalDeviceMask = 0;
		private CommandQueueValidator[COMMAND_QUEUE_TYPE_NUM] m_CommandQueues = .();
		private Dictionary<MemoryType, MemoryLocation> m_MemoryTypeMap;
		private Monitor m_Monitor;

		private readonly String mDebugName = new .() ~ delete _;

		public this(Device device, ILogger logger, DeviceAllocator allocator, uint32 physicalDeviceNum) : base(logger, allocator)
		{
			mDevice = device;
			m_PhysicalDeviceNum = physicalDeviceNum;
			m_PhysicalDeviceMask = (1 << (physicalDeviceNum + 1)) - 1;

			m_MemoryTypeMap = Allocate!<Dictionary<MemoryType, MemoryLocation>>(mDevice.GetDeviceAllocator());
		}

		public ~this()
		{
			for (int i = 0; i < m_CommandQueues.Count; i++)
			{
				if (m_CommandQueues[i] != null)
					Deallocate!(GetDeviceAllocator(), m_CommandQueues[i]);
			}

			Deallocate!(mDevice.GetDeviceAllocator(), mDevice);
		}

		public void RegisterMemoryType(MemoryType memoryType, MemoryLocation memoryLocation)
		{
			using (m_Monitor.Enter())
				m_MemoryTypeMap[memoryType] = memoryLocation;
		}

		public override void SetDebugName(StringView name)
		{
			mDebugName.Set(name);
			mDevice.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override ref DeviceDesc GetDesc()
		{
			return ref mDevice.GetDesc();
		}

		public override Result GetCommandQueue(CommandQueueType commandQueueType, out CommandQueue commandQueue)
		{
			commandQueue = ?;
			RETURN_ON_FAILURE!(mDevice.GetLogger(), commandQueueType < CommandQueueType.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't get CommandQueue: 'commandQueueType' is invalid.");

			CommandQueue commandQueueImpl;
			readonly Result result = mDevice.GetCommandQueue(commandQueueType, out commandQueueImpl);

			if (result == Result.SUCCESS)
			{
				readonly uint32 index = (uint32)commandQueueType;
				if (m_CommandQueues[index] == null)
					m_CommandQueues[index] = Allocate!<CommandQueueValidator>(mDevice.GetDeviceAllocator(), this, commandQueueImpl);

				commandQueue = (CommandQueue)m_CommandQueues[index];
			}

			return result;
		}

		public override Result CreateCommandAllocator(CommandQueue commandQueue, uint32 physicalDeviceMask, out CommandAllocator commandAllocator)
		{
			commandAllocator = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create CommandAllocator: 'physicalDeviceMask' is invalid.");

			CommandAllocator commandAllocatorImpl = null;
			readonly Result result = mDevice.CreateCommandAllocator(commandQueue, physicalDeviceMask, out commandAllocatorImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), commandAllocatorImpl != null, Result.FAILURE, "Unexpected error: 'commandAllocatorImpl' is NULL.");
				commandAllocator = (CommandAllocator)Allocate!<CommandAllocatorValidator>(GetDeviceAllocator(), this, commandAllocatorImpl);
			}

			return result;
		}

		public override Result CreateDescriptorPool(DescriptorPoolDesc descriptorPoolDesc, out DescriptorPool descriptorPool)
		{
			descriptorPool = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(descriptorPoolDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create DescriptorPool: 'descriptorPoolDesc.physicalDeviceMask' is invalid.");

			DescriptorPool descriptorPoolImpl = null;
			readonly Result result = mDevice.CreateDescriptorPool(descriptorPoolDesc, out descriptorPoolImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), descriptorPoolImpl != null, Result.FAILURE, "Unexpected error: 'descriptorPoolImpl' is NULL.");
				descriptorPool = (DescriptorPool)Allocate!<DescriptorPoolValidator>(GetDeviceAllocator(), this, descriptorPoolImpl, descriptorPoolDesc);
			}

			return result;
		}

		public override Result CreateBuffer(BufferDesc bufferDesc, out Buffer buffer)
		{
			buffer = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(bufferDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create Buffer: 'bufferDesc.physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), bufferDesc.size > 0, Result.INVALID_ARGUMENT,
				"Can't create Buffer: 'bufferDesc.size' is 0.");

			Buffer bufferImpl = null;
			readonly Result result = mDevice.CreateBuffer(bufferDesc, out bufferImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), bufferImpl != null, Result.FAILURE, "Unexpected error: 'bufferImpl' is NULL.");
				buffer = (Buffer)Allocate!<BufferValidator>(GetDeviceAllocator(), this, bufferImpl, bufferDesc);
			}

			return result;
		}

		public override Result CreateTexture(TextureDesc textureDesc, out Texture texture)
		{
			texture = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(textureDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create Texture: 'textureDesc.physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureDesc.format > Format.UNKNOWN && textureDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Texture: 'textureDesc.format' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureDesc.sampleNum > 0, Result.INVALID_ARGUMENT,
				"Can't create Texture: 'textureDesc.sampleNum' is invalid.");

			Texture textureImpl = null;
			readonly Result result = mDevice.CreateTexture(textureDesc, out textureImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), textureImpl != null, Result.FAILURE, "Unexpected error: 'textureImpl' is NULL.");
				texture = (Texture)Allocate!<TextureValidator>(GetDeviceAllocator(), this, textureImpl, textureDesc);
			}

			return result;
		}

		public override Result CreateBufferView(BufferViewDesc bufferViewDesc, out Descriptor bufferView)
		{
			bufferView = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(bufferViewDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'bufferViewDesc.physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.buffer != null, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'bufferViewDesc.buffer' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'bufferViewDesc.format' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.viewType < BufferViewType.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'bufferViewDesc.viewType' is invalid");

			readonly ref BufferDesc bufferDesc = ref ((BufferValidator)bufferViewDesc.buffer).GetDesc();

			RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.offset < bufferDesc.size, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'bufferViewDesc.offset' is invalid. (bufferViewDesc.offset=%llu, bufferDesc.size=%llu)",
				bufferViewDesc.offset, bufferDesc.size);

			RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.offset + bufferViewDesc.size <= bufferDesc.size, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'bufferViewDesc.size' is invalid. (bufferViewDesc.offset=%llu, bufferViewDesc.size=%llu, bufferDesc.size=%llu)",
				bufferViewDesc.offset, bufferViewDesc.size, bufferDesc.size);

			var bufferViewDescImpl = bufferViewDesc;
			bufferViewDescImpl.buffer = bufferViewDesc.buffer;

			Descriptor descriptorImpl = null;
			readonly Result result = mDevice.CreateBufferView(bufferViewDescImpl, out descriptorImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is NULL.");
				bufferView = (Descriptor)Allocate!<DescriptorValidator>(GetDeviceAllocator(), this, descriptorImpl, bufferViewDesc);
			}

			return result;
		}

		public override Result CreateTexture1DView(Texture1DViewDesc textureViewDesc, out Descriptor textureView)
		{
			textureView = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(textureViewDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.texture != null, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.texture' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.format > Format.UNKNOWN && textureViewDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.format' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.viewType < Texture1DViewType.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.viewType' is invalid.");

			readonly ref TextureDesc textureDesc = ref ((TextureValidator)textureViewDesc.texture).GetDesc();

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset < textureDesc.mipNum, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.mipOffset' is invalid. (textureViewDesc.mipOffset={}, textureDesc.mipNum={})",
				textureViewDesc.mipOffset, textureDesc.mipNum);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset + textureViewDesc.mipNum <= textureDesc.mipNum, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.mipNum' is invalid. (textureViewDesc.mipOffset={}, textureViewDesc.mipNum={}, textureDesc.mipNum={})",
				textureViewDesc.mipOffset, textureViewDesc.mipNum, textureDesc.mipNum);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.arrayOffset < textureDesc.arraySize, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.arrayOffset' is invalid. (textureViewDesc.arrayOffset={}, textureDesc.arraySize={})",
				textureViewDesc.arrayOffset, textureDesc.arraySize);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.arrayOffset + textureViewDesc.arraySize <= textureDesc.arraySize, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.arraySize' is invalid. (textureViewDesc.arrayOffset={}, textureViewDesc.arraySize={}, textureDesc.arraySize={})",
				textureViewDesc.arrayOffset, textureViewDesc.arraySize, textureDesc.arraySize);

			var textureViewDescImpl = textureViewDesc;
			textureViewDescImpl.texture = textureViewDesc.texture;

			Descriptor descriptorImpl = null;
			readonly Result result = mDevice.CreateTexture1DView(textureViewDescImpl, out descriptorImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is NULL.");
				textureView = (Descriptor)Allocate!<DescriptorValidator>(GetDeviceAllocator(), this, descriptorImpl, textureViewDesc);
			}

			return result;
		}

		public override Result CreateTexture2DView(Texture2DViewDesc textureViewDesc, out Descriptor textureView)
		{
			textureView = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(textureViewDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.texture != null, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.texture' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.format > Format.UNKNOWN && textureViewDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.format' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.viewType < Texture2DViewType.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.viewType' is invalid.");

			readonly ref TextureDesc textureDesc = ref ((TextureValidator)textureViewDesc.texture).GetDesc();

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset < textureDesc.mipNum, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.mipOffset' is invalid. (textureViewDesc.mipOffset={}, textureDesc.mipNum={})",
				textureViewDesc.mipOffset, textureDesc.mipNum);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset + textureViewDesc.mipNum <= textureDesc.mipNum, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.mipNum' is invalid. (textureViewDesc.mipOffset={}, textureViewDesc.mipNum={}, textureDesc.mipNum={})",
				textureViewDesc.mipOffset, textureViewDesc.mipNum, textureDesc.mipNum);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.arrayOffset < textureDesc.arraySize, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.arrayOffset' is invalid. (textureViewDesc.arrayOffset={}, textureDesc.arraySize={})",
				textureViewDesc.arrayOffset, textureDesc.arraySize);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.arrayOffset + textureViewDesc.arraySize <= textureDesc.arraySize, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.arraySize' is invalid. (textureViewDesc.arrayOffset={}, textureViewDesc.arraySize={}, textureDesc.arraySize={})",
				textureViewDesc.arrayOffset, textureViewDesc.arraySize, textureDesc.arraySize);

			var textureViewDescImpl = textureViewDesc;
			textureViewDescImpl.texture = textureViewDesc.texture;

			Descriptor descriptorImpl = null;
			readonly Result result = mDevice.CreateTexture2DView(textureViewDescImpl, out descriptorImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is NULL.");
				textureView = (Descriptor)Allocate!<DescriptorValidator>(GetDeviceAllocator(), this, descriptorImpl, textureViewDesc);
			}

			return result;
		}

		public override Result CreateTexture3DView(Texture3DViewDesc textureViewDesc, out Descriptor textureView)
		{
			textureView = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(textureViewDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.texture != null, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.texture' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.format > Format.UNKNOWN && textureViewDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.format' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.viewType < Texture3DViewType.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.viewType' is invalid.");

			readonly ref TextureDesc textureDesc = ref ((TextureValidator)textureViewDesc.texture).GetDesc();

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset < textureDesc.mipNum, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.mipOffset' is invalid. (textureViewDesc.mipOffset={}, textureViewDesc.mipOffset={})",
				textureViewDesc.mipOffset, textureDesc.mipNum);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset + textureViewDesc.mipNum <= textureDesc.mipNum, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.mipNum' is invalid. (textureViewDesc.mipOffset={}, textureViewDesc.mipNum={}, textureDesc.mipNum={})",
				textureViewDesc.mipOffset, textureViewDesc.mipNum, textureDesc.mipNum);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.sliceOffset < textureDesc.size[2], Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.arrayOffset' is invalid. (textureViewDesc.sliceOffset={}, textureDesc.size[2]={})",
				textureViewDesc.sliceOffset, textureDesc.size[2]);

			RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.sliceOffset + textureViewDesc.sliceNum <= textureDesc.size[2], Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'textureViewDesc.arraySize' is invalid. (textureViewDesc.sliceOffset={}, textureViewDesc.sliceNum={}, textureDesc.size[2]={})",
				textureViewDesc.sliceOffset, textureViewDesc.sliceNum, textureDesc.size[2]);

			var textureViewDescImpl = textureViewDesc;
			textureViewDescImpl.texture = textureViewDesc.texture;

			Descriptor descriptorImpl = null;
			readonly Result result = mDevice.CreateTexture3DView(textureViewDescImpl, out descriptorImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is NULL.");
				textureView = (Descriptor)Allocate!<DescriptorValidator>(GetDeviceAllocator(), this, descriptorImpl, textureViewDesc);
			}

			return result;
		}

		public override Result CreateSampler(SamplerDesc samplerDesc, out Descriptor sampler)
		{
			sampler = ?;

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.magnification < Filter.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.magnification' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.minification < Filter.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.magnification' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.mip < Filter.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.mip' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.filterExt < FilterExt.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.filterExt' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.addressModes.u < AddressMode.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.addressModes.u' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.addressModes.v < AddressMode.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.addressModes.v' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.addressModes.w < AddressMode.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.addressModes.w' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.compareFunc < CompareFunc.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.compareFunc' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), samplerDesc.borderColor < BorderColor.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Descriptor: 'samplerDesc.borderColor' is invalid.");

			Descriptor samplerImpl = null;
			readonly Result result = mDevice.CreateSampler(samplerDesc, out samplerImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), samplerImpl != null, Result.FAILURE, "Unexpected error: 'samplerImpl' is NULL.");
				sampler = (Descriptor)Allocate!<DescriptorValidator>(GetDeviceAllocator(), this, samplerImpl);
			}

			return result;
		}

		public override Result CreatePipelineLayout(PipelineLayoutDesc pipelineLayoutDesc, out PipelineLayout pipelineLayout)
		{
			pipelineLayout = ?;

			readonly bool isGraphics = pipelineLayoutDesc.stageMask & PipelineLayoutShaderStageBits.ALL_GRAPHICS != 0;
			readonly bool isCompute = pipelineLayoutDesc.stageMask & PipelineLayoutShaderStageBits.COMPUTE != 0;
			readonly bool isRayTracing = pipelineLayoutDesc.stageMask & PipelineLayoutShaderStageBits.ALL_RAY_TRACING != 0;
			readonly uint32 supportedTypes = (uint32)(isGraphics ? 1 : 0) + (uint32)(isCompute ? 1 : 0) + (uint32)(isRayTracing ? 1 : 0);

			RETURN_ON_FAILURE!(GetLogger(), supportedTypes > 0, Result.INVALID_ARGUMENT,
				"Can't create pipeline layout: 'pipelineLayoutDesc.stageMask' is 0.");
			RETURN_ON_FAILURE!(GetLogger(), supportedTypes == 1, Result.INVALID_ARGUMENT,
				"Can't create pipeline layout: 'pipelineLayoutDesc.stageMask' is invalid, it can't be compatible with more than one type of pipeline.");

			for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
			{
				readonly ref DescriptorSetDesc descriptorSetDesc = ref pipelineLayoutDesc.descriptorSets[i];

				for (uint32 j = 0; j < descriptorSetDesc.rangeNum; j++)
				{
					readonly ref DescriptorRangeDesc range = ref descriptorSetDesc.ranges[j];

					RETURN_ON_FAILURE!(GetLogger(), !range.isDescriptorNumVariable || range.isArray, Result.INVALID_ARGUMENT,
						"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}]' is invalid, 'isArray' can't be false if 'isDescriptorNumVariable' is true.",
						i, j);

					RETURN_ON_FAILURE!(GetLogger(), range.descriptorNum > 0, Result.INVALID_ARGUMENT,
						"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}].descriptorNum' can't be 0.",
						i, j);

					RETURN_ON_FAILURE!(GetLogger(), range.visibility < ShaderStage.MAX_NUM, Result.INVALID_ARGUMENT,
						"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}].visibility' is invalid.",
						i, j);

					RETURN_ON_FAILURE!(GetLogger(), range.descriptorType < DescriptorType.MAX_NUM, Result.INVALID_ARGUMENT,
						"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}].descriptorType' is invalid.",
						i, j);

					if (range.visibility != ShaderStage.ALL)
					{
						readonly PipelineLayoutShaderStageBits visibilityMask = (PipelineLayoutShaderStageBits)(1 << (uint32)range.visibility);
						readonly uint32 filteredVisibilityMask = (.)(visibilityMask & pipelineLayoutDesc.stageMask);

						RETURN_ON_FAILURE!(GetLogger(), (uint32)visibilityMask == filteredVisibilityMask, Result.INVALID_ARGUMENT,
							"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}].visibility' is not compatible with 'pipelineLayoutDesc.stageMask'.", i, j);
					}
				}
			}

			PipelineLayout pipelineLayoutImpl = null;
			readonly Result result = mDevice.CreatePipelineLayout(pipelineLayoutDesc, out pipelineLayoutImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), pipelineLayoutImpl != null, Result.FAILURE, "Unexpected error: 'pipelineLayoutImpl' is NULL.");
				pipelineLayout = (PipelineLayout)Allocate!<PipelineLayoutValidator>(GetDeviceAllocator(), this, pipelineLayoutImpl, pipelineLayoutDesc);
			}

			return result;
		}

		public override Result CreateGraphicsPipeline(GraphicsPipelineDesc graphicsPipelineDesc, out Pipeline pipeline)
		{
			pipeline = ?;

			RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.pipelineLayout != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'graphicsPipelineDesc.pipelineLayout' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.outputMerger != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'graphicsPipelineDesc.outputMerger' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.rasterization != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'graphicsPipelineDesc.rasterization' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.shaderStages != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'graphicsPipelineDesc.shaderStages' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.shaderStageNum > 0, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'graphicsPipelineDesc.shaderStageNum' is 0.");

			/*readonly*/ ShaderDesc* vertexShader = null;
			for (uint32 i = 0; i < graphicsPipelineDesc.shaderStageNum; i++)
			{
				readonly ShaderDesc* shaderDesc = graphicsPipelineDesc.shaderStages + i;

				if (shaderDesc.stage == ShaderStage.VERTEX)
					vertexShader = shaderDesc;

				RETURN_ON_FAILURE!(GetLogger(), shaderDesc.bytecode != null, Result.INVALID_ARGUMENT,
					"Can't create Pipeline: 'graphicsPipelineDesc.shaderStages[{}].bytecode' is invalid.", i);

				RETURN_ON_FAILURE!(GetLogger(), shaderDesc.size != 0, Result.INVALID_ARGUMENT,
					"Can't create Pipeline: 'graphicsPipelineDesc.shaderStages[{}].size' is 0.", i);

				RETURN_ON_FAILURE!(GetLogger(), shaderDesc.stage > ShaderStage.ALL && shaderDesc.stage < ShaderStage.COMPUTE, Result.INVALID_ARGUMENT,
					"Can't create Pipeline: 'graphicsPipelineDesc.shaderStages[{}].stage' is invalid.", i);
			}

			if (graphicsPipelineDesc.inputAssembly != null)
			{
				RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.inputAssembly.attributes == null || vertexShader != null, Result.INVALID_ARGUMENT,
					"Can't create Pipeline: vertex shader is not specified, but input assembly attributes provided.");

				readonly PipelineLayoutValidator pipelineLayout = (PipelineLayoutValidator)graphicsPipelineDesc.pipelineLayout;
				readonly PipelineLayoutShaderStageBits stageMask = pipelineLayout.GetPipelineLayoutDesc().stageMask;

				RETURN_ON_FAILURE!(GetLogger(), (stageMask & PipelineLayoutShaderStageBits.VERTEX) != 0, Result.INVALID_ARGUMENT,
					"Can't create Pipeline: vertex stage is not enabled in the pipeline layout.");
			}

			var graphicsPipelineDescImpl = graphicsPipelineDesc;
			graphicsPipelineDescImpl.pipelineLayout = graphicsPipelineDesc.pipelineLayout;

			Pipeline pipelineImpl = null;
			readonly Result result = mDevice.CreateGraphicsPipeline(graphicsPipelineDescImpl, out pipelineImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), pipelineImpl != null, Result.FAILURE, "Unexpected error: 'pipelineImpl' is NULL.");
				pipeline = (Pipeline)Allocate!<PipelineValidator>(GetDeviceAllocator(), this, pipelineImpl, graphicsPipelineDesc);
			}

			return result;
		}

		public override Result CreateComputePipeline(ComputePipelineDesc computePipelineDesc, out Pipeline pipeline)
		{
			pipeline = ?;

			RETURN_ON_FAILURE!(GetLogger(), computePipelineDesc.pipelineLayout != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'computePipelineDesc.pipelineLayout' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), computePipelineDesc.computeShader.bytecode != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'computePipelineDesc.computeShader.bytecode' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), computePipelineDesc.computeShader.size != 0, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'computePipelineDesc.computeShader.size' is 0.");

			RETURN_ON_FAILURE!(GetLogger(), computePipelineDesc.computeShader.stage == ShaderStage.COMPUTE, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'computePipelineDesc.computeShader.stage' must be ShaderStage.COMPUTE.");

			var computePipelineDescImpl = computePipelineDesc;
			computePipelineDescImpl.pipelineLayout = computePipelineDesc.pipelineLayout;

			Pipeline pipelineImpl = null;
			readonly Result result = mDevice.CreateComputePipeline(computePipelineDescImpl, out pipelineImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), pipelineImpl != null, Result.FAILURE, "Unexpected error: 'pipelineImpl' is NULL.");
				pipeline = (Pipeline)Allocate!<PipelineValidator>(GetDeviceAllocator(), this, pipelineImpl, computePipelineDesc);
			}

			return result;
		}

		public override Result CreateFrameBuffer(FrameBufferDesc frameBufferDesc, out FrameBuffer frameBuffer)
		{
			frameBuffer = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(frameBufferDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create FrameBuffer: 'frameBufferDesc.physicalDeviceMask' is invalid.");

			if (frameBufferDesc.colorAttachmentNum > 0)
			{
				RETURN_ON_FAILURE!(GetLogger(), frameBufferDesc.colorAttachments != null, Result.INVALID_ARGUMENT,
					"Can't create FrameBuffer: 'frameBufferDesc.colorAttachments' is invalid.");

				for (uint32 i = 0; i < frameBufferDesc.colorAttachmentNum; i++)
				{
					DescriptorValidator descriptorVal = (DescriptorValidator)frameBufferDesc.colorAttachments[i];

					RETURN_ON_FAILURE!(GetLogger(), descriptorVal.IsColorAttachment(), Result.INVALID_ARGUMENT,
						"Can't create FrameBuffer: 'frameBufferDesc.colorAttachments[{}]' is not a color attachment descriptor.", i);
				}
			}

			if (frameBufferDesc.depthStencilAttachment != null)
			{
				DescriptorValidator descriptorVal = (DescriptorValidator)frameBufferDesc.depthStencilAttachment;
				RETURN_ON_FAILURE!(GetLogger(), descriptorVal.IsDepthStencilAttachment(), Result.INVALID_ARGUMENT,
					"Can't create FrameBuffer: 'frameBufferDesc.depthStencilAttachment' is not a depth stencil attachment descriptor.");
			}

			var frameBufferDescImpl = frameBufferDesc;
			if (frameBufferDesc.depthStencilAttachment != null)
				frameBufferDescImpl.depthStencilAttachment = frameBufferDesc.depthStencilAttachment;
			if (frameBufferDesc.colorAttachmentNum > 0)
			{
				frameBufferDescImpl.colorAttachments = scope:: List<Descriptor>() { Count = frameBufferDesc.colorAttachmentNum }.Ptr; //STACK_ALLOC(Descriptor*, frameBufferDesc.colorAttachmentNum);
				for (uint32 i = 0; i < frameBufferDesc.colorAttachmentNum; i++)
					((Descriptor*)frameBufferDescImpl.colorAttachments)[i] = frameBufferDesc.colorAttachments[i];
			}

			FrameBuffer frameBufferImpl = null;
			readonly Result result = mDevice.CreateFrameBuffer(frameBufferDescImpl, out frameBufferImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), frameBufferImpl != null, Result.FAILURE, "Unexpected error: 'frameBufferImpl' is NULL!");
				frameBuffer = (FrameBuffer)Allocate!<FrameBufferValidator>(GetDeviceAllocator(), this, frameBufferImpl);
			}

			return result;
		}

		public override Result CreateQueryPool(QueryPoolDesc queryPoolDesc, out QueryPool queryPool)
		{
			queryPool = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(queryPoolDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create QueryPool: 'queryPoolDesc.physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), queryPoolDesc.queryType < QueryType.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create QueryPool: 'queryPoolDesc.queryType' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), queryPoolDesc.capacity > 0, Result.INVALID_ARGUMENT,
				"Can't create QueryPool: 'queryPoolDesc.capacity' is 0.");

			QueryPool queryPoolImpl = null;
			readonly Result result = mDevice.CreateQueryPool(queryPoolDesc, out queryPoolImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), queryPoolImpl != null, Result.FAILURE, "Unexpected error: 'queryPoolImpl' is NULL!");
				queryPool = (QueryPool)Allocate!<QueryPoolValidator>(GetDeviceAllocator(), this, queryPoolImpl, queryPoolDesc.queryType,
					queryPoolDesc.capacity);
			}

			return result;
		}

		public override Result CreateQueueSemaphore(out QueueSemaphore queueSemaphore)
		{
			queueSemaphore = ?;

			QueueSemaphore queueSemaphoreImpl;
			readonly Result result = mDevice.CreateQueueSemaphore(out queueSemaphoreImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), queueSemaphoreImpl != null, Result.FAILURE, "Unexpected error: 'queueSemaphoreImpl' is NULL!");
				queueSemaphore = (QueueSemaphore)Allocate!<QueueSemaphoreValidator>(GetDeviceAllocator(), this, queueSemaphoreImpl);
			}

			return result;
		}

		public override Result CreateDeviceSemaphore(bool signaled, out DeviceSemaphore deviceSemaphore)
		{
			deviceSemaphore = ?;

			DeviceSemaphore deviceSemaphoreImpl;
			readonly Result result = mDevice.CreateDeviceSemaphore(signaled, out deviceSemaphoreImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), deviceSemaphoreImpl != null, Result.FAILURE, "Unexpected error: 'queueSemaphoreImpl' is NULL!");
				DeviceSemaphoreValidator deviceSemaphoreVal = Allocate!<DeviceSemaphoreValidator>(GetDeviceAllocator(), this, deviceSemaphoreImpl);
				deviceSemaphoreVal.Create(signaled);
				deviceSemaphore = (DeviceSemaphore)deviceSemaphoreVal;
			}

			return result;
		}

		public override Result CreateSwapChain(SwapChainDesc swapChainDesc, out SwapChain swapChain)
		{
			swapChain = ?;

			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.commandQueue != null, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.commandQueue' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.windowSystemType < WindowSystemType.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.windowSystemType' is invalid.");

			if (swapChainDesc.windowSystemType == WindowSystemType.WINDOWS)
			{
				RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.windows.hwnd != null, Result.INVALID_ARGUMENT,
					"Can't create SwapChain: 'swapChainDesc.window.windows.hwnd' is invalid.");
			}
			else if (swapChainDesc.windowSystemType == WindowSystemType.X11)
			{
				RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.x11.dpy != null, Result.INVALID_ARGUMENT,
					"Can't create SwapChain: 'swapChainDesc.window.x11.dpy' is invalid.");
				RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.x11.window != 0, Result.INVALID_ARGUMENT,
					"Can't create SwapChain: 'swapChainDesc.window.x11.window' is invalid.");
			}
			else if (swapChainDesc.windowSystemType == WindowSystemType.WAYLAND)
			{
				RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.wayland.display != null, Result.INVALID_ARGUMENT,
					"Can't create SwapChain: 'swapChainDesc.window.wayland.display' is invalid.");
				RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.wayland.surface != null, Result.INVALID_ARGUMENT,
					"Can't create SwapChain: 'swapChainDesc.window.wayland.surface' is invalid.");
			}

			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.width != 0, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.width' is 0.");

			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.height != 0, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.height' is 0.");

			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.textureNum > 0, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.textureNum' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.format < SwapChainFormat.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.format' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.physicalDeviceIndex < m_PhysicalDeviceNum, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.physicalDeviceIndex' is invalid.");

			var swapChainDescImpl = swapChainDesc;
			swapChainDescImpl.commandQueue = swapChainDesc.commandQueue;

			SwapChain swapChainImpl;
			readonly Result result = mDevice.CreateSwapChain(swapChainDescImpl, out swapChainImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), swapChainImpl != null, Result.FAILURE, "Unexpected error: 'swapChainImpl' is NULL.");
				swapChain = (SwapChain)Allocate!<SwapChainValidator>(GetDeviceAllocator(), this, swapChainImpl, swapChainDesc);
			}

			return result;
		}

		public override Result CreateRayTracingPipeline(RayTracingPipelineDesc pipelineDesc, out Pipeline pipeline)
		{
			pipeline = ?;

			RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.pipelineLayout != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'pipelineDesc.pipelineLayout' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.shaderLibrary != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'pipelineDesc.shaderLibrary' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.shaderGroupDescs != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'pipelineDesc.shaderGroupDescs' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.shaderGroupDescNum != 0, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'pipelineDesc.shaderGroupDescNum' is 0.");

			RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.recursionDepthMax != 0, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'pipelineDesc.recursionDepthMax' is 0.");

			for (uint32 i = 0; i < pipelineDesc.shaderLibrary.shaderNum; i++)
			{
				readonly ref ShaderDesc shaderDesc = ref pipelineDesc.shaderLibrary.shaderDescs[i];

				RETURN_ON_FAILURE!(GetLogger(), shaderDesc.bytecode != null, Result.INVALID_ARGUMENT,
					"Can't create Pipeline: 'pipelineDesc.shaderLibrary.shaderDescs[{}].bytecode' is invalid.", i);

				RETURN_ON_FAILURE!(GetLogger(), shaderDesc.size != 0, Result.INVALID_ARGUMENT,
					"Can't create Pipeline: 'pipelineDesc.shaderLibrary.shaderDescs[{}].size' is 0.", i);

				RETURN_ON_FAILURE!(GetLogger(), shaderDesc.stage > ShaderStage.COMPUTE && shaderDesc.stage < ShaderStage.MAX_NUM, Result.INVALID_ARGUMENT,
					"Can't create Pipeline: 'pipelineDesc.shaderLibrary.shaderDescs[{}].stage' is invalid.", i);
			}

			var pipelineDescImpl = pipelineDesc;
			pipelineDescImpl.pipelineLayout = pipelineDesc.pipelineLayout;

			Pipeline pipelineImpl = null;
			readonly Result result = mDevice.CreateRayTracingPipeline(pipelineDescImpl, out pipelineImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), pipelineImpl != null, Result.FAILURE, "Unexpected error: 'pipelineImpl' is NULL.");
				pipeline = (Pipeline)Allocate!<PipelineValidator>(GetDeviceAllocator(), this, pipelineImpl);
			}

			return result;
		}

		public override Result CreateAccelerationStructure(AccelerationStructureDesc accelerationStructureDesc, out AccelerationStructure accelerationStructure)
		{
			accelerationStructure = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(accelerationStructureDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't create AccelerationStructure: 'accelerationStructureDesc.physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), accelerationStructureDesc.instanceOrGeometryObjectNum != 0, Result.INVALID_ARGUMENT,
				"Can't create AccelerationStructure: 'accelerationStructureDesc.instanceOrGeometryObjectNum' is 0.");

			AccelerationStructureDesc accelerationStructureDescImpl = accelerationStructureDesc;

			List<GeometryObject> objectImplArray = scope .();
			if (accelerationStructureDesc.type == AccelerationStructureType.BOTTOM_LEVEL)
			{
				readonly uint32 geometryObjectNum = accelerationStructureDesc.instanceOrGeometryObjectNum;
				objectImplArray.Resize(geometryObjectNum);
				ConvertGeometryObjectsVal(objectImplArray.Ptr, accelerationStructureDesc.geometryObjects, geometryObjectNum);
				accelerationStructureDescImpl.geometryObjects = objectImplArray.Ptr;
			}

			AccelerationStructure accelerationStructureImpl = null;
			readonly Result result = mDevice.CreateAccelerationStructure(accelerationStructureDescImpl, out accelerationStructureImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), accelerationStructureImpl != null, Result.FAILURE, "Unexpected error: 'accelerationStructureImpl' is NULL.");
				accelerationStructure = (AccelerationStructure)Allocate!<AccelerationStructureValidator>(GetDeviceAllocator(), this, accelerationStructureImpl);
			}

			return result;
		}

		public override void DestroyCommandAllocator(ref CommandAllocator commandAllocator)
		{
			mDevice.DestroyCommandAllocator(ref ((CommandAllocatorValidator)commandAllocator).GetImpl());
			Deallocate!(GetDeviceAllocator(), (CommandAllocatorValidator)commandAllocator);
		}

		public override void DestroyDescriptorPool(ref DescriptorPool descriptorPool)
		{
			mDevice.DestroyDescriptorPool(ref ((DescriptorPoolValidator)descriptorPool).GetImpl());
			Deallocate!(GetDeviceAllocator(), (DescriptorPoolValidator)descriptorPool);
		}

		public override void DestroyBuffer(ref Buffer buffer)
		{
			mDevice.DestroyBuffer(ref ((BufferValidator)buffer).GetImpl());
			Deallocate!(GetDeviceAllocator(), (BufferValidator)buffer);
		}

		public override void DestroyTexture(ref Texture texture)
		{
			mDevice.DestroyTexture(ref ((TextureValidator)texture).GetImpl());
			Deallocate!(GetDeviceAllocator(), (TextureValidator)texture);
		}

		public override void DestroyDescriptor(ref Descriptor descriptor)
		{
			mDevice.DestroyDescriptor(ref ((DescriptorValidator)descriptor).GetImpl());
			Deallocate!(GetDeviceAllocator(), (DescriptorValidator)descriptor);
		}

		public override void DestroyPipelineLayout(ref PipelineLayout pipelineLayout)
		{
			mDevice.DestroyPipelineLayout(ref ((PipelineLayoutValidator)pipelineLayout).GetImpl());
			Deallocate!(GetDeviceAllocator(), (PipelineLayoutValidator)pipelineLayout);
		}

		public override void DestroyPipeline(ref Pipeline pipeline)
		{
			mDevice.DestroyPipeline(ref ((PipelineValidator)pipeline).GetImpl());
			Deallocate!(GetDeviceAllocator(), (PipelineValidator)pipeline);
		}

		public override void DestroyFrameBuffer(ref FrameBuffer frameBuffer)
		{
			mDevice.DestroyFrameBuffer(ref ((FrameBufferValidator)frameBuffer).GetImpl());
			Deallocate!(GetDeviceAllocator(), (FrameBuffer)frameBuffer);
		}

		public override void DestroyQueryPool(ref QueryPool queryPool)
		{
			mDevice.DestroyQueryPool(ref ((QueryPoolValidator)queryPool).GetImpl());
			Deallocate!(GetDeviceAllocator(), (QueryPoolValidator)queryPool);
		}

		public override void DestroyQueueSemaphore(ref QueueSemaphore queueSemaphore)
		{
			mDevice.DestroyQueueSemaphore(ref ((QueueSemaphoreValidator)queueSemaphore).GetImpl());
			Deallocate!(GetDeviceAllocator(), (QueueSemaphoreValidator)queueSemaphore);
		}

		public override void DestroyDeviceSemaphore(ref DeviceSemaphore deviceSemaphore)
		{
			mDevice.DestroyDeviceSemaphore(ref ((DeviceSemaphoreValidator)deviceSemaphore).GetImpl());
			Deallocate!(GetDeviceAllocator(), (DeviceSemaphoreValidator)deviceSemaphore);
		}

		public override void DestroySwapChain(ref SwapChain swapChain)
		{
			mDevice.DestroySwapChain(ref ((SwapChainValidator)swapChain).GetImpl());
			Deallocate!(GetDeviceAllocator(), (SwapChainValidator)swapChain);
		}

		public override void DestroyAccelerationStructure(ref AccelerationStructure accelerationStructure)
		{
			Deallocate!(GetDeviceAllocator(), (AccelerationStructureValidator)accelerationStructure);
		}

		public override void DestroyCommandBuffer(ref CommandBuffer commandBuffer)
		{
			mDevice.DestroyCommandBuffer(ref ((CommandBufferValidator)commandBuffer).GetImpl());
			Deallocate!(mDevice.GetDeviceAllocator(), commandBuffer);
		}

		public override Result GetDisplays(Display** displays, ref uint32 displayNum)
		{
			RETURN_ON_FAILURE!(GetLogger(), displayNum == 0 || displays != null, Result.INVALID_ARGUMENT,
				"Can't get displays: 'displays' is invalid.");

			return mDevice.GetDisplays(displays, ref displayNum);
		}

		public override Result GetDisplaySize(ref Display display, ref uint16 width, ref uint16 height)
		{
			return mDevice.GetDisplaySize(ref display, ref width, ref height);
		}

		public override Result AllocateMemory(uint32 physicalDeviceMask, uint32 memoryType, uint64 size, out Memory memory)
		{
			memory = ?;

			RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(physicalDeviceMask), Result.INVALID_ARGUMENT,
				"Can't allocate Memory: 'physicalDeviceMask' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), size > 0, Result.INVALID_ARGUMENT,
				"Can't allocate Memory: 'size' is 0.");

			bool hasMemoryType = false;
			MemoryLocation memoryLocation = .MAX_NUM;
			using (m_Monitor.Enter())
			{
				if (m_MemoryTypeMap.ContainsKey(memoryType))
				{
					hasMemoryType = true;
					memoryLocation = m_MemoryTypeMap[memoryType];
				}
			}

			RETURN_ON_FAILURE!(GetLogger(), hasMemoryType, Result.FAILURE,
				"Can't allocate Memory: 'memoryType' is invalid.");

			Memory memoryImpl;
			readonly Result result = mDevice.AllocateMemory(physicalDeviceMask, memoryType, size, out memoryImpl);

			if (result == Result.SUCCESS)
			{
				RETURN_ON_FAILURE!(GetLogger(), memoryImpl != null, Result.FAILURE, "Unexpected error: 'memoryImpl' is NULL!");
				memory = (Memory)Allocate!<MemoryValidator>(GetDeviceAllocator(), this, memoryImpl, size, memoryLocation);
			}

			return result;
		}

		public override Result BindBufferMemory(BufferMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
		{
			if (memoryBindingDescNum == 0)
				return Result.SUCCESS;

			RETURN_ON_FAILURE!(GetLogger(), memoryBindingDescs != null, Result.INVALID_ARGUMENT,
				"Can't bind memory to buffers: 'memoryBindingDescs' is invalid.");

			BufferMemoryBindingDesc* memoryBindingDescsImpl = STACK_ALLOC!<BufferMemoryBindingDesc>(memoryBindingDescNum);

			for (uint32 i = 0; i < memoryBindingDescNum; i++)
			{
				ref BufferMemoryBindingDesc destDesc = ref memoryBindingDescsImpl[i];
				readonly ref BufferMemoryBindingDesc srcDesc = ref memoryBindingDescs[i];

				RETURN_ON_FAILURE!(GetLogger(), srcDesc.buffer != null, Result.INVALID_ARGUMENT,
					"Can't bind memory to buffers: 'memoryBindingDescs[{}].buffer' is invalid.", i);
				RETURN_ON_FAILURE!(GetLogger(), srcDesc.memory != null, Result.INVALID_ARGUMENT,
					"Can't bind memory to buffers: 'memoryBindingDescs[{}].memory' is invalid.", i);

				MemoryValidator memory = (MemoryValidator)srcDesc.memory;
				BufferValidator buffer = (BufferValidator)srcDesc.buffer;

				RETURN_ON_FAILURE!(GetLogger(), !buffer.IsBoundToMemory(), Result.INVALID_ARGUMENT,
					"Can't bind memory to buffers: 'memoryBindingDescs[{}].buffer' is already bound to memory.", i);

				// Skip validation if memory has been created from GAPI object using a wrapper extension
				if (memory.GetMemoryLocation() == MemoryLocation.MAX_NUM)
					continue;

				MemoryDesc memoryDesc = .();
				buffer.GetMemoryInfo(memory.GetMemoryLocation(), ref memoryDesc);

				RETURN_ON_FAILURE!(GetLogger(), !memoryDesc.mustBeDedicated || srcDesc.offset == 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to buffers: 'memoryBindingDescs[{}].offset' must be zero for dedicated allocation.", i);

				RETURN_ON_FAILURE!(GetLogger(), memoryDesc.alignment != 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to buffers: 'memoryBindingDescs[{}].alignment' can't be zero.", i);

				RETURN_ON_FAILURE!(GetLogger(), srcDesc.offset % memoryDesc.alignment == 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to buffers: 'memoryBindingDescs[{}].offset' is misaligned.", i);

				readonly uint64 rangeMax = srcDesc.offset + memoryDesc.size;
				readonly bool memorySizeIsUnknown = memory.GetSize() == 0;

				RETURN_ON_FAILURE!(GetLogger(), memorySizeIsUnknown || rangeMax <= memory.GetSize(), Result.INVALID_ARGUMENT,
					"Can't bind memory to buffers: 'memoryBindingDescs[{}].offset' is invalid.", i);

				destDesc = srcDesc;
				destDesc.memory = memory.GetImpl();
				destDesc.buffer = buffer.GetImpl();
			}

			readonly Result result = mDevice.BindBufferMemory(memoryBindingDescsImpl, memoryBindingDescNum);

			if (result == Result.SUCCESS)
			{
				for (uint32 i = 0; i < memoryBindingDescNum; i++)
				{
					MemoryValidator memory = (MemoryValidator)memoryBindingDescs[i].memory;
					memory.BindBuffer((BufferValidator)memoryBindingDescs[i].buffer);
				}
			}

			return result;
		}

		public override Result BindTextureMemory(TextureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
		{
			RETURN_ON_FAILURE!(GetLogger(), memoryBindingDescs != null || memoryBindingDescNum == 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to textures: 'memoryBindingDescs' is a NULL.");

			TextureMemoryBindingDesc* memoryBindingDescsImpl = STACK_ALLOC!<TextureMemoryBindingDesc>(memoryBindingDescNum);

			for (uint32 i = 0; i < memoryBindingDescNum; i++)
			{
				ref TextureMemoryBindingDesc destDesc = ref memoryBindingDescsImpl[i];
				readonly ref TextureMemoryBindingDesc srcDesc = ref memoryBindingDescs[i];

				RETURN_ON_FAILURE!(GetLogger(), srcDesc.texture != null, Result.INVALID_ARGUMENT,
					"Can't bind memory to textures: 'memoryBindingDescs[{}].texture' is invalid.", i);
				RETURN_ON_FAILURE!(GetLogger(), srcDesc.memory != null, Result.INVALID_ARGUMENT,
					"Can't bind memory to textures: 'memoryBindingDescs[{}].memory' is invalid.", i);

				MemoryValidator memory = (MemoryValidator)srcDesc.memory;
				TextureValidator texture = (TextureValidator)srcDesc.texture;

				RETURN_ON_FAILURE!(GetLogger(), !texture.IsBoundToMemory(), Result.INVALID_ARGUMENT,
					"Can't bind memory to textures: 'memoryBindingDescs[{}].texture' is already bound to memory.", i);

				// Skip validation if memory has been created from GAPI object using a wrapper extension
				if (memory.GetMemoryLocation() == MemoryLocation.MAX_NUM)
					continue;

				MemoryDesc memoryDesc = .();
				texture.GetMemoryInfo(memory.GetMemoryLocation(), ref memoryDesc);

				RETURN_ON_FAILURE!(GetLogger(), !memoryDesc.mustBeDedicated || srcDesc.offset == 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to textures: 'memoryBindingDescs[{}].offset' must be zero for dedicated allocation.", i);

				RETURN_ON_FAILURE!(GetLogger(), memoryDesc.alignment != 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to textures: 'memoryBindingDescs[{}].alignment' can't be zero.", i);

				RETURN_ON_FAILURE!(GetLogger(), srcDesc.offset % memoryDesc.alignment == 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to textures: 'memoryBindingDescs[{}].offset' is misaligned.", i);

				readonly uint64 rangeMax = srcDesc.offset + memoryDesc.size;
				readonly bool memorySizeIsUnknown = memory.GetSize() == 0;

				RETURN_ON_FAILURE!(GetLogger(), memorySizeIsUnknown || rangeMax <= memory.GetSize(), Result.INVALID_ARGUMENT,
					"Can't bind memory to textures: 'memoryBindingDescs[{}].offset' is invalid.", i);

				destDesc = srcDesc;
				destDesc.memory = memory.GetImpl();
				destDesc.texture = texture.GetImpl();
			}

			readonly Result result = mDevice.BindTextureMemory(memoryBindingDescsImpl, memoryBindingDescNum);

			if (result == Result.SUCCESS)
			{
				for (uint32 i = 0; i < memoryBindingDescNum; i++)
				{
					MemoryValidator memory = (MemoryValidator)memoryBindingDescs[i].memory;
					memory.BindTexture((TextureValidator)memoryBindingDescs[i].texture);
				}
			}

			return result;
		}

		public override Result BindAccelerationStructureMemory(AccelerationStructureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
		{
			if (memoryBindingDescNum == 0)
				return Result.SUCCESS;

			RETURN_ON_FAILURE!(GetLogger(), memoryBindingDescs != null, Result.INVALID_ARGUMENT,
				"Can't bind memory to acceleration structures: 'memoryBindingDescs' is invalid.");

			AccelerationStructureMemoryBindingDesc* memoryBindingDescsImpl = STACK_ALLOC!<AccelerationStructureMemoryBindingDesc>(memoryBindingDescNum);
			for (uint32 i = 0; i < memoryBindingDescNum; i++)
			{
				ref AccelerationStructureMemoryBindingDesc destDesc = ref memoryBindingDescsImpl[i];
				readonly ref AccelerationStructureMemoryBindingDesc srcDesc = ref memoryBindingDescs[i];

				MemoryValidator memory = (MemoryValidator)srcDesc.memory;
				AccelerationStructureValidator accelerationStructure = (AccelerationStructureValidator)srcDesc.accelerationStructure;

				RETURN_ON_FAILURE!(GetLogger(), !accelerationStructure.IsBoundToMemory(), Result.INVALID_ARGUMENT,
					"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].accelerationStructure' is already bound to memory.", i);

				MemoryDesc memoryDesc = .();
				accelerationStructure.GetMemoryInfo(ref memoryDesc);

				RETURN_ON_FAILURE!(GetLogger(), !memoryDesc.mustBeDedicated || srcDesc.offset == 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].offset' must be zero for dedicated allocation.", i);

				RETURN_ON_FAILURE!(GetLogger(), memoryDesc.alignment != 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].alignment' can't be zero.", i);

				RETURN_ON_FAILURE!(GetLogger(), srcDesc.offset % memoryDesc.alignment == 0, Result.INVALID_ARGUMENT,
					"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].offset' is misaligned.", i);

				readonly uint64 rangeMax = srcDesc.offset + memoryDesc.size;
				readonly bool memorySizeIsUnknown = memory.GetSize() == 0;

				RETURN_ON_FAILURE!(GetLogger(), memorySizeIsUnknown || rangeMax <= memory.GetSize(), Result.INVALID_ARGUMENT,
					"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].offset' is invalid.", i);

				destDesc = srcDesc;
				destDesc.memory = memory.GetImpl();
				destDesc.accelerationStructure = accelerationStructure.GetImpl();
			}

			readonly Result result = mDevice.BindAccelerationStructureMemory(memoryBindingDescsImpl, memoryBindingDescNum);

			if (result == Result.SUCCESS)
			{
				for (uint32 i = 0; i < memoryBindingDescNum; i++)
				{
					MemoryValidator memory = (MemoryValidator)memoryBindingDescs[i].memory;
					memory.BindAccelerationStructure((AccelerationStructureValidator)memoryBindingDescs[i].accelerationStructure);
				}
			}

			return result;
		}

		public override void FreeMemory(ref Memory memory)
		{
			MemoryValidator memoryVal = (MemoryValidator)memory;

			if (memoryVal.HasBoundResources())
			{
				memoryVal.ReportBoundResources();
				REPORT_ERROR(GetLogger(), "Can't free Memory: some resources are still bound to the memory.");
				return;
			}

			mDevice.FreeMemory(ref ((MemoryValidator)memory).GetImpl());
			Deallocate!(GetDeviceAllocator(), (MemoryValidator)memory);
		}

		public override FormatSupportBits GetFormatSupport(Format format)
		{
			return mDevice.GetFormatSupport(format);
		}

		public override uint32 CalculateAllocationNumber(ResourceGroupDesc resourceGroupDesc)
		{
			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.memoryLocation < MemoryLocation.MAX_NUM, 0,
				"Can't calculate the number of allocations: 'resourceGroupDesc.memoryLocation' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.bufferNum == 0 || resourceGroupDesc.buffers != null, 0,
				"Can't calculate the number of allocations: 'resourceGroupDesc.buffers' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.textureNum == 0 || resourceGroupDesc.textures != null, 0,
				"Can't calculate the number of allocations: 'resourceGroupDesc.textures' is invalid.");

			Buffer* buffersImpl = scope:: List<Buffer>() { Count = resourceGroupDesc.bufferNum }.Ptr; //STACK_ALLOC(Buffer*, resourceGroupDesc.bufferNum);

			for (uint32 i = 0; i < resourceGroupDesc.bufferNum; i++)
			{
				RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.buffers[i] != null, 0,
					"Can't calculate the number of allocations: 'resourceGroupDesc.buffers[{}]' is invalid.", i);

				BufferValidator bufferVal = (BufferValidator)resourceGroupDesc.buffers[i];
				buffersImpl[i] = (Buffer)bufferVal;
			}

			Texture* texturesImpl = scope List<Texture>() { Count = resourceGroupDesc.textureNum }.Ptr; // STACK_ALLOC(Texture*, resourceGroupDesc.textureNum);

			for (uint32 i = 0; i < resourceGroupDesc.textureNum; i++)
			{
				RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.textures[i] != null, 0,
					"Can't calculate the number of allocations: 'resourceGroupDesc.textures[{}]' is invalid.", i);

				TextureValidator textureVal = (TextureValidator)resourceGroupDesc.textures[i];
				texturesImpl[i] = (Texture)textureVal;
			}

			ResourceGroupDesc resourceGroupDescImpl = resourceGroupDesc;
			resourceGroupDescImpl.buffers = buffersImpl;
			resourceGroupDescImpl.textures = texturesImpl;

			return mDevice.CalculateAllocationNumber(resourceGroupDescImpl);
		}

		public override Result AllocateAndBindMemory(ResourceGroupDesc resourceGroupDesc, Memory* allocations)
		{
			RETURN_ON_FAILURE!(GetLogger(), allocations != null, Result.INVALID_ARGUMENT,
				"Can't allocate and bind memory: 'allocations' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.memoryLocation < MemoryLocation.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't allocate and bind memory: 'resourceGroupDesc.memoryLocation' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.bufferNum == 0 || resourceGroupDesc.buffers != null, Result.INVALID_ARGUMENT,
				"Can't allocate and bind memory: 'resourceGroupDesc.buffers' is invalid.");

			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.textureNum == 0 || resourceGroupDesc.textures != null, Result.INVALID_ARGUMENT,
				"Can't allocate and bind memory: 'resourceGroupDesc.textures' is invalid.");

			Buffer* buffersImpl = scope:: List<Buffer>() { Count = resourceGroupDesc.bufferNum }.Ptr; //STACK_ALLOC(Buffer*, resourceGroupDesc.bufferNum);

			for (uint32 i = 0; i < resourceGroupDesc.bufferNum; i++)
			{
				RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.buffers[i] != null, Result.INVALID_ARGUMENT,
					"Can't allocate and bind memory: 'resourceGroupDesc.buffers[{}]' is invalid.", i);

				BufferValidator bufferVal = (BufferValidator)resourceGroupDesc.buffers[i];
				buffersImpl[i] = (Buffer)bufferVal;
			}

			Texture* texturesImpl = scope List<Texture>() { Count = resourceGroupDesc.textureNum }.Ptr; //STACK_ALLOC(Texture*, resourceGroupDesc.textureNum);

			for (uint32 i = 0; i < resourceGroupDesc.textureNum; i++)
			{
				RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.textures[i] != null, Result.INVALID_ARGUMENT,
					"Can't allocate and bind memory: 'resourceGroupDesc.textures[{}]' is invalid.", i);

				TextureValidator textureVal = (TextureValidator)resourceGroupDesc.textures[i];
				texturesImpl[i] = (Texture)textureVal;
			}

			readonly int allocationNum = CalculateAllocationNumber(resourceGroupDesc);

			ResourceGroupDesc resourceGroupDescImpl = resourceGroupDesc;
			resourceGroupDescImpl.buffers = buffersImpl;
			resourceGroupDescImpl.textures = texturesImpl;

			readonly Result result = mDevice.AllocateAndBindMemory(resourceGroupDescImpl, allocations);

			if (result == Result.SUCCESS)
			{
				for (uint32 i = 0; i < resourceGroupDesc.bufferNum; i++)
				{
					BufferValidator BufferValidatoridatoridatoridatoridator = (BufferValidator)resourceGroupDesc.buffers[i];
					BufferValidatoridatoridatoridatoridator.SetBoundToMemory();
				}

				for (uint32 i = 0; i < resourceGroupDesc.textureNum; i++)
				{
					TextureValidator textureVal = (TextureValidator)resourceGroupDesc.textures[i];
					textureVal.SetBoundToMemory();
				}

				for (uint32 i = 0; i < allocationNum; i++)
				{
					RETURN_ON_FAILURE!(GetLogger(), allocations[i] != null, Result.FAILURE, "Unexpected error: 'memoryImpl' is invalid");
					allocations[i] = (Memory)Allocate!<MemoryValidator>(GetDeviceAllocator(), this, allocations[i], 0, resourceGroupDesc.memoryLocation);
				}
			}

			return result;
		}

		public override void SetSPIRVBindingOffsets(SPIRVBindingOffsets spirvBindingOffsets)
		{
			mDevice.SetSPIRVBindingOffsets(spirvBindingOffsets);
		}

		public uint32 GetPhysicalDeviceNum() => m_PhysicalDeviceNum;

		public bool IsPhysicalDeviceMaskValid(uint32 physicalDeviceMask) => m_PhysicalDeviceMask & physicalDeviceMask == physicalDeviceMask;

		public Monitor GetLock() => m_Monitor;
	}
}
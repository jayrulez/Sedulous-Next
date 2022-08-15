using System.Collections;
using System;
namespace Sedulous.RHI.Validation
{
	enum ValidationCommandType : uint32
	{
		NONE,
		BEGIN_QUERY,
		END_QUERY,
		RESET_QUERY,
		MAX_NUM
	}

	struct ValidationCommandUseQuery
	{
		public ValidationCommandType type;
		public QueryPool queryPool;
		public uint32 queryPoolOffset;
	}

	struct ValidationCommandResetQuery
	{
		public ValidationCommandType type;
		public QueryPool queryPool;
		public uint32 queryPoolOffset;
		public uint32 queryNum;
	}

	public static
	{
		public static bool ValidateBufferTransitionBarrierDesc(DeviceValidator device, uint32 i, BufferTransitionBarrierDesc bufferTransitionBarrierDesc)
		{
			RETURN_ON_FAILURE!(device.GetLogger(), bufferTransitionBarrierDesc.buffer != null, false,
				"Can't record pipeline barrier: 'transitionBarriers->buffers[%u].buffer' is invalid.", i);

			readonly BufferValidator bufferVal = (BufferValidator)bufferTransitionBarrierDesc.buffer;

			RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(bufferVal.GetUsageMask(), bufferTransitionBarrierDesc.prevAccess), false,
				"Can't record pipeline barrier: 'transitionBarriers->buffers[%u].prevAccess' is not supported by the usage mask of the buffer ('{}').",
				i, bufferVal.GetDebugName());

			RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(bufferVal.GetUsageMask(), bufferTransitionBarrierDesc.nextAccess), false,
				"Can't record pipeline barrier: 'transitionBarriers->buffers[%u].nextAccess' is not supported by the usage mask of the buffer ('{}').",
				i, bufferVal.GetDebugName());

			return true;
		}

		public static bool ValidateTextureTransitionBarrierDesc(DeviceValidator device, uint32 i, TextureTransitionBarrierDesc textureTransitionBarrierDesc)
		{
			RETURN_ON_FAILURE!(device.GetLogger(), textureTransitionBarrierDesc.texture != null, false,
				"Can't record pipeline barrier: 'transitionBarriers->textures[%u].texture' is invalid.", i);

			TextureValidator textureVal = (TextureValidator)textureTransitionBarrierDesc.texture;

			RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(textureVal.GetDesc().usageMask, textureTransitionBarrierDesc.prevAccess), false,
				"Can't record pipeline barrier: 'transitionBarriers->textures[%u].prevAccess' is not supported by the usage mask of the texture ('{}').",
				i, textureVal.GetDebugName());

			RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(textureVal.GetDesc().usageMask, textureTransitionBarrierDesc.nextAccess), false,
				"Can't record pipeline barrier: 'transitionBarriers->textures[%u].nextAccess' is not supported by the usage mask of the texture ('{}').",
				i, textureVal.GetDebugName());

			RETURN_ON_FAILURE!(device.GetLogger(), IsTextureLayoutSupported(textureVal.GetDesc().usageMask, textureTransitionBarrierDesc.prevLayout), false,
				"Can't record pipeline barrier: 'transitionBarriers->textures[%u].prevLayout' is not supported by the usage mask of the texture ('{}').",
				i, textureVal.GetDebugName());

			RETURN_ON_FAILURE!(device.GetLogger(), IsTextureLayoutSupported(textureVal.GetDesc().usageMask, textureTransitionBarrierDesc.nextLayout), false,
				"Can't record pipeline barrier: 'transitionBarriers->textures[%u].nextLayout' is not supported by the usage mask of the texture ('{}').",
				i, textureVal.GetDebugName());

			return true;
		}
	}

	class CommandBufferValidator : CommandBuffer
	{
		private readonly DeviceValidator mDevice;
		private CommandBuffer mCommandBuffer;

		List<uint8> m_ValidationCommands = new .() ~ delete _;
		bool m_IsRecordingStarted = false;
		FrameBuffer m_FrameBuffer = null;
		int32 m_AnnotationStack = 0;

		private readonly String mDebugName = new .() ~ delete _;

		private mut Command AllocateValidationCommand<Command>()
		{
			readonly int commandSize = sizeof(Command);
			readonly int newSize = m_ValidationCommands.Count + commandSize;
			readonly int capacity = m_ValidationCommands.Capacity;

			if (newSize > capacity)
				m_ValidationCommands.Reserve(Math.Max(capacity + (capacity >> 1), newSize));

			readonly int offset = m_ValidationCommands.Count;
			m_ValidationCommands.Resize(newSize);

			return mut *(Command*)(m_ValidationCommands.Ptr + offset);
		}

		public List<uint8> GetValidationCommands() => m_ValidationCommands;

		public this(DeviceValidator device, CommandBuffer commandBuffer)
		{
			mDevice = device;
			mCommandBuffer = commandBuffer;
		}


		public ref CommandBuffer GetImpl() => ref mCommandBuffer;

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mCommandBuffer.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override Result Begin(DescriptorPool descriptorPool, uint32 physicalDeviceIndex)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), !m_IsRecordingStarted, Result.FAILURE,
				"Can't begin recording of CommandBuffer: the command buffer is already in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), physicalDeviceIndex < mDevice.GetPhysicalDeviceNum(), Result.FAILURE,
				"Can't begin recording of CommandBuffer: 'physicalDeviceIndex' is invalid.");

			DescriptorPool descriptorPoolImpl = null;
			if (descriptorPool != null)
				descriptorPoolImpl = ((DescriptorPoolValidator)descriptorPool).GetImpl();

			Result result = mCommandBuffer.Begin(descriptorPoolImpl, physicalDeviceIndex);
			if (result == Result.SUCCESS)
				m_IsRecordingStarted = true;

			m_ValidationCommands.Clear();

			return result;
		}

		public override Result End()
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, Result.FAILURE,
				"Can't end command buffer: the command buffer must be in the recording state.");

			if (m_AnnotationStack > 0)
				REPORT_ERROR(mDevice.GetLogger(), "BeginAnnotation() is called more times than EndAnnotation()");
			else if (m_AnnotationStack < 0)
				REPORT_ERROR(mDevice.GetLogger(), "EndAnnotation() is called more times than BeginAnnotation()");

			Result result = mCommandBuffer.End();

			if (result == Result.SUCCESS)
			{
				m_IsRecordingStarted = false;
				m_FrameBuffer = null;
			}

			return result;
		}

		public override void SetPipeline(Pipeline pipeline)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set pipeline: the command buffer must be in the recording state.");

			Pipeline pipelineImpl = ((PipelineValidator)pipeline).GetImpl();

			mCommandBuffer.SetPipeline(pipelineImpl);
		}

		public override void SetPipelineLayout(PipelineLayout pipelineLayout)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set pipeline layout: the command buffer must be in the recording state.");

			PipelineLayout pipelineLayoutImpl = ((PipelineLayoutValidator)pipelineLayout).GetImpl();

			mCommandBuffer.SetPipelineLayout(pipelineLayoutImpl);
		}

		public override void SetDescriptorSets(uint32 baseIndex, uint32 descriptorSetNum, DescriptorSet* descriptorSets, uint32* dynamicConstantBufferOffsets)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set descriptor sets: the command buffer must be in the recording state.");

			DescriptorSet* descriptorSetsImpl = scope:: List<DescriptorSet>() { Count = descriptorSetNum }.Ptr; //STACK_ALLOC!<DescriptorSet>(descriptorSetNum);
			for (uint32 i = 0; i < descriptorSetNum; i++)
				descriptorSetsImpl[i] = ((DescriptorSetValidator)descriptorSets[i]).GetImpl();

			mCommandBuffer.SetDescriptorSets(baseIndex, descriptorSetNum, descriptorSetsImpl, dynamicConstantBufferOffsets);
		}

		public override void SetConstants(uint32 pushConstantIndex, void* data, uint32 size)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set constants: the command buffer must be in the recording state.");

			mCommandBuffer.SetConstants(pushConstantIndex, data, size);
		}

		public override void SetDescriptorPool(DescriptorPool descriptorPool)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set descriptor pool: the command buffer must be in the recording state.");

			DescriptorPool descriptorPoolImpl = ((DescriptorPoolValidator)descriptorPool).GetImpl();

			mCommandBuffer.SetDescriptorPool(descriptorPoolImpl);
		}

		public override void PipelineBarrier(TransitionBarrierDesc* transitionBarriers, AliasingBarrierDesc* aliasingBarriers, BarrierDependency dependency)
		{
			var transitionBarriers;
			var aliasingBarriers;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't record pipeline barrier: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't record pipeline barrier: this operation is allowed only outside render pass.");

			TransitionBarrierDesc transitionBarrierImpl;
			if (transitionBarriers != null)
			{
				transitionBarrierImpl = *transitionBarriers;

				for (uint32 i = 0; i < transitionBarriers.bufferNum; i++)
				{
					if (!ValidateBufferTransitionBarrierDesc(mDevice, i, transitionBarriers.buffers[i]))
						return;
				}

				for (uint32 i = 0; i < transitionBarriers.textureNum; i++)
				{
					if (!ValidateTextureTransitionBarrierDesc(mDevice, i, transitionBarriers.textures[i]))
						return;
				}

				transitionBarrierImpl.buffers = STACK_ALLOC!<BufferTransitionBarrierDesc>(transitionBarriers.bufferNum);
				Internal.MemCpy((void*)transitionBarrierImpl.buffers, transitionBarriers.buffers, sizeof(BufferTransitionBarrierDesc) * transitionBarriers.bufferNum);
				for (uint32 i = 0; i < transitionBarrierImpl.bufferNum; i++)
					((BufferTransitionBarrierDesc*)transitionBarrierImpl.buffers)[i].buffer = ((BufferValidator)transitionBarriers.buffers[i].buffer).GetImpl();

				transitionBarrierImpl.textures = STACK_ALLOC!<TextureTransitionBarrierDesc>(transitionBarriers.textureNum);
				Internal.MemCpy((void*)transitionBarrierImpl.textures, transitionBarriers.textures, sizeof(TextureTransitionBarrierDesc) * transitionBarriers.textureNum);
				for (uint32 i = 0; i < transitionBarrierImpl.textureNum; i++)
					((TextureTransitionBarrierDesc*)transitionBarrierImpl.textures)[i].texture = ((TextureValidator)transitionBarriers.textures[i].texture).GetImpl();

				transitionBarriers = &transitionBarrierImpl;
			}

			AliasingBarrierDesc aliasingBarriersImpl;
			if (aliasingBarriers != null)
			{
				aliasingBarriersImpl = *aliasingBarriers;

				aliasingBarriersImpl.buffers = STACK_ALLOC!<BufferAliasingBarrierDesc>(aliasingBarriers.bufferNum);
				Internal.MemCpy((void*)aliasingBarriersImpl.buffers, aliasingBarriers.buffers, sizeof(BufferAliasingBarrierDesc) * aliasingBarriers.bufferNum);
				for (uint32 i = 0; i < aliasingBarriersImpl.bufferNum; i++)
				{
					((BufferAliasingBarrierDesc*)aliasingBarriersImpl.buffers)[i].before = ((BufferValidator)aliasingBarriers.buffers[i].before).GetImpl();
					((BufferAliasingBarrierDesc*)aliasingBarriersImpl.buffers)[i].after = ((BufferValidator)aliasingBarriers.buffers[i].after).GetImpl();
				}

				aliasingBarriersImpl.textures = STACK_ALLOC!<TextureAliasingBarrierDesc>(aliasingBarriers.textureNum);
				Internal.MemCpy((void*)aliasingBarriersImpl.textures, aliasingBarriers.textures, sizeof(TextureAliasingBarrierDesc) * aliasingBarriers.textureNum);
				for (uint32 i = 0; i < aliasingBarriersImpl.textureNum; i++)
				{
					((TextureAliasingBarrierDesc*)aliasingBarriersImpl.textures)[i].before = ((TextureValidator)aliasingBarriers.textures[i].before).GetImpl();
					((TextureAliasingBarrierDesc*)aliasingBarriersImpl.textures)[i].after = ((TextureValidator)aliasingBarriers.textures[i].after).GetImpl();
				}

				aliasingBarriers = &aliasingBarriersImpl;
			}

			mCommandBuffer.PipelineBarrier(transitionBarriers, aliasingBarriers, dependency);
		}

		public override void BeginRenderPass(FrameBuffer frameBuffer, RenderPassBeginFlag renderPassBeginFlag)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't begin render pass: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't begin render pass: render pass already started.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), renderPassBeginFlag < RenderPassBeginFlag.MAX_NUM, void(),
				"Can't begin render pass: 'renderPassBeginFlag' is invalid.");

			m_FrameBuffer = frameBuffer;

			FrameBuffer frameBufferImpl = ((FrameBufferValidator) frameBuffer).GetImpl();

			mCommandBuffer.BeginRenderPass(frameBufferImpl, renderPassBeginFlag);
		}

		public override void EndRenderPass()
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't end render pass: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer != null, void(),
				"Can't end render pass: no render pass.");

			m_FrameBuffer = null;

			mCommandBuffer.EndRenderPass();
		}

		public override void SetViewports(Viewport* viewports, uint32 viewportNum)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set viewports: the command buffer must be in the recording state.");

			if (viewportNum == 0)
				return;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), viewports != null, void(),
				"Can't set viewports: 'viewports' is invalid.");

			mCommandBuffer.SetViewports(viewports, viewportNum);
		}

		public override void SetScissors(Rect* rects, uint32 rectNum)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set scissors: the command buffer must be in the recording state.");

			if (rectNum == 0)
				return;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), rects != null, void(),
				"Can't set scissor rects: 'rects' is invalid.");

			mCommandBuffer.SetScissors(rects, rectNum);
		}

		public override void SetDepthBounds(float boundsMin, float boundsMax)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set depth bounds: the command buffer must be in the recording state.");

			mCommandBuffer.SetDepthBounds(boundsMin, boundsMax);
		}

		public override void SetStencilReference(uint8 reference)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set stencil reference: the command buffer must be in the recording state.");

			mCommandBuffer.SetStencilReference(reference);
		}

		public override void SetSamplePositions(SamplePosition* positions, uint32 positionNum)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set sample positions: the command buffer must be in the recording state.");

			mCommandBuffer.SetSamplePositions(positions, positionNum);
		}

		public override void ClearAttachments(ClearDesc* clearDescs, uint32 clearDescNum, Rect* rects, uint32 rectNum)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't clear attachments: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer != null, void(),
				"Can't clear attachments: no FrameBuffer bound.");

			mCommandBuffer.ClearAttachments(clearDescs, clearDescNum, rects, rectNum);
		}

		public override void SetIndexBuffer(Buffer buffer, uint64 offset, IndexType indexType)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set index buffers: the command buffer must be in the recording state.");

			Buffer bufferImpl = ((BufferValidator)buffer).GetImpl();

			mCommandBuffer.SetIndexBuffer(bufferImpl, offset, indexType);
		}

		public override void SetVertexBuffers(uint32 baseSlot, uint32 bufferNum, Buffer* buffers, uint64* offsets)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't set vertex buffers: the command buffer must be in the recording state.");

			Buffer* buffersImpl = scope:: List<Buffer>() { Count = bufferNum }.Ptr; //STACK_ALLOC!<Buffer>(bufferNum);
			for (uint32 i = 0; i < bufferNum; i++)
				buffersImpl[i] = ((BufferValidator)buffers[i]).GetImpl();

			mCommandBuffer.SetVertexBuffers(baseSlot, bufferNum, buffersImpl, offsets);
		}

		public override void Draw(uint32 vertexNum, uint32 instanceNum, uint32 baseVertex, uint32 baseInstance)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't record draw call: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer != null, void(),
				"Can't record draw call: this operation is allowed only inside render pass.");

			mCommandBuffer.Draw(vertexNum, instanceNum, baseVertex, baseInstance);
		}

		public override void DrawIndexed(uint32 indexNum, uint32 instanceNum, uint32 baseIndex, uint32 baseVertex, uint32 baseInstance)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't record draw call: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer != null, void(),
				"Can't record draw call: this operation is allowed only inside render pass.");

			mCommandBuffer.DrawIndexed(indexNum, instanceNum, baseIndex, baseVertex, baseInstance);
		}

		public override void DrawIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't record draw call: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer != null, void(),
				"Can't record draw call: this operation is allowed only inside render pass.");

			Buffer bufferImpl = ((BufferValidator)buffer).GetImpl();

			mCommandBuffer.DrawIndirect(bufferImpl, offset, drawNum, stride);
		}

		public override void DrawIndexedIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't record draw call: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer != null, void(),
				"Can't record draw call: this operation is allowed only inside render pass.");

			Buffer bufferImpl = ((BufferValidator)buffer).GetImpl();

			mCommandBuffer.DrawIndexedIndirect(bufferImpl, offset, drawNum, stride);
		}

		public override void Dispatch(uint32 x, uint32 y, uint32 z)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't record dispatch call: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't record dispatch call: this operation is allowed only outside render pass.");

			mCommandBuffer.Dispatch(x, y, z);
		}

		public override void DispatchIndirect(Buffer buffer, uint64 offset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't record dispatch call: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't record dispatch call: this operation is allowed only outside render pass.");

			Buffer bufferImpl = ((BufferValidator)buffer).GetImpl();

			mCommandBuffer.DispatchIndirect(bufferImpl, offset);
		}

		public override void BeginQuery(QueryPool queryPool, uint32 offset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't begin query: the command buffer must be in the recording state.");

			QueryPoolValidator queryPoolVal = (QueryPoolValidator)queryPool;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), queryPoolVal.GetQueryType() != QueryType.TIMESTAMP, void(),
				"Can't begin query: BeginQuery() is not supported for timestamp queries.");

			if (!queryPoolVal.IsImported())
			{
				RETURN_ON_FAILURE!(mDevice.GetLogger(), offset < queryPoolVal.GetQueryNum(), void(),
					"Can't begin query: the offset ('{}') is out of range.", offset);

				ref ValidationCommandUseQuery validationCommand = ref AllocateValidationCommand<ValidationCommandUseQuery>();
				validationCommand.type = ValidationCommandType.BEGIN_QUERY;
				validationCommand.queryPool = queryPool;
				validationCommand.queryPoolOffset = offset;
			}

			QueryPool queryPoolImpl = ((QueryPoolValidator)queryPool).GetImpl();

			mCommandBuffer.BeginQuery(queryPoolImpl, offset);
		}

		public override void EndQuery(QueryPool queryPool, uint32 offset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't end query: the command buffer must be in the recording state.");

			QueryPoolValidator queryPoolVal = (QueryPoolValidator)queryPool;

			if (!queryPoolVal.IsImported())
			{
				RETURN_ON_FAILURE!(mDevice.GetLogger(), offset < queryPoolVal.GetQueryNum(), void(),
					"Can't end query: the offset ('{}') is out of range.", offset);

				ref ValidationCommandUseQuery validationCommand = ref AllocateValidationCommand<ValidationCommandUseQuery>();
				validationCommand.type = ValidationCommandType.END_QUERY;
				validationCommand.queryPool = queryPool;
				validationCommand.queryPoolOffset = offset;
			}

			QueryPool queryPoolImpl = ((QueryPoolValidator)queryPool).GetImpl();

			mCommandBuffer.EndQuery(queryPoolImpl, offset);
		}

		public override void BeginAnnotation(System.StringView name)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't copy queries: the command buffer must be in the recording state.");

			m_AnnotationStack++;
			mCommandBuffer.BeginAnnotation(name);
		}

		public override void EndAnnotation()
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't copy queries: the command buffer must be in the recording state.");

			mCommandBuffer.EndAnnotation();
			m_AnnotationStack--;
		}

		public override void ClearStorageBuffer(ClearStorageBufferDesc clearDesc)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't clear storage buffer: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't clear storage buffer: this operation is not allowed in render pass.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), clearDesc.storageBuffer != null, void(),
				"Can't clear storage buffer: 'clearDesc.storageBuffer' is invalid.");

			var clearDescImpl = clearDesc;
			clearDescImpl.storageBuffer = ((DescriptorValidator)clearDesc.storageBuffer).GetImpl();

			mCommandBuffer.ClearStorageBuffer(clearDescImpl);
		}

		public override void ClearStorageTexture(ClearStorageTextureDesc clearDesc)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't clear storage texture: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't clear storage texture: this operation is not allowed in render pass.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), clearDesc.storageTexture != null, void(),
				"Can't clear storage texture: 'clearDesc.storageTexture' is invalid.");

			var clearDescImpl = clearDesc;
			clearDescImpl.storageTexture = ((DescriptorValidator)clearDesc.storageTexture).GetImpl();

			mCommandBuffer.ClearStorageTexture(clearDescImpl);
		}

		public override void CopyBuffer(Buffer dstBuffer, uint32 dstPhysicalDeviceIndex, uint64 dstOffset, Buffer srcBuffer, uint32 srcPhysicalDeviceIndex, uint64 srcOffset, uint64 size)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't copy buffer: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't copy buffer: this operation is allowed only outside render pass.");

			if (size == WHOLE_SIZE)
			{
				readonly ref BufferDesc dstDesc = ref ((BufferValidator)dstBuffer).GetDesc();
				readonly ref BufferDesc srcDesc = ref ((BufferValidator)srcBuffer).GetDesc();

				if (dstDesc.size != srcDesc.size)
				{
					REPORT_WARNING(mDevice.GetLogger(), "WHOLE_SIZE is used but 'dstBuffer' and 'srcBuffer' have diffenet sizes. 'srcDesc.size' bytes will be copied to the destination.");
					return;
				}
			}

			Buffer dstBufferImpl = ((BufferValidator)dstBuffer).GetImpl();
			Buffer srcBufferImpl = ((BufferValidator)srcBuffer).GetImpl();

			mCommandBuffer.CopyBuffer(dstBufferImpl, dstPhysicalDeviceIndex, dstOffset, srcBufferImpl, srcPhysicalDeviceIndex,
				srcOffset, size);
		}

		public override void CopyTexture(Texture dstTexture, uint32 dstPhysicalDeviceIndex, TextureRegionDesc* dstRegionDesc, Texture srcTexture, uint32 srcPhysicalDeviceIndex, TextureRegionDesc* srcRegionDesc)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't copy texture: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't copy texture: this operation is allowed only outside render pass.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), (dstRegionDesc == null && srcRegionDesc == null) || (dstRegionDesc != null && srcRegionDesc != null), void(),
				"Can't copy texture: 'dstRegionDesc' and 'srcRegionDesc' must be valid pointers or be both NULL.");

			Texture dstTextureImpl = ((TextureValidator)dstTexture).GetImpl();
			Texture srcTextureImpl = ((TextureValidator)srcTexture).GetImpl();

			mCommandBuffer.CopyTexture(dstTextureImpl, dstPhysicalDeviceIndex, dstRegionDesc, srcTextureImpl, srcPhysicalDeviceIndex,
				srcRegionDesc);
		}

		public override void UploadBufferToTexture(Texture dstTexture, TextureRegionDesc dstRegionDesc, Buffer srcBuffer, TextureDataLayoutDesc srcDataLayoutDesc)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't upload buffer to texture: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't upload buffer to texture: this operation is allowed only outside render pass.");

			Texture dstTextureImpl = ((TextureValidator)dstTexture).GetImpl();
			Buffer srcBufferImpl = ((BufferValidator)srcBuffer).GetImpl();

			mCommandBuffer.UploadBufferToTexture(dstTextureImpl, dstRegionDesc, srcBufferImpl, srcDataLayoutDesc);
		}

		public override void ReadbackTextureToBuffer(Buffer dstBuffer, ref TextureDataLayoutDesc dstDataLayoutDesc, Texture srcTexture, TextureRegionDesc srcRegionDesc)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't readback texture to buffer: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't readback texture to buffer: this operation is allowed only outside render pass.");

			Buffer dstBufferImpl = ((BufferValidator)dstBuffer).GetImpl();
			Texture srcTextureImpl = ((TextureValidator)srcTexture).GetImpl();

			mCommandBuffer.ReadbackTextureToBuffer(dstBufferImpl, ref dstDataLayoutDesc, srcTextureImpl, srcRegionDesc);
		}

		public override void CopyQueries(QueryPool queryPool, uint32 offset, uint32 num, Buffer dstBuffer, uint64 dstOffset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't copy queries: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't copy queries: this operation is allowed only outside render pass.");

			QueryPoolValidator queryPoolVal = (QueryPoolValidator)queryPool;

			if (!queryPoolVal.IsImported())
			{
				RETURN_ON_FAILURE!(mDevice.GetLogger(), offset + num <= queryPoolVal.GetQueryNum(), void(),
					"Can't copy queries: offset + num ('{}') is out of range.", offset + num);
			}

			QueryPool queryPoolImpl = ((QueryPoolValidator)queryPool).GetImpl();
			Buffer dstBufferImpl = ((BufferValidator)dstBuffer).GetImpl();

			mCommandBuffer.CopyQueries(queryPoolImpl, offset, num, dstBufferImpl, dstOffset);
		}

		public override void ResetQueries(QueryPool queryPool, uint32 offset, uint32 num)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't reset queries: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't reset queries: this operation is allowed only outside render pass.");

			QueryPoolValidator queryPoolVal = (QueryPoolValidator)queryPool;

			if (!queryPoolVal.IsImported())
			{
				RETURN_ON_FAILURE!(mDevice.GetLogger(), offset + num <= queryPoolVal.GetQueryNum(), void(),
					"Can't reset queries: offset + num ('{}') is out of range.", offset + num);

				ref ValidationCommandResetQuery validationCommand = ref AllocateValidationCommand<ValidationCommandResetQuery>();
				validationCommand.type = ValidationCommandType.RESET_QUERY;
				validationCommand.queryPool = queryPool;
				validationCommand.queryPoolOffset = offset;
				validationCommand.queryNum = num;
			}

			QueryPool queryPoolImpl = ((QueryPoolValidator)queryPool).GetImpl();

			mCommandBuffer.ResetQueries(queryPoolImpl, offset, num);
		}

		public override void BuildTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset, AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't build TLAS: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't build TLAS: this operation is allowed only outside render pass.");

			BufferValidator bufferVal = (BufferValidator)buffer;
			BufferValidator scratchVal = (BufferValidator)scratch;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), bufferOffset < bufferVal.GetDesc().size, void(),
				"Can't update TLAS: 'bufferOffset' is out of bounds.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), scratchOffset < scratchVal.GetDesc().size, void(),
				"Can't update TLAS: 'scratchOffset' is out of bounds.");

			AccelerationStructure dstImpl = ((AccelerationStructureValidator)dst).GetImpl();
			Buffer scratchImpl = ((BufferValidator)scratch).GetImpl();
			Buffer bufferImpl = ((BufferValidator)buffer).GetImpl();

			mCommandBuffer.BuildTopLevelAccelerationStructure(instanceNum, bufferImpl, bufferOffset, flags, dstImpl, scratchImpl, scratchOffset);
		}

		public override void BuildBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects, AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't build BLAS: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't build BLAS: this operation is allowed only outside render pass.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), geometryObjects != null, void(),
				"Can't update BLAS: 'geometryObjects' is invalid.");

			BufferValidator scratchVal = (BufferValidator)scratch;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), scratchOffset < scratchVal.GetDesc().size, void(),
				"Can't build BLAS: 'scratchOffset' is out of bounds.");

			AccelerationStructure dstImpl = ((AccelerationStructureValidator)dst).GetImpl();
			Buffer scratchImpl = ((BufferValidator)scratch).GetImpl();

			List<GeometryObject> objectImplArray = scope .() { Count = geometryObjectNum };
			ConvertGeometryObjectsVal(objectImplArray.Ptr, geometryObjects, geometryObjectNum);

			mCommandBuffer.BuildBottomLevelAccelerationStructure(geometryObjectNum, objectImplArray.Ptr, flags, dstImpl, scratchImpl, scratchOffset);
		}

		public override void UpdateTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset, AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't update TLAS: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't update TLAS: this operation is allowed only outside render pass.");

			BufferValidator bufferVal = (BufferValidator)buffer;
			BufferValidator scratchVal = (BufferValidator)scratch;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), bufferOffset < bufferVal.GetDesc().size, void(),
				"Can't update TLAS: 'bufferOffset' is out of bounds.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), scratchOffset < scratchVal.GetDesc().size, void(),
				"Can't update TLAS: 'scratchOffset' is out of bounds.");

			AccelerationStructure dstImpl = ((AccelerationStructureValidator)dst).GetImpl();
			AccelerationStructure srcImpl = ((AccelerationStructureValidator)src).GetImpl();
			Buffer scratchImpl = ((BufferValidator)scratch).GetImpl();
			Buffer bufferImpl = ((BufferValidator)buffer).GetImpl();

			mCommandBuffer.UpdateTopLevelAccelerationStructure(instanceNum, bufferImpl, bufferOffset, flags, dstImpl, srcImpl, scratchImpl, scratchOffset);
		}

		public override void UpdateBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects, AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't update BLAS: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't update BLAS: this operation is allowed only outside render pass.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), geometryObjects != null, void(),
				"Can't update BLAS: 'geometryObjects' is invalid.");

			BufferValidator scratchVal = (BufferValidator)scratch;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), scratchOffset < scratchVal.GetDesc().size, void(),
				"Can't update BLAS: 'scratchOffset' is out of bounds.");

			AccelerationStructure dstImpl = ((AccelerationStructureValidator)dst).GetImpl();
			AccelerationStructure srcImpl = ((AccelerationStructureValidator)src).GetImpl();
			Buffer scratchImpl = ((BufferValidator)scratch).GetImpl();

			List<GeometryObject> objectImplArray = scope .() { Count = geometryObjectNum };
			ConvertGeometryObjectsVal(objectImplArray.Ptr, geometryObjects, geometryObjectNum);

			mCommandBuffer.UpdateBottomLevelAccelerationStructure(geometryObjectNum, objectImplArray.Ptr, flags, dstImpl, srcImpl, scratchImpl, scratchOffset);
		}

		public override void CopyAccelerationStructure(AccelerationStructure dst, AccelerationStructure src, CopyMode copyMode)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't copy AS: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't copy AS: this operation is allowed only outside render pass.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), copyMode < CopyMode.MAX_NUM, void(),
				"Can't copy AS: 'copyMode' is invalid.");

			AccelerationStructure dstImpl = ((AccelerationStructureValidator)dst).GetImpl();
			AccelerationStructure srcImpl = ((AccelerationStructureValidator)src).GetImpl();

			mCommandBuffer.CopyAccelerationStructure(dstImpl, srcImpl, copyMode);
		}

		public override void WriteAccelerationStructureSize(AccelerationStructure* accelerationStructures, uint32 accelerationStructureNum, QueryPool queryPool, uint32 queryOffset)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't write AS size: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't write AS size: this operation is allowed only outside render pass.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), accelerationStructures != null, void(),
				"Can't write AS size: 'accelerationStructures' is invalid.");

			AccelerationStructure* accelerationStructureArray = scope:: List<AccelerationStructure>() { Count = accelerationStructureNum }.Ptr; //STACK_ALLOC(AccelerationStructure*, accelerationStructureNum);
			for (uint32 i = 0; i < accelerationStructureNum; i++)
			{
				RETURN_ON_FAILURE!(mDevice.GetLogger(), accelerationStructures[i] != null, void(),
					"Can't write AS size: 'accelerationStructures[{}]' is invalid.", i);

				accelerationStructureArray[i] = ((AccelerationStructureValidator)accelerationStructures[i]).GetImpl();
			}

			QueryPool queryPoolImpl = ((QueryPoolValidator)queryPool).GetImpl();

			mCommandBuffer.WriteAccelerationStructureSize(accelerationStructures, accelerationStructureNum, queryPoolImpl, queryOffset);
		}

		public override void DispatchRays(DispatchRaysDesc dispatchRaysDesc)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_IsRecordingStarted, void(),
				"Can't record ray tracing dispatch: the command buffer must be in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), m_FrameBuffer == null, void(),
				"Can't record ray tracing dispatch: this operation is allowed only outside render pass.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dispatchRaysDesc.raygenShader.buffer != null, void(),
				"Can't record ray tracing dispatch: 'dispatchRaysDesc.raygenShader.buffer' is invalid.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dispatchRaysDesc.raygenShader.size != 0, void(),
				"Can't record ray tracing dispatch: 'dispatchRaysDesc.raygenShader.size' is 0.");

			readonly uint64 SBTAlignment = mDevice.GetDesc().rayTracingShaderTableAligment;

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dispatchRaysDesc.raygenShader.offset % SBTAlignment == 0, void(),
				"Can't record ray tracing dispatch: 'dispatchRaysDesc.raygenShader.offset' is misaligned.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dispatchRaysDesc.missShaders.offset % SBTAlignment == 0, void(),
				"Can't record ray tracing dispatch: 'dispatchRaysDesc.missShaders.offset' is misaligned.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dispatchRaysDesc.hitShaderGroups.offset % SBTAlignment == 0, void(),
				"Can't record ray tracing dispatch: 'dispatchRaysDesc.hitShaderGroups.offset' is misaligned.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), dispatchRaysDesc.callableShaders.offset % SBTAlignment == 0, void(),
				"Can't record ray tracing dispatch: 'dispatchRaysDesc.callableShaders.offset' is misaligned.");

			var dispatchRaysDescImpl = dispatchRaysDesc;
			dispatchRaysDescImpl.raygenShader.buffer = ((BufferValidator)dispatchRaysDesc.raygenShader.buffer).GetImpl();
			dispatchRaysDescImpl.missShaders.buffer = ((BufferValidator)dispatchRaysDesc.missShaders.buffer).GetImpl();
			dispatchRaysDescImpl.hitShaderGroups.buffer = ((BufferValidator)dispatchRaysDesc.hitShaderGroups.buffer).GetImpl();
			dispatchRaysDescImpl.callableShaders.buffer = ((BufferValidator)dispatchRaysDesc.callableShaders.buffer).GetImpl();

			mCommandBuffer.DispatchRays(dispatchRaysDescImpl);
		}

		public override void DispatchMeshTasks(uint32 taskNum)
		{
			readonly uint32 meshTaskMaxNum = mDevice.GetDesc().meshTaskMaxNum;

			if (taskNum > meshTaskMaxNum)
			{
				REPORT_ERROR(mDevice.GetLogger(),
					"Can't dispatch the specified number of mesh tasks: the number exceeds the maximum number of mesh tasks.");
			}

			mCommandBuffer.DispatchMeshTasks(Math.Min(taskNum, meshTaskMaxNum));
		}
	}
}
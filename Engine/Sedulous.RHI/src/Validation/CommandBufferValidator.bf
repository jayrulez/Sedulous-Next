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

	class CommandBufferValidator : CommandBuffer
	{
		private readonly DeviceValidator mDevice;
		private readonly CommandBuffer mCommandBuffer;

		List<uint8> m_ValidationCommands = new .() ~ delete _;
		bool m_IsRecordingStarted = false;
		FrameBuffer m_FrameBuffer = null;
		int32 m_AnnotationStack = 0;

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

		public override void SetDebugName(System.StringView name)
		{
			mCommandBuffer.SetDebugName(name);
		}

		public override Result Begin(DescriptorPool descriptorPool, uint32 physicalDeviceIndex)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), !m_IsRecordingStarted, Result.FAILURE,
			    "Can't begin recording of CommandBuffer: the command buffer is already in the recording state.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), physicalDeviceIndex < mDevice.GetPhysicalDeviceNum(), Result.FAILURE,
			    "Can't begin recording of CommandBuffer: 'physicalDeviceIndex' is invalid.");

			Result result = mCommandBuffer.Begin(descriptorPool, physicalDeviceIndex);
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
		}

		public override void SetPipelineLayout(PipelineLayout pipelineLayout)
		{
		}

		public override void SetDescriptorSets(uint32 baseSlot, uint32 descriptorSetNum, DescriptorSet* descriptorSets, uint32* dynamicConstantBufferOffsets)
		{
		}

		public override void SetConstants(uint32 pushConstantIndex, void* data, uint32 size)
		{
		}

		public override void SetDescriptorPool(DescriptorPool descriptorPool)
		{
		}

		public override void PipelineBarrier(TransitionBarrierDesc* transitionBarriers, AliasingBarrierDesc* aliasingBarriers, BarrierDependency dependency)
		{
		}

		public override void BeginRenderPass(FrameBuffer frameBuffer, RenderPassBeginFlag renderPassBeginFlag)
		{
		}

		public override void EndRenderPass()
		{
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
		}

		public override void SetDepthBounds(float boundsMin, float boundsMax)
		{
		}

		public override void SetStencilReference(uint8 reference)
		{
		}

		public override void SetSamplePositions(SamplePosition* positions, uint32 positionNum)
		{
		}

		public override void ClearAttachments(ClearDesc* clearDescs, uint32 clearDescNum, Rect* rects, uint32 rectNum)
		{
		}

		public override void SetIndexBuffer(Buffer buffer, uint64 offset, IndexType indexType)
		{
		}

		public override void SetVertexBuffers(uint32 baseSlot, uint32 bufferNum, Buffer* buffers, uint64* offsets)
		{
		}

		public override void Draw(uint32 vertexNum, uint32 instanceNum, uint32 baseVertex, uint32 baseInstance)
		{
		}

		public override void DrawIndexed(uint32 indexNum, uint32 instanceNum, uint32 baseIndex, uint32 baseVertex, uint32 baseInstance)
		{
		}

		public override void DrawIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
		{
		}

		public override void DrawIndexedIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
		{
		}

		public override void Dispatch(uint32 x, uint32 y, uint32 z)
		{
		}

		public override void DispatchIndirect(Buffer buffer, uint64 offset)
		{
		}

		public override void BeginQuery(QueryPool queryPool, uint32 offset)
		{
		}

		public override void EndQuery(QueryPool queryPool, uint32 offset)
		{
		}

		public override void BeginAnnotation(System.StringView name)
		{
		}

		public override void EndAnnotation()
		{
		}

		public override void ClearStorageBuffer(ClearStorageBufferDesc clearDesc)
		{
		}

		public override void ClearStorageTexture(ClearStorageTextureDesc clearDesc)
		{
		}

		public override void CopyBuffer(Buffer dstBuffer, uint32 dstPhysicalDeviceIndex, uint64 dstOffset, Buffer srcBuffer, uint32 srcPhysicalDeviceIndex, uint64 srcOffset, uint64 size)
		{
		}

		public override void CopyTexture(Texture dstTexture, uint32 dstPhysicalDeviceIndex, TextureRegionDesc* dstRegionDesc, Texture srcTexture, uint32 srcPhysicalDeviceIndex, TextureRegionDesc* srcRegionDesc)
		{
		}

		public override void UploadBufferToTexture(Texture dstTexture, TextureRegionDesc dstRegionDesc, Buffer srcBuffer, TextureDataLayoutDesc srcDataLayoutDesc)
		{
		}

		public override void ReadbackTextureToBuffer(Buffer dstBuffer, ref TextureDataLayoutDesc dstDataLayoutDesc, Texture srcTexture, TextureRegionDesc srcRegionDesc)
		{
		}

		public override void CopyQueries(QueryPool queryPool, uint32 offset, uint32 num, Buffer dstBuffer, uint64 dstOffset)
		{
		}

		public override void ResetQueries(QueryPool queryPool, uint32 offset, uint32 num)
		{
		}

		public override void BuildTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset, AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset)
		{
		}

		public override void BuildBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects, AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset)
		{
		}

		public override void UpdateTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset, AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset)
		{
		}

		public override void UpdateBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects, AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset)
		{
		}

		public override void CopyAccelerationStructure(AccelerationStructure dst, AccelerationStructure src, CopyMode copyMode)
		{
		}

		public override void WriteAccelerationStructureSize(AccelerationStructure* accelerationStructures, uint32 accelerationStructureNum, QueryPool queryPool, uint32 queryPoolOffset)
		{
		}

		public override void DispatchRays(DispatchRaysDesc dispatchRaysDesc)
		{
		}

		public override void DispatchMeshTasks(uint32 taskNum)
		{
		}
	}
}
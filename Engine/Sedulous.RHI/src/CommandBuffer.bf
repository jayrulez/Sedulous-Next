using System;
namespace Sedulous.RHI
{
	abstract class CommandBuffer
	{
		public abstract void SetDebugName(in StringView name);

		public abstract Result Begin(DescriptorPool* descriptorPool, uint32 physicalDeviceIndex);
		public abstract Result End();

		public abstract void SetPipeline(in Pipeline pipeline);
		public abstract void SetPipelineLayout(in PipelineLayout pipelineLayout);
		public abstract void SetDescriptorSets(uint32 baseSlot, uint32 descriptorSetNum, in DescriptorSet* descriptorSets, in uint32* dynamicConstantBufferOffsets);
		public abstract void SetConstants(uint32 pushConstantIndex, in void* data, uint32 size);
		public abstract void SetDescriptorPool(in DescriptorPool descriptorPool);
		public abstract void PipelineBarrier(in TransitionBarrierDesc* transitionBarriers, AliasingBarrierDesc* aliasingBarriers, BarrierDependency dependency);

		public abstract void BeginRenderPass(in FrameBuffer frameBuffer, RenderPassBeginFlag renderPassBeginFlag);
		public abstract void EndRenderPass();
		public abstract void SetViewports(in Viewport* viewports, uint32 viewportNum);
		public abstract void SetScissors(in Rect* rects, uint32 rectNum);
		public abstract void SetDepthBounds(float boundsMin, float boundsMax);
		public abstract void SetStencilReference(uint8 reference);
		public abstract void SetSamplePositions(in SamplePosition* positions, uint32 positionNum);
		public abstract void ClearAttachments(in ClearDesc* clearDescs, uint32 clearDescNum, in Rect* rects, uint32 rectNum);
		public abstract void SetIndexBuffer(in Buffer buffer, uint64 offset, IndexType indexType);
		public abstract void SetVertexBuffers(uint32 baseSlot, uint32 bufferNum, in Buffer* buffers, in uint64* offsets);

		public abstract void Draw(uint32 vertexNum, uint32 instanceNum, uint32 baseVertex, uint32 baseInstance);
		public abstract void DrawIndexed(uint32 indexNum, uint32 instanceNum, uint32 baseIndex, uint32 baseVertex, uint32 baseInstance);
		public abstract void DrawIndirect(in Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride);
		public abstract void DrawIndexedIndirect(in Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride);
		public abstract void Dispatch(uint32 x, uint32 y, uint32 z);
		public abstract void DispatchIndirect(in Buffer buffer, uint64 offset);
		public abstract void BeginQuery(in QueryPool queryPool, uint32 offset);
		public abstract void EndQuery(in QueryPool queryPool, uint32 offset);
		public abstract void BeginAnnotation(in StringView name);
		public abstract void EndAnnotation();

		public abstract void ClearStorageBuffer(in ClearStorageBufferDesc clearDesc);

		public abstract void ClearStorageTexture(in ClearStorageTextureDesc clearDesc);

		public abstract void CopyBuffer(Buffer dstBuffer, uint32 dstPhysicalDeviceIndex, uint64 dstOffset, in Buffer srcBuffer,
			uint32 srcPhysicalDeviceIndex, uint64 srcOffset, uint64 size);

		public abstract void CopyTexture(ref Texture dstTexture, uint32 dstPhysicalDeviceIndex, in TextureRegionDesc* dstRegionDesc,
			in Texture srcTexture, uint32 srcPhysicalDeviceIndex, in TextureRegionDesc* srcRegionDesc);

		public abstract void UploadBufferToTexture(Texture dstTexture, in TextureRegionDesc dstRegionDesc, in Buffer srcBuffer,
			in TextureDataLayoutDesc srcDataLayoutDesc);

		public abstract void ReadbackTextureToBuffer(ref Buffer dstBuffer, ref TextureDataLayoutDesc dstDataLayoutDesc, in Texture srcTexture,
			in TextureRegionDesc srcRegionDesc);

		public abstract void CopyQueries(in QueryPool queryPool, uint32 offset, uint32 num, ref Buffer dstBuffer, uint64 dstOffset);
		public abstract void ResetQueries(in QueryPool queryPool, uint32 offset, uint32 num);

		public abstract void BuildTopLevelAccelerationStructure(uint32 instanceNum, in Buffer buffer, uint64 bufferOffset,
			AccelerationStructureBuildBits flags, ref AccelerationStructure dst, ref Buffer scratch, uint64 scratchOffset);

		public abstract void BuildBottomLevelAccelerationStructure(uint32 geometryObjectNum, in GeometryObject* geometryObjects,
			AccelerationStructureBuildBits flags, ref AccelerationStructure dst, ref Buffer scratch, uint64 scratchOffset);

		public abstract void UpdateTopLevelAccelerationStructure(uint32 instanceNum, in Buffer buffer, uint64 bufferOffset,
			AccelerationStructureBuildBits flags, ref AccelerationStructure dst, in AccelerationStructure src, ref Buffer scratch,
			uint64 scratchOffset);

		public abstract void UpdateBottomLevelAccelerationStructure(uint32 geometryObjectNum, in GeometryObject* geometryObjects,
			AccelerationStructureBuildBits flags, ref AccelerationStructure dst, in AccelerationStructure src, ref Buffer scratch,
			uint64 scratchOffset);

		public abstract void CopyAccelerationStructure(ref AccelerationStructure dst, in AccelerationStructure src, CopyMode copyMode);

		public abstract void WriteAccelerationStructureSize(in AccelerationStructure* accelerationStructures,
			uint32 accelerationStructureNum, ref QueryPool queryPool, uint32 queryPoolOffset);

		public abstract void DispatchRays(in DispatchRaysDesc dispatchRaysDesc);
		public abstract void DispatchMeshTasks(uint32 taskNum);
	}
}
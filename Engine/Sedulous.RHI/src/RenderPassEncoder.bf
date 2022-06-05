using System;
namespace Sedulous.RHI
{
	abstract class RenderPassEncoder
	{
		public abstract void BindDescriptorSet(in DescriptorSet set);
		public abstract void SetViewport(float x, float y, float width, float height, float minDepth, float maxDepth);
		public abstract void SetScissor(uint32 x, uint32 y, uint32 width, uint32 height);
		public abstract void BindPipeline(in GraphicsPipeline pipeline);
		public abstract void BindVertexBuffers(in Span<Buffer> buffers, in Span<uint32> strides, in Span<uint32> offsets);
		public abstract void BindIndexBuffer(in Buffer buffer, uint32 indexStride, uint64 offset);
		public abstract void PushConstants(in RootSignature rootSignature, char8* name, void* data);
		public abstract void Draw(uint32 vertexCount, uint32 firstVertex);
		public abstract void DrawInstanced(uint32 vertex_count, uint32 first_vertex, uint32 instance_count, uint32 first_instance);
		public abstract void DrawIndexed(uint32 indexCount, uint32 firstIndex, uint32 firstVertex);
		public abstract void DrawIndexedInstanced(uint32 indexCount, uint32 firstIndex, uint32 instanceCount, uint32 firstInstance, uint32 firstVertex);
	}
}
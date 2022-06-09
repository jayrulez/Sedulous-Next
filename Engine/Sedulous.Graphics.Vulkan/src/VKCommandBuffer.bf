using System;
using System.Text;
using Bulkan;
using Sedulous.Graphics;
using Sedulous.Graphics.Raytracing;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;
	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;
	using static Sedulous.Graphics.Vulkan.VKHelpers;

	/// <summary>
	/// The Vulkan implementation of a command buffer Object.
	/// </summary>
	public class VKCommandBuffer : CommandBuffer
	{
		internal VkCommandBuffer CommandBuffer;

		private VKGraphicsContext context;

		private VKCommandQueue commandQueue;

		private VKFrameBufferBase activeFrameBuffer;

		private VKGraphicsPipelineState currentGraphicsPipelineState;

		private VKComputePipelineState currentComputePipelineState;

		private VKRaytracingPipelineState currentRaytracingPipelineState;

		private PipelineState activePipelineState;

		private VkRect2D[] rawRectangles;

		private VkViewport[] rawViewports;

		private VkBuffer[] vertexBuffers;

		private uint64[] vertexOffsets;

		private VkCommandPool commandPool;

		private String name;

		private bool disposed;

		/// <inheritdoc />
		protected override GraphicsContext GraphicsContext => context;

		/// <inheritdoc />
		public override String Name
		{
			get
			{
				return name;
			}
			set
			{
				name = value;
				context.SetDebugName(VkObjectType.VK_OBJECT_TYPE_COMMAND_BUFFER, (uint64)(int64)CommandBuffer.Handle, scope String(name)..Append("_CommandBuffer"));
				context.SetDebugName(VkObjectType.VK_OBJECT_TYPE_COMMAND_POOL, commandPool.Handle, scope String(name)..Append("_CommandPool"));
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKCommandBuffer" /> class.
		/// </summary>
		/// <param name="context">Graphics Context.</param>
		/// <param name="queue">The commandqueue for this commandbuffer.</param>
		public  this(VKGraphicsContext context, VKCommandQueue queue)
		{
			this.context = context;
			commandQueue = queue;
			VkCommandPoolCreateInfo vkCommandPoolCreateInfo = VkCommandPoolCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
				flags = VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
			};
			switch (commandQueue.QueueType)
			{
			case CommandQueueType.Graphics:
				vkCommandPoolCreateInfo.queueFamilyIndex = (uint32)this.context.QueueIndices.GraphicsFamily;
				break;
			case CommandQueueType.Compute:
				vkCommandPoolCreateInfo.queueFamilyIndex = (uint32)this.context.QueueIndices.ComputeFamily;
				break;
			case CommandQueueType.Copy:
				vkCommandPoolCreateInfo.queueFamilyIndex = (uint32)this.context.QueueIndices.CopyFamily;
				break;
			}
			VkDevice vkDevice = this.context.VkDevice;
			VkCommandPool vkCommandPool = default(VkCommandPool);
			VulkanNative.vkCreateCommandPool(vkDevice, &vkCommandPoolCreateInfo, null, &vkCommandPool);
			commandPool = vkCommandPool;
			VkCommandBufferAllocateInfo vkCommandBufferAllocateInfo = VkCommandBufferAllocateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
				commandPool = commandPool,
				commandBufferCount = 1,
				level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY
			};
			VkCommandBuffer commandBuffer = default(VkCommandBuffer);
			VulkanNative.vkAllocateCommandBuffers(vkDevice, &vkCommandBufferAllocateInfo, &commandBuffer);
			CommandBuffer = commandBuffer;
		}

		/// <inheritdoc />
		protected  override void BeginRenderPassInternal(ref RenderPassDescription description)
		{
			FrameBuffer frameBuffer = description.FrameBuffer;
			ClearValue clearValue = description.ClearValue;
			if (clearValue.Flags == ClearFlags.None)
			{
				FrameBufferAttachment[] colorTargets = frameBuffer.ColorTargets;
				for (FrameBufferAttachment frameBufferAttachment in colorTargets)
				{
					(frameBufferAttachment.Texture as VKTexture).TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, 0, 1u, 0, 1u);
				}
				if (frameBuffer.DepthStencilTarget.HasValue)
				{
					(frameBuffer.DepthStencilTarget.Value.Texture as VKTexture).TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, 0, 1u, 0, 1u);
				}
			}
			if (activeFrameBuffer == null || activeFrameBuffer != frameBuffer)
			{
				if (activeFrameBuffer != null && activeFrameBuffer != frameBuffer)
				{
					activeFrameBuffer.TransitionToFinalLayout(CommandBuffer);
				}
				if (frameBuffer is VKSwapChainFrameBuffer)
				{
					activeFrameBuffer = frameBuffer as VKSwapChainFrameBuffer;
				}
				else
				{
					activeFrameBuffer = frameBuffer as VKFrameBuffer;
				}
			}
			VkRenderPassBeginInfo vkRenderPassBeginInfo = default(VkRenderPassBeginInfo);
			vkRenderPassBeginInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
			vkRenderPassBeginInfo.renderArea = VkRect2D(frameBuffer.Width, frameBuffer.Height);
			VKSwapChainFrameBuffer vKSwapChainFrameBuffer = frameBuffer as VKSwapChainFrameBuffer;
			if (vKSwapChainFrameBuffer != null)
			{
				vkRenderPassBeginInfo.framebuffer = vKSwapChainFrameBuffer.CurrentBackBuffer;
				vKSwapChainFrameBuffer.FrameBuffers[0].GetRenderPass(clearValue.Flags, out vkRenderPassBeginInfo.renderPass);
			}
			else
			{
				VKFrameBuffer vKFrameBuffer = frameBuffer as VKFrameBuffer;
				if (vKFrameBuffer != null)
				{
					vkRenderPassBeginInfo.framebuffer = vKFrameBuffer.NativeFrameBuffer;
					vKFrameBuffer.GetRenderPass(clearValue.Flags, out vkRenderPassBeginInfo.renderPass);
				}
			}
			VulkanNative.vkCmdBeginRenderPass(CommandBuffer, &vkRenderPassBeginInfo, VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE);
			VkClearValue clearValue2 = default(VkClearValue);
			VkClearAttachment vkClearAttachment;
			VkClearRect vkClearRect;
			if ((clearValue.Flags & ClearFlags.Target) == ClearFlags.Target)
			{
				for (uint32 num = 0u; num < frameBuffer.ColorTargets.Count; num++)
				{
					Vector4 vector = clearValue.ColorValues[num];
					clearValue2.color = VkClearColorValue(vector.X, vector.Y, vector.Z, vector.W);
					vkClearAttachment = default(VkClearAttachment);
					vkClearAttachment.colorAttachment = num;
					vkClearAttachment.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
					vkClearAttachment.clearValue = clearValue2;
					VkClearAttachment vkClearAttachment2 = vkClearAttachment;
					Texture attachmentTexture = frameBuffer.ColorTargets[num].AttachmentTexture;
					vkClearRect = default(VkClearRect);
					vkClearRect.baseArrayLayer = 0u;
					vkClearRect.layerCount = 1u;
					vkClearRect.rect = VkRect2D(0, 0, attachmentTexture.Description.Width, attachmentTexture.Description.Height);
					VkClearRect vkClearRect2 = vkClearRect;
					VulkanNative.vkCmdClearAttachments(CommandBuffer, 1u, &vkClearAttachment2, 1u, &vkClearRect2);
				}
			}
			if ((clearValue.Flags & ClearFlags.Depth) == ClearFlags.Depth || (clearValue.Flags & ClearFlags.Stencil) == ClearFlags.Stencil)
			{
				bool flag = Helpers.IsStencilFormat(frameBuffer.DepthStencilTarget.Value.AttachmentTexture.Description.Format);
				vkClearAttachment = default(VkClearAttachment);
				vkClearAttachment.aspectMask = (flag ? (VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT) : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
				vkClearAttachment.clearValue = VkClearValue
				{
					depthStencil = VkClearDepthStencilValue
					{
						depth = clearValue.Depth,
						stencil = clearValue.Stencil
					}
				};
				VkClearAttachment vkClearAttachment3 = vkClearAttachment;
				Texture attachmentTexture2 = frameBuffer.DepthStencilTarget.Value.AttachmentTexture;
				vkClearRect = default(VkClearRect);
				vkClearRect.baseArrayLayer = 0u;
				vkClearRect.layerCount = 1u;
				vkClearRect.rect = VkRect2D(0, 0, attachmentTexture2.Description.Width, attachmentTexture2.Description.Height);
				VkClearRect vkClearRect3 = vkClearRect;
				VulkanNative.vkCmdClearAttachments(CommandBuffer, 1u, &vkClearAttachment3, 1u, &vkClearRect3);
			}
		}

		/// <inheritdoc />
		protected override void EndRenderPassInternal()
		{
			VulkanNative.vkCmdEndRenderPass(CommandBuffer);
			activeFrameBuffer.TransitionToIntermedialLayout(CommandBuffer);
		}

		/// <inheritdoc />
		public  override void Begin()
		{
			if (base.State == CommandBufferState.Recording)
			{
				GraphicsContext.ValidationLayer?.Notify("Vulkan", "Begin cannot be called again until End has been successfully called");
			}
			VkCommandBufferBeginInfo vkCommandBufferBeginInfo = default(VkCommandBufferBeginInfo);
			vkCommandBufferBeginInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
			vkCommandBufferBeginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
			VulkanNative.vkBeginCommandBuffer(CommandBuffer, &vkCommandBufferBeginInfo);
			activeFrameBuffer = null;
			base.State = CommandBufferState.Recording;
		}

		/// <inheritdoc />
		protected override void EndInternal()
		{
			activeFrameBuffer?.TransitionToFinalLayout(CommandBuffer);
			activeFrameBuffer = null;
			if (base.State == CommandBufferState.Initial)
			{
				GraphicsContext.ValidationLayer?.Notify("Vulkan", "End was called, but Begin has not yet been called. You mush call Begin successfully before you can call End.");
			}
			VulkanNative.vkEndCommandBuffer(CommandBuffer);
			base.State = CommandBufferState.Executable;
		}

		/// <inheritdoc />
		public override void Reset()
		{
			base.State = CommandBufferState.Initial;
		}

		/// <inheritdoc />
		public override void Commit()
		{
			if (base.State == CommandBufferState.Commited)
			{
				GraphicsContext.ValidationLayer?.Notify("Vulkan", "This commandbuffer was already committed.");
			}
			if (base.State != CommandBufferState.Executable)
			{
				GraphicsContext.ValidationLayer?.Notify("Vulkan", "You mush record some command before to execute a commandbuffer. Call begin...end methods before to commit.");
			}
			commandQueue.CommitCommandBuffer(this);
			base.State = CommandBufferState.Commited;
		}

		/// <inheritdoc />
		public override void Dispatch(uint32 threadGroupCountX, uint32 threadGroupCountY, uint32 threadGroupCountZ)
		{
			VulkanNative.vkCmdDispatch(CommandBuffer, threadGroupCountX, threadGroupCountY, threadGroupCountZ);
		}

		/// <inheritdoc />
		public override void DispatchIndirect(Sedulous.Graphics.Buffer argBuffer, uint32 offset)
		{
			VKBuffer vKBuffer = argBuffer as VKBuffer;
			VulkanNative.vkCmdDispatchIndirect(CommandBuffer, vKBuffer.NativeBuffer, offset);
		}

		/// <inheritdoc />
		public override void Draw(uint32 vertexCount, uint32 startVertexLocation = 0)
		{
			VulkanNative.vkCmdDraw(CommandBuffer, vertexCount, 1, startVertexLocation, 0);
		}

		/// <inheritdoc />
		public override void DrawIndexed(uint32 indexCount, uint32 startIndexLocation = 0, uint32 baseVertexLocation = 0)
		{
			VulkanNative.vkCmdDrawIndexed(CommandBuffer, indexCount, 1u, startIndexLocation, (int32)baseVertexLocation, 0);
		}

		/// <inheritdoc />
		public override void DrawIndexedInstanced(uint32 indexCountPerInstance, uint32 instanceCount, uint32 startIndexLocation = 0, uint32 baseVertexLocation = 0, uint32 startInstanceLocation = 0)
		{
			VulkanNative.vkCmdDrawIndexed(CommandBuffer, indexCountPerInstance, instanceCount, startIndexLocation, (int32)baseVertexLocation, startInstanceLocation);
		}

		/// <inheritdoc />
		public override void DrawIndexedInstancedIndirect(Sedulous.Graphics.Buffer argBuffer, uint32 offset, uint32 drawCount, uint32 stride)
		{
			if ((argBuffer.Description.Flags & BufferFlags.IndirectBuffer) == 0)
			{
				GraphicsContext.ValidationLayer?.Notify("Vulkan", "DrawIndexedInstancedIndirect must be an argBuffer with IndirectBuffer flag");
			}
			VKBuffer vKBuffer = argBuffer as VKBuffer;
			VulkanNative.vkCmdDrawIndexedIndirect(CommandBuffer, vKBuffer.NativeBuffer, offset, drawCount, stride);
		}

		/// <inheritdoc />
		public override void DrawInstanced(uint32 vertexCountPerInstance, uint32 instanceCount, uint32 startVertexLocation = 0, uint32 startInstanceLocation = 0)
		{
			VulkanNative.vkCmdDraw(CommandBuffer, vertexCountPerInstance, instanceCount, startVertexLocation, startInstanceLocation);
		}

		/// <inheritdoc />
		public override void DrawInstancedIndirect(Sedulous.Graphics.Buffer argBuffer, uint32 offset, uint32 drawCount, uint32 stride)
		{
			VKBuffer vKBuffer = argBuffer as VKBuffer;
			VulkanNative.vkCmdDrawIndirect(CommandBuffer, vKBuffer.NativeBuffer, offset, drawCount, stride);
		}

		/// <inheritdoc />
		public override void SetIndexBuffer(Sedulous.Graphics.Buffer buffer, IndexFormat format = IndexFormat.UInt16, uint32 offset = 0)
		{
			VKBuffer vKBuffer = buffer as VKBuffer;
			VkIndexType indexType = format.ToVulkan();
			VulkanNative.vkCmdBindIndexBuffer(CommandBuffer, vKBuffer.NativeBuffer, offset, indexType);
		}

		/// <inheritdoc />
		protected  override void SetGraphicsPipelineStateInternal(GraphicsPipelineState pipeline)
		{
			VKGraphicsPipelineState vKGraphicsPipelineState = pipeline as VKGraphicsPipelineState;
			VulkanNative.vkCmdBindPipeline(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS, vKGraphicsPipelineState.NativePipeline);
			currentGraphicsPipelineState = vKGraphicsPipelineState;
			activePipelineState = vKGraphicsPipelineState;
			if (!currentGraphicsPipelineState.Description.RenderStates.RasterizerState.ScissorEnable)
			{
				VkRect2D vkRect2D = VkRect2D(0, 0, 15360, 8640);
				VulkanNative.vkCmdSetScissor(CommandBuffer, 0, 1u, &vkRect2D);
			}
		}

		/// <inheritdoc />
		protected override void SetComputePipelineStateInternal(ComputePipelineState pipeline)
		{
			VKComputePipelineState vKComputePipelineState = pipeline as VKComputePipelineState;
			VulkanNative.vkCmdBindPipeline(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_COMPUTE, vKComputePipelineState.NativePipeline);
			currentComputePipelineState = vKComputePipelineState;
			activePipelineState = vKComputePipelineState;
		}

		/// <inheritdoc />
		protected override void SetRaytracingPipelineStateInternal(RaytracingPipelineState pipeline)
		{
			VKRaytracingPipelineState vKRaytracingPipelineState = pipeline as VKRaytracingPipelineState;
			VulkanNative.vkCmdBindPipeline(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR, vKRaytracingPipelineState.NativePipeline);
			currentRaytracingPipelineState = vKRaytracingPipelineState;
			activePipelineState = vKRaytracingPipelineState;
		}

		/// <inheritdoc />
		public  override void SetResourceSet(ResourceSet resourceSet, uint32 index, uint32[] offsets)
		{
			VKResourceSet vKResourceSet = resourceSet as VKResourceSet;
			for (int32 i = 0; i < vKResourceSet.StorageTextures.Count; i++)
			{
				VKTexture vKTexture = vKResourceSet.StorageTextures[i];
				vKTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_GENERAL, 0, vKTexture.Description.MipLevels, 0, vKTexture.Description.ArraySize);
			}
			for (int32 j = 0; j < vKResourceSet.Textures.Count; j++)
			{
				VKTexture vKTexture2 = vKResourceSet.Textures[j];
				vKTexture2.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, 0, vKTexture2.Description.MipLevels, 0, vKTexture2.Description.ArraySize);
			}
			VkDescriptorSet descriptorSet = vKResourceSet.DescriptorAllocationToken.DescriptorSet;
			uint32* ptr = scope uint32[(int32)vKResourceSet.DynamicBufferCount]*;
			if (vKResourceSet.DynamicBufferCount != 0 && offsets != null)
			{
				if (offsets.Count < vKResourceSet.DynamicBufferCount)
				{
					GraphicsContext.ValidationLayer?.Notify("Vulkan", "offsets error.");
				}
				else
				{
					for (int k = 0; k < vKResourceSet.DynamicBufferCount; k++)
					{
						ptr[k] = offsets[k];
					}
				}
			}
			if (activePipelineState is VKGraphicsPipelineState)
			{
				VulkanNative.vkCmdBindDescriptorSets(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS, currentGraphicsPipelineState.NativePipelineLayout, 0, 1u, &descriptorSet, vKResourceSet.DynamicBufferCount, ptr);
			}
			else if (activePipelineState is VKComputePipelineState)
			{
				VulkanNative.vkCmdBindDescriptorSets(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_COMPUTE, currentComputePipelineState.NativePipelineLayout, 0, 1u, &descriptorSet, vKResourceSet.DynamicBufferCount, ptr);
			}
			else if (activePipelineState is VKRaytracingPipelineState)
			{
				VulkanNative.vkCmdBindDescriptorSets(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR, currentRaytracingPipelineState.NativePipelineLayout, 0, 1u, &descriptorSet, vKResourceSet.DynamicBufferCount, ptr);
			}
			else
			{
				context.ValidationLayer.Notify("VK", "PipelineState type not supported!");
			}
		}

		/// <inheritdoc />
		public  override void SetScissorRectangles(Rect[] rectangles)
		{
			VKGraphicsPipelineState vKGraphicsPipelineState = currentGraphicsPipelineState;
			if (vKGraphicsPipelineState == null || vKGraphicsPipelineState.Description.RenderStates.RasterizerState.ScissorEnable)
			{
				ArrayHelpers.EnsureArraySize(ref rawRectangles, rectangles.Count);
				for (int32 i = 0; i < rectangles.Count; i++)
				{
					Rect rectangle = rectangles[i];
					rawRectangles[i] = VkRect2D((.)rectangle.X, (.)rectangle.Y, (.)rectangle.Width, (.)rectangle.Height);
				}
				VkRect2D* pScissors = rawRectangles.Ptr;
				{
					VulkanNative.vkCmdSetScissor(CommandBuffer, 0, (uint32)rectangles.Count, pScissors);
				}
			}
		}

		/// <inheritdoc />
		public  override void SetVertexBuffer(uint32 slot, Sedulous.Graphics.Buffer buffer, uint32 offset = 0)
		{
			VKBuffer obj = buffer as VKBuffer;
			uint64 num = offset;
			VkBuffer nativeBuffer = obj.NativeBuffer;
			VulkanNative.vkCmdBindVertexBuffers(CommandBuffer, slot, 1u, &nativeBuffer, &num);
		}

		/// <inheritdoc />
		public  override void SetVertexBuffers(Sedulous.Graphics.Buffer[] buffers, int32[] offsets)
		{
			ArrayHelpers.EnsureArraySize(ref vertexBuffers, buffers.Count);
			ArrayHelpers.EnsureArraySize(ref vertexOffsets, buffers.Count);
			for (int32 i = 0; i < buffers.Count; i++)
			{
				vertexBuffers[i] = (buffers[i] as VKBuffer).NativeBuffer;
				vertexOffsets[i] = (uint64)((offsets != null) ? offsets[i] : 0);
			}
			VkBuffer* pBuffers = vertexBuffers.Ptr;
			{
				uint64* pOffsets = vertexOffsets.Ptr;
				{
					VulkanNative.vkCmdBindVertexBuffers(CommandBuffer, 0, (uint32)buffers.Count, pBuffers, pOffsets);
				}
			}
		}

		/// <inheritdoc />
		public  override void SetViewports(Viewport[] viewports)
		{
			ArrayHelpers.EnsureArraySize(ref rawViewports, viewports.Count);
			for (int32 i = 0; i < viewports.Count; i++)
			{
				Viewport viewport = viewports[i];
				float y = (context.ClipSpaceYInvertedSupported ? (viewport.Height + viewport.Y) : viewport.Y);
				float height = (context.ClipSpaceYInvertedSupported ? (0f - viewport.Height) : viewport.Height);
				rawViewports[i] = VkViewport
				{
					x = viewport.X,
					y = y,
					width = viewport.Width,
					height = height,
					minDepth = viewport.MinDepth,
					maxDepth = viewport.MaxDepth
				};
			}
			VkViewport* pViewports = rawViewports.Ptr;
			{
				VulkanNative.vkCmdSetViewport(CommandBuffer, 0, (uint32)rawViewports.Count, pViewports);
			}
		}

		/// <summary>
		/// Sets a resource barrier for a texture.
		/// </summary>
		/// <param name="buffer">The buffer.</param>
		public  override void ResourceBarrierUnorderedAccessView(Sedulous.Graphics.Buffer buffer)
		{
			VkBufferMemoryBarrier vkBufferMemoryBarrier = default(VkBufferMemoryBarrier);
			vkBufferMemoryBarrier.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
			vkBufferMemoryBarrier.buffer = (buffer as VKBuffer).NativeBuffer;
			vkBufferMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
			vkBufferMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT | VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT;
			vkBufferMemoryBarrier.srcQueueFamilyIndex = uint32.MaxValue;
			vkBufferMemoryBarrier.dstQueueFamilyIndex = uint32.MaxValue;
			vkBufferMemoryBarrier.size = uint64.MaxValue;
			VulkanNative.vkCmdPipelineBarrier(CommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.None, 0, null, 1u, &vkBufferMemoryBarrier, 0, null);
		}

		/// <summary>
		/// Sets a resource barrier for a texture.
		/// </summary>
		/// <param name="texture">The texture.</param>
		public  override void ResourceBarrierUnorderedAccessView(Texture texture)
		{
			VkImageMemoryBarrier vkImageMemoryBarrier = default(VkImageMemoryBarrier);
			vkImageMemoryBarrier.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
			vkImageMemoryBarrier.image = (texture as VKTexture).NativeImage;
			vkImageMemoryBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
			vkImageMemoryBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT | VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT;
			vkImageMemoryBarrier.srcQueueFamilyIndex = uint32.MaxValue;
			vkImageMemoryBarrier.dstQueueFamilyIndex = uint32.MaxValue;
			VulkanNative.vkCmdPipelineBarrier(CommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.None, 0, null, 0, null, 1u, &vkImageMemoryBarrier);
		}

		/// <inheritdoc />
		public  override void GenerateMipmaps(Texture texture)
		{
			VKTexture vKTexture = texture as VKTexture;
			TextureDescription description = vKTexture.Description;
			vKTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, 0, 1u, 0, description.ArraySize);
			vKTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1u, description.MipLevels - 1, 0, description.ArraySize);
			uint32 num = description.MipLevels - 1;
			VkImageBlit* ptr = scope VkImageBlit[(int32)num]*;
			for (uint32 num2 = 1u; num2 < description.MipLevels; num2++)
			{
				uint32 num3 = num2 - 1;
				VkImageSubresourceLayers vkImageSubresourceLayers = (ptr[num3].srcSubresource = VkImageSubresourceLayers
				{
					aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
					baseArrayLayer = 0,
					layerCount = description.ArraySize,
					mipLevel = 0
				});
				ptr[num3].srcOffsets[0] = default(VkOffset3D);
				VkOffset3D vkOffset3D = (ptr[num3].srcOffsets[1] = VkOffset3D
				{
					x = (int32)description.Width,
					y = (int32)description.Height,
					z = (int32)description.Depth
				});
				vkImageSubresourceLayers = (ptr[num3].dstSubresource = VkImageSubresourceLayers
				{
					aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
					baseArrayLayer = 0,
					layerCount = description.ArraySize,
					mipLevel = num2
				});
				ptr[num3].dstOffsets[0] = default(VkOffset3D);
				Helpers.GetMipDimensions(description, num2, var width, var height, var depth);
				vkOffset3D = (ptr[num3].dstOffsets[1] = VkOffset3D
				{
					x = (int32)width,
					y = (int32)height,
					z = (int32)depth
				});
			}
			VkFormatProperties vkFormatProperties = default(VkFormatProperties);
			VulkanNative.vkGetPhysicalDeviceFormatProperties(context.VkPhysicalDevice, vKTexture.Format, &vkFormatProperties);
			VkFilter filter = VkFilter.VK_FILTER_NEAREST;
			if ((vkFormatProperties.optimalTilingFeatures & VkFormatFeatureFlags.VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_IMG) != 0)
			{
				filter = VkFilter.VK_FILTER_CUBIC_IMG;
			}
			else if ((vkFormatProperties.optimalTilingFeatures & VkFormatFeatureFlags.VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) != 0)
			{
				filter = VkFilter.VK_FILTER_LINEAR;
			}
			VulkanNative.vkCmdBlitImage(CommandBuffer, vKTexture.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vKTexture.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, num, ptr, filter);
			if ((description.Flags & TextureFlags.ShaderResource) != 0)
			{
				vKTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, 0, 1u, 0, description.ArraySize);
				vKTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, 1u, description.MipLevels - 1, 0, description.ArraySize);
			}
		}

		/// <inheritdoc />
		protected override void CopyBufferDataToInternal(Sedulous.Graphics.Buffer origin, Sedulous.Graphics.Buffer destination, uint32 sizeInBytes, uint32 sourceOffset = 0, uint32 destinationOffset = 0)
		{
			(origin as VKBuffer).CopyTo(CommandBuffer, commandQueue.QueueType, destination, sizeInBytes, sourceOffset, destinationOffset);
		}

		/// <inheritdoc />
		protected override void CopyTextureDataToInternal(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 width, uint32 height, uint32 depth, uint32 layerCount)
		{
			(source as VKTexture).CopyTo(CommandBuffer, sourceX, sourceY, sourceZ, sourceMipLevel, sourceBasedArrayLayer, destination, destinationX, destinationY, destinationZ, destinationMipLevel, destinationBasedArrayLayer, width, height, depth, layerCount);
		}

		/// <inheritdoc />
		protected override void Blit(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 layerCount)
		{
			(source as VKTexture).Blit(CommandBuffer, sourceX, sourceY, sourceZ, sourceMipLevel, sourceBasedArrayLayer, destination, destinationX, destinationY, destinationZ, destinationMipLevel, destinationBasedArrayLayer, layerCount);
		}

		/// <inheritdoc />
		protected override void UpdateBufferDataInternal(Sedulous.Graphics.Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
		{
			(buffer as VKBuffer).SetData(CommandBuffer, source, sourceSizeInBytes, destinationOffsetInBytes);
		}

		/// <inheritdoc />
		public  override void BeginDebugMarker(String label)
		{
			if (context.DebugMarkerEnabled && !String.IsNullOrEmpty(label))
			{
				VkDebugUtilsLabelEXT vkDebugUtilsLabelEXT = default(VkDebugUtilsLabelEXT);
				vkDebugUtilsLabelEXT.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT;
				vkDebugUtilsLabelEXT.pLabelName = label.CStr();
				VkDebugUtilsLabelEXT vkDebugUtilsLabelEXT2 = vkDebugUtilsLabelEXT;
				VulkanNative.vkCmdBeginDebugUtilsLabelEXT(CommandBuffer, &vkDebugUtilsLabelEXT2);
			}
		}

		/// <inheritdoc />
		public override void EndDebugMarker()
		{
			if (context.DebugMarkerEnabled)
			{
				VulkanNative.vkCmdEndDebugUtilsLabelEXT(CommandBuffer);
			}
		}

		/// <inheritdoc />
		public  override void InsertDebugMarker(String label)
		{
			if (context.DebugMarkerEnabled && !String.IsNullOrEmpty(label))
			{
				VkDebugUtilsLabelEXT vkDebugUtilsLabelEXT = default(VkDebugUtilsLabelEXT);
				vkDebugUtilsLabelEXT.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT;
				vkDebugUtilsLabelEXT.pLabelName = label.CStr();
				VkDebugUtilsLabelEXT vkDebugUtilsLabelEXT2 = vkDebugUtilsLabelEXT;
				VulkanNative.vkCmdInsertDebugUtilsLabelEXT(CommandBuffer, &vkDebugUtilsLabelEXT2);
			}
		}

		/// <inheritdoc />
		public override void WriteTimestamp(QueryHeap heap, uint32 index)
		{
			VKQueryHeap vKQueryHeap = (VKQueryHeap)heap;
			VulkanNative.vkCmdWriteTimestamp(CommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, vKQueryHeap.nativeQueryHeap, index);
		}

		/// <inheritdoc />
		public override void BeginQuery(QueryHeap heap, uint32 index)
		{
			VKQueryHeap vKQueryHeap = (VKQueryHeap)heap;
			switch (heap.Description.Type)
			{
			case QueryType.Occlusion:
				VulkanNative.vkCmdBeginQuery(CommandBuffer, vKQueryHeap.nativeQueryHeap, index, VkQueryControlFlags.VK_QUERY_CONTROL_PRECISE_BIT);
				break;
			case QueryType.BinaryOcclusion:
				VulkanNative.vkCmdBeginQuery(CommandBuffer, vKQueryHeap.nativeQueryHeap, index, VkQueryControlFlags.None);
				break;
			default:
				break;
			}
		}

		/// <inheritdoc />
		public override void EndQuery(QueryHeap heap, uint32 index)
		{
			VKQueryHeap vKQueryHeap = (VKQueryHeap)heap;
			VulkanNative.vkCmdEndQuery(CommandBuffer, vKQueryHeap.nativeQueryHeap, index);
		}

		/// <inheritdoc />
		public override BottomLevelAS BuildRaytracingAccelerationStructure(BottomLevelASDescription description)
		{
			var description;

			return new VKBottomLevelAS(context, CommandBuffer, ref description);
		}

		/// <inheritdoc />
		public override TopLevelAS BuildRaytracingAccelerationStructure(TopLevelASDescription description)
		{
			var description;

			return new VKTopLevelAS(context, CommandBuffer, ref description);
		}

		/// <inheritdoc />
		public override void UpdateRaytracingAccelerationStructure(ref TopLevelAS tlas, TopLevelASDescription newDescription)
		{
			var newDescription;

			((VKTopLevelAS)tlas).UpdateAccelerationStructure(CommandBuffer, ref newDescription);
		}

		/// <inheritdoc />
		public  override void DispatchRays(DispatchRaysDescription description)
		{
			VKShaderTable shaderBindingTable = currentRaytracingPipelineState.shaderBindingTable;
			VkStridedDeviceAddressRegionKHR vkStridedDeviceAddressRegionKHR = default(VkStridedDeviceAddressRegionKHR);
			vkStridedDeviceAddressRegionKHR.deviceAddress = shaderBindingTable.GetRayGenStartAddress();
			vkStridedDeviceAddressRegionKHR.stride = shaderBindingTable.GetRayGenStride();
			vkStridedDeviceAddressRegionKHR.size = shaderBindingTable.GetRayGenSize();
			VkStridedDeviceAddressRegionKHR vkStridedDeviceAddressRegionKHR2 = vkStridedDeviceAddressRegionKHR;
			vkStridedDeviceAddressRegionKHR = default(VkStridedDeviceAddressRegionKHR);
			vkStridedDeviceAddressRegionKHR.deviceAddress = shaderBindingTable.GetMissStartAddress();
			vkStridedDeviceAddressRegionKHR.stride = shaderBindingTable.GetMissStride();
			vkStridedDeviceAddressRegionKHR.size = shaderBindingTable.GetMissSize();
			VkStridedDeviceAddressRegionKHR vkStridedDeviceAddressRegionKHR3 = vkStridedDeviceAddressRegionKHR;
			vkStridedDeviceAddressRegionKHR = default(VkStridedDeviceAddressRegionKHR);
			vkStridedDeviceAddressRegionKHR.deviceAddress = shaderBindingTable.GetHitGroupStartAddress();
			vkStridedDeviceAddressRegionKHR.stride = shaderBindingTable.GetHitGroupStride();
			vkStridedDeviceAddressRegionKHR.size = shaderBindingTable.GetHitGroupSize();
			VkStridedDeviceAddressRegionKHR vkStridedDeviceAddressRegionKHR4 = vkStridedDeviceAddressRegionKHR;
			VkStridedDeviceAddressRegionKHR vkStridedDeviceAddressRegionKHR5 = default(VkStridedDeviceAddressRegionKHR);
			VulkanNative.vkCmdTraceRaysKHR(CommandBuffer, &vkStridedDeviceAddressRegionKHR2, &vkStridedDeviceAddressRegionKHR3, &vkStridedDeviceAddressRegionKHR4, &vkStridedDeviceAddressRegionKHR5, description.Width, description.Height, description.Depth);
		}

		/// <inheritdoc />
		public override void Dispose()
		{
			//Dispose(disposing: true);
			//GC.SuppressFinalize(this);
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing">
		/// <c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.
		/// </param>
		protected  virtual void Dispose(bool disposing)
		{
			if (!disposed)
			{
				if (disposing)
				{
					VulkanNative.vkDestroyCommandPool(context.VkDevice, commandPool, null);
				}
				disposed = true;
			}
		}
	}
}

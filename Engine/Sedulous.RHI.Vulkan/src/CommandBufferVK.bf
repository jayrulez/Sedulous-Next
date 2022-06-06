using Bulkan;
using System;
using static Bulkan.VulkanNative;
using static Sedulous.RHI.Vulkan.VulkanUtils;
namespace Sedulous.RHI.Vulkan
{
	struct Barriers
	{
		public VkBufferMemoryBarrier* buffers;
		public VkImageMemoryBarrier* images;
		public uint32 bufferNum;
		public uint32 imageNum;
	}

	class CommandBufferVK : CommandBuffer
	{
		private VkCommandBuffer m_Handle = .Null;
		private uint32 m_PhysicalDeviceIndex = 0;
		private DeviceVK m_Device;
		private CommandQueueType m_Type = (CommandQueueType)0;
		private VkPipelineBindPoint m_CurrentPipelineBindPoint = (.)uint32.MaxValue;
		private VkPipelineLayout m_CurrentPipelineLayoutHandle = .Null;
		private PipelineVK m_CurrentPipeline = null;
		private PipelineLayoutVK m_CurrentPipelineLayout = null;
		private FrameBufferVK m_CurrentFrameBuffer = null;
		private VkCommandPool m_CommandPool = .Null;

		 //////////////////////////////Private Methods//////////////////////////////

		private void FillAliasingBufferBarriers(in AliasingBarrierDesc aliasing, ref Barriers barriers)
		{
			for (uint32 i = 0; i < aliasing.bufferNum; i++)
			{
				readonly ref BufferAliasingBarrierDesc barrierDesc = ref aliasing.buffers[i];
				readonly BufferVK bufferImpl = (BufferVK)barrierDesc.after;

				barriers.buffers[barriers.bufferNum++] = .()
					{
						sType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
						pNext = null,
						srcAccessMask = (VkAccessFlags)0,
						dstAccessMask = VulkanUtils.GetAccessFlags(barrierDesc.nextAccess),
						srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
						dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
						buffer = bufferImpl.GetHandle(m_PhysicalDeviceIndex),
						offset = 0,
						size = VulkanNative.VK_WHOLE_SIZE
					};
			}
		}

		private void FillAliasingImageBarriers(in AliasingBarrierDesc aliasing, ref Barriers barriers)
		{
			for (uint32 i = 0; i < aliasing.textureNum; i++)
			{
				readonly ref TextureAliasingBarrierDesc barrierDesc = ref aliasing.textures[i];
				readonly TextureVK textureImpl = (TextureVK)barrierDesc.after;

				barriers.images[barriers.imageNum++] = .()
					{
						sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
						pNext = null,
						srcAccessMask = (VkAccessFlags)0,
						dstAccessMask = VulkanUtils.GetAccessFlags(barrierDesc.nextAccess),
						oldLayout = .VK_IMAGE_LAYOUT_UNDEFINED,
						newLayout = VulkanUtils.GetImageLayout(barrierDesc.nextLayout),
						srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
						dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
						image = textureImpl.GetHandle(m_PhysicalDeviceIndex),
						subresourceRange = VkImageSubresourceRange()
							{
								aspectMask = textureImpl.GetImageAspectFlags(),
								baseMipLevel = 0,
								levelCount = VulkanNative.VK_REMAINING_MIP_LEVELS,
								baseArrayLayer = 0,
								layerCount = VulkanNative.VK_REMAINING_ARRAY_LAYERS
							}
					};
			}
		}

		private void FillTransitionBufferBarriers(in TransitionBarrierDesc transitions, ref Barriers barriers)
		{
			for (uint32 i = 0; i < transitions.bufferNum; i++)
			{
				readonly ref BufferTransitionBarrierDesc barrierDesc = ref transitions.buffers[i];

				ref VkBufferMemoryBarrier barrier = ref barriers.buffers[barriers.bufferNum++];
				readonly BufferVK bufferImpl = (BufferVK)barrierDesc.buffer;

				barrier = .()
					{
						sType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
						pNext = null,
						srcAccessMask = VulkanUtils.GetAccessFlags(barrierDesc.prevAccess),
						dstAccessMask = VulkanUtils.GetAccessFlags(barrierDesc.nextAccess),
						srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
						dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
						buffer = bufferImpl.GetHandle(m_PhysicalDeviceIndex),
						offset = 0,
						size = VulkanNative.VK_WHOLE_SIZE
					};
			}
		}

		private void FillTransitionImageBarriers(in TransitionBarrierDesc transitions, ref Barriers barriers)
		{
			for (uint32 i = 0; i < transitions.textureNum; i++)
			{
				readonly ref TextureTransitionBarrierDesc barrierDesc = ref transitions.textures[i];

				ref VkImageMemoryBarrier barrier = ref barriers.images[barriers.imageNum++];
				readonly TextureVK textureImpl = (TextureVK)barrierDesc.texture;

				barrier = .()
					{
						sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
						pNext = null,
						srcAccessMask = VulkanUtils.GetAccessFlags(barrierDesc.prevAccess),
						dstAccessMask = VulkanUtils.GetAccessFlags(barrierDesc.nextAccess),
						oldLayout = VulkanUtils.GetImageLayout(barrierDesc.prevLayout),
						newLayout = VulkanUtils.GetImageLayout(barrierDesc.nextLayout),
						srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
						dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
						image = textureImpl.GetHandle(m_PhysicalDeviceIndex),
						subresourceRange = VkImageSubresourceRange()
							{
								aspectMask = textureImpl.GetImageAspectFlags(),
								baseMipLevel = barrierDesc.mipOffset,
								levelCount = (barrierDesc.mipNum == REMAINING_MIP_LEVELS) ? VulkanNative.VK_REMAINING_MIP_LEVELS : barrierDesc.mipNum,
								baseArrayLayer = barrierDesc.arrayOffset,
								layerCount = (barrierDesc.arraySize == REMAINING_ARRAY_LAYERS) ? VulkanNative.VK_REMAINING_ARRAY_LAYERS : barrierDesc.arraySize
							}
					};
			}
		}

		private void CopyWholeTexture(in TextureVK dstTexture, uint32 dstPhysicalDeviceIndex, in TextureVK srcTexture, uint32 srcPhysicalDeviceIndex)
		{
			VkImageCopy* regions = STACK_ALLOC!<VkImageCopy>(dstTexture.GetMipNum());

			for (uint32 i = 0; i < dstTexture.GetMipNum(); i++)
			{
				regions[i].srcSubresource = .()
					{
						aspectMask = srcTexture.GetImageAspectFlags(),
						mipLevel = i,
						baseArrayLayer = 0,
						layerCount = srcTexture.GetArraySize()
					};

				regions[i].dstSubresource = .()
					{
						aspectMask = dstTexture.GetImageAspectFlags(),
						mipLevel = i,
						baseArrayLayer = 0,
						layerCount = dstTexture.GetArraySize()
					};

				regions[i].dstOffset = .() { };
				regions[i].srcOffset = .() { };
				regions[i].extent = dstTexture.GetExtent();
			}

			vkCmdCopyImage(m_Handle,
				srcTexture.GetHandle(srcPhysicalDeviceIndex), .VK_IMAGE_LAYOUT_GENERAL,
				dstTexture.GetHandle(dstPhysicalDeviceIndex), .VK_IMAGE_LAYOUT_GENERAL,
				dstTexture.GetMipNum(), regions);
		}

		 ///////////////////////////////////////////////////////////////////////////

		 /////////////////////////////Internal Methods//////////////////////////////
		public static implicit operator VkCommandBuffer(Self self) => self.m_Handle;

		public readonly ref DeviceVK GetDevice() => ref m_Device;

		public void Create(VkCommandPool commandPool, VkCommandBuffer commandBuffer, CommandQueueType type)
		{
			m_CommandPool = commandPool;
			m_Handle = commandBuffer;
			m_Type = type;
		}

		public Result Create(in CommandBufferVulkanDesc commandBufferDesc)
		{
			m_CommandPool = .Null;
			m_Handle = (VkCommandBuffer)commandBufferDesc.vkCommandBuffer;
			m_Type = commandBufferDesc.commandQueueType;

			return Result.SUCCESS;
		}
		 ///////////////////////////////////////////////////////////////////////////

		public this(DeviceVK device)
		{
			m_Device = device;
		}

		public ~this()
		{
			if (m_CommandPool == .Null)
				return;

			vkFreeCommandBuffers(m_Device, m_CommandPool, 1, &m_Handle);
		}

		public override void SetDebugName(in StringView name)
		{
			m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_COMMAND_BUFFER, (uint64)m_Handle.Handle, name);
		}

		public override Result Begin(DescriptorPool* descriptorPool, uint32 physicalDeviceIndex)
		{
			//MaybeUnused(descriptorPool);

			m_PhysicalDeviceIndex = physicalDeviceIndex;

			VkCommandBufferBeginInfo info = .()
				{
					sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
					pNext = null,
					flags = (VkCommandBufferUsageFlags)0,
					pInheritanceInfo = null
				};

			VkDeviceGroupCommandBufferBeginInfo deviceGroupInfo;
			if (m_Device.GetPhyiscalDeviceGroupSize() > 1)
			{
				deviceGroupInfo = .()
					{
						sType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_COMMAND_BUFFER_BEGIN_INFO,
						pNext = null,
						deviceMask = 1u << physicalDeviceIndex
					};

				info.pNext = &deviceGroupInfo;
			}

			readonly VkResult result = vkBeginCommandBuffer(m_Handle, &info);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't begin a command buffer: vkBeginCommandBuffer returned {0}.", (int32)result);

			if (m_Type == CommandQueueType.GRAPHICS)
				vkCmdSetDepthBounds(m_Handle, 0.0f, 1.0f);

			m_CurrentPipelineBindPoint = (.)uint32.MaxValue; ///*VK_PIPELINE_BIND_POINT_MAX_ENUM*/;
			m_CurrentPipelineLayoutHandle = .Null;
			m_CurrentPipelineLayout = null;
			m_CurrentPipeline = null;
			m_CurrentFrameBuffer = null;

			return Result.SUCCESS;
		}

		public override Result End()
		{
			readonly VkResult result = vkEndCommandBuffer(m_Handle);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't end a command buffer: vkEndCommandBuffer returned {0}.", (int32)result);

			return Result.SUCCESS;
		}

		public override void SetPipeline(in Pipeline pipeline)
		{
			if (m_CurrentPipeline == (PipelineVK)pipeline)
				return;

			readonly PipelineVK pipelineImpl = (PipelineVK)pipeline;

			vkCmdBindPipeline(m_Handle, pipelineImpl.GetBindPoint(), pipelineImpl);
			m_CurrentPipeline = pipelineImpl;
		}

		public override void SetPipelineLayout(in PipelineLayout pipelineLayout)
		{
			readonly PipelineLayoutVK pipelineLayoutVK = (PipelineLayoutVK)pipelineLayout;

			m_CurrentPipelineLayout = pipelineLayoutVK;
			m_CurrentPipelineLayoutHandle = pipelineLayoutVK;
			m_CurrentPipelineBindPoint = pipelineLayoutVK.GetPipelineBindPoint();
		}

		public override void SetDescriptorSets(uint32 baseIndex, uint32 setNum, in DescriptorSet* descriptorSets, in uint32* offsets)
		{
			VkDescriptorSet* sets = STACK_ALLOC!<VkDescriptorSet>(setNum);
			uint32 dynamicOffsetNum = 0;

			for (uint32 i = 0; i < setNum; i++)
			{
				readonly DescriptorSetVK descriptorSetImpl = (DescriptorSetVK)descriptorSets[i];

				sets[i] = descriptorSetImpl.GetHandle(m_PhysicalDeviceIndex);
				dynamicOffsetNum += descriptorSetImpl.GetDynamicConstantBufferNum();
			}

			vkCmdBindDescriptorSets(
				m_Handle,
				m_CurrentPipelineBindPoint,
				m_CurrentPipelineLayoutHandle,
				baseIndex,
				setNum,
				sets,
				dynamicOffsetNum,
				offsets);
		}

		public override void SetConstants(uint32 pushConstantIndex, in void* data, uint32 size)
		{
			readonly ref RuntimeBindingInfo bindingInfo = ref m_CurrentPipelineLayout.GetRuntimeBindingInfo();
			readonly ref PushConstantRangeBindingDesc desc = ref bindingInfo.pushConstantBindings[pushConstantIndex];

			vkCmdPushConstants(m_Handle, m_CurrentPipelineLayoutHandle, desc.flags, desc.offset, size, data);
		}

		public override void SetDescriptorPool(in DescriptorPool descriptorPool)
		{
			//MaybeUnused(descriptorPool);
		}

		public override void PipelineBarrier(in TransitionBarrierDesc* transitionBarriers, AliasingBarrierDesc* aliasingBarriers, BarrierDependency dependency)
		{
	//MaybeUnused(dependency); // TODO: use it or remove, because it's needed only for VK

			Barriers barriers = .() { };

			barriers.bufferNum = transitionBarriers != null ? transitionBarriers.bufferNum : 0;
			barriers.bufferNum += aliasingBarriers != null ? aliasingBarriers.bufferNum : 0;

			barriers.buffers = STACK_ALLOC!<VkBufferMemoryBarrier>(barriers.bufferNum);
			barriers.bufferNum = 0;

			if (aliasingBarriers != null)
				FillAliasingBufferBarriers(*aliasingBarriers, ref barriers);
			if (transitionBarriers != null)
				FillTransitionBufferBarriers(*transitionBarriers, ref barriers);

			barriers.imageNum = transitionBarriers != null ? transitionBarriers.textureNum : 0;
			barriers.imageNum += aliasingBarriers != null ? aliasingBarriers.textureNum : 0;

			barriers.images = STACK_ALLOC!<VkImageMemoryBarrier>(barriers.imageNum);
			barriers.imageNum = 0;

			if (aliasingBarriers != null)
				FillAliasingImageBarriers(*aliasingBarriers, ref barriers);
			if (transitionBarriers != null)
				FillTransitionImageBarriers(*transitionBarriers, ref barriers);

	// TODO: more optimal srcStageMask and dstStageMask
			vkCmdPipelineBarrier(
				m_Handle,
				.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
				.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
				0,
				0,
				null,
				barriers.bufferNum,
				barriers.buffers,
				barriers.imageNum,
				barriers.images);
		}

		public override void BeginRenderPass(in FrameBuffer frameBuffer, RenderPassBeginFlag renderPassBeginFlag)
		{
			readonly FrameBufferVK frameBufferImpl = (FrameBufferVK)frameBuffer;

			readonly uint32 attachmentNum = frameBufferImpl.GetAttachmentNum();
			VkClearValue* values = STACK_ALLOC!<VkClearValue>(attachmentNum);
			frameBufferImpl.GetClearValues(values);

			VkRenderPassBeginInfo info = .()
				{
					sType = .VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
					pNext = null,
					renderPass = frameBufferImpl.GetRenderPass(renderPassBeginFlag),
					framebuffer = frameBufferImpl.GetHandle(m_PhysicalDeviceIndex),
					renderArea = frameBufferImpl.GetRenderArea(),
					clearValueCount = attachmentNum,
					pClearValues = values
				};

			vkCmdBeginRenderPass(m_Handle, &info, .VK_SUBPASS_CONTENTS_INLINE);

			m_CurrentFrameBuffer = frameBufferImpl;
		}

		public override void EndRenderPass()
		{
			vkCmdEndRenderPass(m_Handle);
		}

		public override void SetViewports(in Viewport* viewports, uint32 viewportNum)
		{
			VkViewport* flippedViewports = STACK_ALLOC!<VkViewport>(viewportNum);

			for (uint32 i = 0; i < viewportNum; i++)
			{
				readonly VkViewport viewport = *(VkViewport*)&viewports[i];
				ref VkViewport flippedViewport = ref flippedViewports[i];
				flippedViewport = viewport;
				flippedViewport.y = viewport.height - viewport.y;
				flippedViewport.height = -viewport.height;
			}

			vkCmdSetViewport(m_Handle, 0, viewportNum, flippedViewports);
		}

		public override void SetScissors(in Rect* rects, uint32 rectNum)
		{
			vkCmdSetScissor(m_Handle, 0, rectNum, (VkRect2D*)rects);
		}

		public override void SetDepthBounds(float boundsMin, float boundsMax)
		{
			vkCmdSetDepthBounds(m_Handle, boundsMin, boundsMax);
		}

		public override void SetStencilReference(uint8 reference)
		{
			vkCmdSetStencilReference(m_Handle, .VK_STENCIL_FRONT_AND_BACK, reference);
		}

		public override void SetSamplePositions(in SamplePosition* positions, uint32 positionNum)
		{
			// TODO: not implemented
			//MaybeUnused(positions);
			//MaybeUnused(positionNum);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), false, void(),
				"CommandBufferVK::SetSamplePositions() is not implemented.");
		}

		public override void ClearAttachments(in ClearDesc* clearDescs, uint32 clearDescNum, in Rect* rects, uint32 rectNum)
		{
			var rectNum;
			VkClearAttachment* attachments = STACK_ALLOC!<VkClearAttachment>(clearDescNum);

			for (uint32 i = 0; i < clearDescNum; i++)
			{
				/*readonly*/ ref ClearDesc desc = ref clearDescs[i];
				ref VkClearAttachment attachment = ref attachments[i];

				switch (desc.attachmentContentType)
				{
				case AttachmentContentType.COLOR:
					attachment.aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
					break;
				case AttachmentContentType.DEPTH:
					attachment.aspectMask = .VK_IMAGE_ASPECT_DEPTH_BIT;
					break;
				case AttachmentContentType.STENCIL:
					attachment.aspectMask = .VK_IMAGE_ASPECT_STENCIL_BIT;
					break;
				case AttachmentContentType.DEPTH_STENCIL:
					attachment.aspectMask = .VK_IMAGE_ASPECT_DEPTH_BIT | .VK_IMAGE_ASPECT_STENCIL_BIT;
					break;
				default:
					attachment.aspectMask = 0;
					break;
				}

				attachment.colorAttachment = desc.colorAttachmentIndex;
				Internal.MemCpy(&attachment.clearValue, &desc.value, sizeof(VkClearValue));
			}

			VkClearRect* clearRects;

			if (rectNum == 0)
			{
				clearRects = STACK_ALLOC!<VkClearRect>(clearDescNum);
				rectNum = clearDescNum;

				readonly ref VkRect2D rect = ref m_CurrentFrameBuffer.GetRenderArea();

				for (uint32 i = 0; i < clearDescNum; i++)
				{
					ref VkClearRect clearRect = ref clearRects[i];
					clearRect.baseArrayLayer = 0;
					clearRect.layerCount = 1;
					clearRect.rect = rect;
				}
			}
			else
			{
				clearRects = STACK_ALLOC!<VkClearRect>(rectNum);

				for (uint32 i = 0; i < rectNum; i++)
				{
					ref VkClearRect clearRect = ref clearRects[i];
					clearRect.baseArrayLayer = 0;
					clearRect.layerCount = 1;
					Internal.MemCpy(&clearRect.rect, rects + i, sizeof(VkRect2D));
				}
			}

			vkCmdClearAttachments(m_Handle, clearDescNum, attachments, rectNum, clearRects);
		}

		public override void SetIndexBuffer(in Buffer buffer, uint64 offset, IndexType indexType)
		{
			readonly VkBuffer bufferHandle = ((BufferVK)buffer).GetHandle(m_PhysicalDeviceIndex);
			vkCmdBindIndexBuffer(m_Handle, bufferHandle, offset, GetIndexType(indexType));
		}

		public override void SetVertexBuffers(uint32 baseSlot, uint32 bufferNum, in Buffer* buffers, in uint64* offsets)
		{
			VkBuffer* bufferHandles = STACK_ALLOC!<VkBuffer>(bufferNum);

			for (uint32 i = 0; i < bufferNum; i++)
				bufferHandles[i] = ((BufferVK)buffers[i]).GetHandle(m_PhysicalDeviceIndex);

			vkCmdBindVertexBuffers(m_Handle, baseSlot, bufferNum, bufferHandles, offsets);
		}

		public override void Draw(uint32 vertexNum, uint32 instanceNum, uint32 baseVertex, uint32 baseInstance)
		{
			vkCmdDraw(m_Handle, vertexNum, instanceNum, baseVertex, baseInstance);
		}

		public override void DrawIndexed(uint32 indexNum, uint32 instanceNum, uint32 baseIndex, uint32 baseVertex, uint32 baseInstance)
		{
			vkCmdDrawIndexed(m_Handle, indexNum, instanceNum, baseIndex, (.)baseVertex, baseInstance);
		}

		public override void DrawIndirect(in Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
		{
			readonly VkBuffer bufferHandle = ((BufferVK)buffer).GetHandle(m_PhysicalDeviceIndex);
			vkCmdDrawIndirect(m_Handle, bufferHandle, offset, drawNum, (uint32)stride);
		}

		public override void DrawIndexedIndirect(in Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
		{
			readonly VkBuffer bufferHandle = ((BufferVK)buffer).GetHandle(m_PhysicalDeviceIndex);
			vkCmdDrawIndexedIndirect(m_Handle, bufferHandle, offset, drawNum, (uint32)stride);
		}

		public override void Dispatch(uint32 x, uint32 y, uint32 z)
		{
			vkCmdDispatch(m_Handle, x, y, z);
		}

		public override void DispatchIndirect(in Buffer buffer, uint64 offset)
		{
			readonly BufferVK bufferImpl = (BufferVK)buffer;
			vkCmdDispatchIndirect(m_Handle, bufferImpl.GetHandle(m_PhysicalDeviceIndex), offset);
		}

		public override void BeginQuery(in QueryPool queryPool, uint32 offset)
		{
			readonly QueryPoolVK queryPoolImpl = (QueryPoolVK)queryPool;
			vkCmdBeginQuery(m_Handle, queryPoolImpl.GetHandle(m_PhysicalDeviceIndex), offset, (VkQueryControlFlags)0);
		}

		public override void EndQuery(in QueryPool queryPool, uint32 offset)
		{
			readonly QueryPoolVK queryPoolImpl = (QueryPoolVK)queryPool;

			if (queryPoolImpl.GetQueryType() == .VK_QUERY_TYPE_TIMESTAMP)
			{
				vkCmdWriteTimestamp(m_Handle, .VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, queryPoolImpl.GetHandle(m_PhysicalDeviceIndex), offset);
				return;
			}

			vkCmdEndQuery(m_Handle, queryPoolImpl.GetHandle(m_PhysicalDeviceIndex), offset);
		}

		public override void BeginAnnotation(in StringView name)
		{
			if ([Friend]vkCmdBeginDebugUtilsLabelEXT_ptr == null)
				return;

			VkDebugUtilsLabelEXT info = .() { sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT };
			info.pLabelName = name.Ptr;

			vkCmdBeginDebugUtilsLabelEXT(m_Handle, &info);
		}

		public override void EndAnnotation()
		{
			if ([Friend]vkCmdEndDebugUtilsLabelEXT_ptr == null)
				return;

			vkCmdEndDebugUtilsLabelEXT(m_Handle);
		}

		public override void ClearStorageBuffer(in ClearStorageBufferDesc clearDesc)
		{
			readonly DescriptorVK descriptor = (DescriptorVK)clearDesc.storageBuffer;
			vkCmdFillBuffer(m_Handle, descriptor.GetBuffer(m_PhysicalDeviceIndex), 0, VK_WHOLE_SIZE, clearDesc.value);
		}

		public override void ClearStorageTexture(in ClearStorageTextureDesc clearDesc)
		{
			var clearDesc;
			readonly DescriptorVK descriptor = (DescriptorVK)clearDesc.storageTexture;
			readonly VkClearColorValue* value = (VkClearColorValue*)&clearDesc.value;

			VkImageSubresourceRange range = .();
			descriptor.GetImageSubresourceRange(ref range);

			vkCmdClearColorImage(m_Handle, descriptor.GetImage(m_PhysicalDeviceIndex), .VK_IMAGE_LAYOUT_GENERAL, value, 1, &range);
		}

		public override void CopyBuffer(Buffer dstBuffer, uint32 dstPhysicalDeviceIndex, uint64 dstOffset, in Buffer srcBuffer, uint32 srcPhysicalDeviceIndex, uint64 srcOffset, uint64 size)
		{
			readonly BufferVK srcBufferImpl = (BufferVK)srcBuffer;
			readonly BufferVK dstBufferImpl = (BufferVK)dstBuffer;

			VkBufferCopy region = .()
				{
					srcOffset = srcOffset,
					dstOffset = dstOffset,
					size = size == WHOLE_SIZE ? srcBufferImpl.GetSize() : size
				};

			vkCmdCopyBuffer(m_Handle, srcBufferImpl.GetHandle(srcPhysicalDeviceIndex), dstBufferImpl.GetHandle(dstPhysicalDeviceIndex), 1, &region);
		}

		public override void CopyTexture(ref Texture dstTexture, uint32 dstPhysicalDeviceIndex, in TextureRegionDesc* dstRegionDesc, in Texture srcTexture, uint32 srcPhysicalDeviceIndex, in TextureRegionDesc* srcRegionDesc)
		{
			readonly TextureVK srcTextureImpl = (TextureVK)srcTexture;
			readonly TextureVK dstTextureImpl = (TextureVK)dstTexture;

			if (srcRegionDesc == null && dstRegionDesc == null)
			{
				CopyWholeTexture(dstTextureImpl, dstPhysicalDeviceIndex, srcTextureImpl, srcPhysicalDeviceIndex);
				return;
			}

			VkImageCopy region = .();

			if (srcRegionDesc != null)
			{
				region.srcSubresource = .()
					{
						aspectMask = srcTextureImpl.GetImageAspectFlags(),
						mipLevel = srcRegionDesc.mipOffset,
						baseArrayLayer = srcRegionDesc.arrayOffset,
						layerCount = 1
					};

				region.srcOffset = .()
					{
						x = (int32)srcRegionDesc.offset[0],
						y = (int32)srcRegionDesc.offset[1],
						z = (int32)srcRegionDesc.offset[2]
					};

				region.extent = .()
					{
						width = (srcRegionDesc.size[0] == WHOLE_SIZE) ? srcTextureImpl.GetSize(0, srcRegionDesc.mipOffset) : srcRegionDesc.size[0],
						height = (srcRegionDesc.size[1] == WHOLE_SIZE) ? srcTextureImpl.GetSize(1, srcRegionDesc.mipOffset) : srcRegionDesc.size[1],
						depth = (srcRegionDesc.size[2] == WHOLE_SIZE) ? srcTextureImpl.GetSize(2, srcRegionDesc.mipOffset) : srcRegionDesc.size[2]
					};
			}
			else
			{
				region.srcSubresource = .()
					{
						aspectMask = srcTextureImpl.GetImageAspectFlags(),
						mipLevel = 0,
						baseArrayLayer = 0,
						layerCount = 1
					};

				region.srcOffset = .() { };
				region.extent = srcTextureImpl.GetExtent();
			}

			if (dstRegionDesc != null)
			{
				region.dstSubresource = .()
					{
						aspectMask = dstTextureImpl.GetImageAspectFlags(),
						mipLevel = dstRegionDesc.mipOffset,
						baseArrayLayer = dstRegionDesc.arrayOffset,
						layerCount = 1
					};

				region.dstOffset = .()
					{
						x = (int32)dstRegionDesc.offset[0],
						y = (int32)dstRegionDesc.offset[1],
						z = (int32)dstRegionDesc.offset[2]
					};
			}
			else
			{
				region.dstSubresource = .()
					{
						aspectMask = dstTextureImpl.GetImageAspectFlags(),
						mipLevel = 0,
						baseArrayLayer = 0,
						layerCount = 1
					};

				region.dstOffset = .();
			}

			vkCmdCopyImage(m_Handle, srcTextureImpl.GetHandle(dstPhysicalDeviceIndex), .VK_IMAGE_LAYOUT_GENERAL,
				dstTextureImpl.GetHandle(srcPhysicalDeviceIndex), .VK_IMAGE_LAYOUT_GENERAL, 1, &region);
		}

		public override void UploadBufferToTexture(Texture dstTexture, in TextureRegionDesc dstRegionDesc, in Buffer srcBuffer, in TextureDataLayoutDesc srcDataLayoutDesc)
		{
			readonly BufferVK srcBufferImpl = (BufferVK)srcBuffer;
			readonly TextureVK dstTextureImpl = (TextureVK)dstTexture;

			readonly uint32 rowBlockNum = srcDataLayoutDesc.rowPitch / GetTexelBlockSize(dstTextureImpl.GetFormat());
			readonly uint32 bufferRowLength = rowBlockNum * GetTexelBlockWidth(dstTextureImpl.GetFormat());

			readonly uint32 sliceRowNum = srcDataLayoutDesc.slicePitch / srcDataLayoutDesc.rowPitch;
			readonly uint32 bufferImageHeight = sliceRowNum * GetTexelBlockWidth(dstTextureImpl.GetFormat());

			VkBufferImageCopy region = .()
				{
					bufferOffset = srcDataLayoutDesc.offset,
					bufferRowLength = bufferRowLength,
					bufferImageHeight = bufferImageHeight,
					imageSubresource = VkImageSubresourceLayers()
						{
							aspectMask = dstTextureImpl.GetImageAspectFlags(),
							mipLevel = dstRegionDesc.mipOffset,
							baseArrayLayer = dstRegionDesc.arrayOffset,
							layerCount = 1
						},
					imageOffset = VkOffset3D()
						{
							x = dstRegionDesc.offset[0],
							y = dstRegionDesc.offset[1],
							z = dstRegionDesc.offset[2]
						},
					imageExtent = VkExtent3D()
						{
							width = (dstRegionDesc.size[0] == WHOLE_SIZE) ? dstTextureImpl.GetSize(0, dstRegionDesc.mipOffset) : dstRegionDesc.size[0],
							height = (dstRegionDesc.size[1] == WHOLE_SIZE) ? dstTextureImpl.GetSize(1, dstRegionDesc.mipOffset) : dstRegionDesc.size[1],
							depth = (dstRegionDesc.size[2] == WHOLE_SIZE) ? dstTextureImpl.GetSize(2, dstRegionDesc.mipOffset) : dstRegionDesc.size[2]
						}
				};

			vkCmdCopyBufferToImage(m_Handle, srcBufferImpl.GetHandle(0), dstTextureImpl.GetHandle(m_PhysicalDeviceIndex), .VK_IMAGE_LAYOUT_GENERAL, 1, &region);
		}

		public override void ReadbackTextureToBuffer(ref Buffer dstBuffer, ref TextureDataLayoutDesc dstDataLayoutDesc, in Texture srcTexture, in TextureRegionDesc srcRegionDesc)
		{
			readonly TextureVK srcTextureImpl = (TextureVK)srcTexture;
			readonly BufferVK dstBufferImpl = (BufferVK)dstBuffer;

			readonly uint32 rowBlockNum = dstDataLayoutDesc.rowPitch / GetTexelBlockSize(srcTextureImpl.GetFormat());
			readonly uint32 bufferRowLength = rowBlockNum * GetTexelBlockWidth(srcTextureImpl.GetFormat());

			readonly uint32 sliceRowNum = dstDataLayoutDesc.slicePitch / dstDataLayoutDesc.rowPitch;
			readonly uint32 bufferImageHeight = sliceRowNum * GetTexelBlockWidth(srcTextureImpl.GetFormat());

			VkBufferImageCopy region = .()
				{
					bufferOffset = dstDataLayoutDesc.offset,
					bufferRowLength = bufferRowLength,
					bufferImageHeight = bufferImageHeight,
					imageSubresource = VkImageSubresourceLayers()
						{
							aspectMask = srcTextureImpl.GetImageAspectFlags(),
							mipLevel = srcRegionDesc.mipOffset,
							baseArrayLayer = srcRegionDesc.arrayOffset,
							layerCount = 1
						},
					imageOffset = VkOffset3D()
						{
							x = srcRegionDesc.offset[0],
							y = srcRegionDesc.offset[1],
							z = srcRegionDesc.offset[2]
						},
					imageExtent = VkExtent3D()
						{
							width = (srcRegionDesc.size[0] == WHOLE_SIZE) ? srcTextureImpl.GetSize(0, srcRegionDesc.mipOffset) : srcRegionDesc.size[0],
							height = (srcRegionDesc.size[1] == WHOLE_SIZE) ? srcTextureImpl.GetSize(1, srcRegionDesc.mipOffset) : srcRegionDesc.size[1],
							depth = (srcRegionDesc.size[2] == WHOLE_SIZE) ? srcTextureImpl.GetSize(2, srcRegionDesc.mipOffset) : srcRegionDesc.size[2]
						}
				};

			vkCmdCopyImageToBuffer(m_Handle, srcTextureImpl.GetHandle(m_PhysicalDeviceIndex), .VK_IMAGE_LAYOUT_GENERAL, dstBufferImpl.GetHandle(0), 1, &region);
		}

		public override void CopyQueries(in QueryPool queryPool, uint32 offset, uint32 num, ref Buffer dstBuffer, uint64 dstOffset)
		{
			readonly QueryPoolVK queryPoolImpl = (QueryPoolVK)queryPool;
			readonly BufferVK bufferImpl = (BufferVK)dstBuffer;

			VkQueryResultFlags flags = .VK_QUERY_RESULT_PARTIAL_BIT;
			if (queryPoolImpl.GetQueryType() == .VK_QUERY_TYPE_TIMESTAMP)
				flags = .VK_QUERY_RESULT_64_BIT;

			vkCmdCopyQueryPoolResults(m_Handle, queryPoolImpl.GetHandle(m_PhysicalDeviceIndex), offset, num, bufferImpl.GetHandle(m_PhysicalDeviceIndex), dstOffset,
				queryPoolImpl.GetStride(), flags);
		}

		public override void ResetQueries(in QueryPool queryPool, uint32 offset, uint32 num)
		{
			readonly QueryPoolVK queryPoolImpl = (QueryPoolVK)queryPool;

			vkCmdResetQueryPool(m_Handle, queryPoolImpl.GetHandle(m_PhysicalDeviceIndex), offset, num);
		}

		public override void BuildTopLevelAccelerationStructure(uint32 instanceNum, in Buffer buffer, uint64 bufferOffset, AccelerationStructureBuildBits flags, ref AccelerationStructure dst, ref Buffer scratch, uint64 scratchOffset)
		{
			readonly VkAccelerationStructureKHR dstASHandle = ((AccelerationStructureVK)dst).GetHandle(m_PhysicalDeviceIndex);
			readonly VkDeviceAddress scratchAddress = ((BufferVK)scratch).GetDeviceAddress(m_PhysicalDeviceIndex) + scratchOffset;
			readonly VkDeviceAddress bufferAddress = ((BufferVK)buffer).GetDeviceAddress(m_PhysicalDeviceIndex) + bufferOffset;

			VkAccelerationStructureGeometryKHR geometry = .() { };
			geometry.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
			geometry.geometryType = .VK_GEOMETRY_TYPE_INSTANCES_KHR;
			geometry.geometry.triangles.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR;
			geometry.geometry.aabbs.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR;
			geometry.geometry.instances.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR;
			geometry.geometry.instances.data.deviceAddress = bufferAddress;

			VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfo = .() { };
			buildGeometryInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
			buildGeometryInfo.mode = .VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR;
			buildGeometryInfo.type = .VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR;
			buildGeometryInfo.flags = GetAccelerationStructureBuildFlags(flags);
			buildGeometryInfo.dstAccelerationStructure = dstASHandle;
			buildGeometryInfo.geometryCount = 1;
			buildGeometryInfo.pGeometries = &geometry;
			buildGeometryInfo.scratchData.deviceAddress = scratchAddress;

			VkAccelerationStructureBuildRangeInfoKHR range = .() { };
			range.primitiveCount = instanceNum;

			/*readonly*/ VkAccelerationStructureBuildRangeInfoKHR*[1] rangeArrays = .(&range);

			vkCmdBuildAccelerationStructuresKHR(m_Handle, 1, &buildGeometryInfo, &rangeArrays);
		}

		public override void BuildBottomLevelAccelerationStructure(uint32 geometryObjectNum, in GeometryObject* geometryObjects, AccelerationStructureBuildBits flags, ref AccelerationStructure dst, ref Buffer scratch, uint64 scratchOffset)
		{
			readonly VkAccelerationStructureKHR dstASHandle = ((AccelerationStructureVK)dst).GetHandle(m_PhysicalDeviceIndex);
			readonly VkDeviceAddress scratchAddress = ((BufferVK)scratch).GetDeviceAddress(m_PhysicalDeviceIndex) + scratchOffset;

			VkAccelerationStructureGeometryKHR* geometries = ALLOCATE_SCRATCH!<VkAccelerationStructureGeometryKHR>(m_Device, geometryObjectNum);
			VkAccelerationStructureBuildRangeInfoKHR* ranges = ALLOCATE_SCRATCH!<VkAccelerationStructureBuildRangeInfoKHR>(m_Device, geometryObjectNum);

			ConvertGeometryObjectsVK(m_PhysicalDeviceIndex, geometries, ranges, geometryObjects, geometryObjectNum);

			VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfo = .() { };
			buildGeometryInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
			buildGeometryInfo.mode = .VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR;
			buildGeometryInfo.type = .VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR;
			buildGeometryInfo.flags = GetAccelerationStructureBuildFlags(flags);
			buildGeometryInfo.dstAccelerationStructure = dstASHandle;
			buildGeometryInfo.geometryCount = geometryObjectNum;
			buildGeometryInfo.pGeometries = geometries;
			buildGeometryInfo.scratchData.deviceAddress = scratchAddress;

			/*readonly*/ VkAccelerationStructureBuildRangeInfoKHR*[1] rangeArrays = .(ranges);

			vkCmdBuildAccelerationStructuresKHR(m_Handle, 1, &buildGeometryInfo, &rangeArrays);

			FREE_SCRATCH!(m_Device, ranges, geometryObjectNum);
			FREE_SCRATCH!(m_Device, geometries, geometryObjectNum);
		}

		public override void UpdateTopLevelAccelerationStructure(uint32 instanceNum, in Buffer buffer, uint64 bufferOffset, AccelerationStructureBuildBits flags, ref AccelerationStructure dst, in AccelerationStructure src, ref Buffer scratch, uint64 scratchOffset)
		{
			readonly VkAccelerationStructureKHR srcASHandle = ((AccelerationStructureVK)src).GetHandle(m_PhysicalDeviceIndex);
			readonly VkAccelerationStructureKHR dstASHandle = ((AccelerationStructureVK)dst).GetHandle(m_PhysicalDeviceIndex);
			readonly VkDeviceAddress scratchAddress = ((BufferVK)scratch).GetDeviceAddress(m_PhysicalDeviceIndex) + scratchOffset;
			readonly VkDeviceAddress bufferAddress = ((BufferVK)buffer).GetDeviceAddress(m_PhysicalDeviceIndex) + bufferOffset;

			VkAccelerationStructureGeometryKHR geometry = .() { };
			geometry.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
			geometry.geometryType = .VK_GEOMETRY_TYPE_INSTANCES_KHR;
			geometry.geometry.triangles.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR;
			geometry.geometry.aabbs.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR;
			geometry.geometry.instances.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR;
			geometry.geometry.instances.data.deviceAddress = bufferAddress;

			VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfo = .() { };
			buildGeometryInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
			buildGeometryInfo.mode = .VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR;
			buildGeometryInfo.type = .VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR;
			buildGeometryInfo.flags = GetAccelerationStructureBuildFlags(flags);
			buildGeometryInfo.srcAccelerationStructure = srcASHandle;
			buildGeometryInfo.dstAccelerationStructure = dstASHandle;
			buildGeometryInfo.geometryCount = 1;
			buildGeometryInfo.pGeometries = &geometry;
			buildGeometryInfo.scratchData.deviceAddress = scratchAddress;

			VkAccelerationStructureBuildRangeInfoKHR range = .() { };
			range.primitiveCount = instanceNum;

			/*readonly*/ VkAccelerationStructureBuildRangeInfoKHR*[1] rangeArrays = .(&range);

			vkCmdBuildAccelerationStructuresKHR(m_Handle, 1, &buildGeometryInfo, &rangeArrays);
		}

		public override void UpdateBottomLevelAccelerationStructure(uint32 geometryObjectNum, in GeometryObject* geometryObjects, AccelerationStructureBuildBits flags, ref AccelerationStructure dst, in AccelerationStructure src, ref Buffer scratch, uint64 scratchOffset)
		{
			readonly VkAccelerationStructureKHR srcASHandle = ((AccelerationStructureVK)src).GetHandle(m_PhysicalDeviceIndex);
			readonly VkAccelerationStructureKHR dstASHandle = ((AccelerationStructureVK)dst).GetHandle(m_PhysicalDeviceIndex);
			readonly VkDeviceAddress scratchAddress = ((BufferVK)scratch).GetDeviceAddress(m_PhysicalDeviceIndex) + scratchOffset;

			VkAccelerationStructureGeometryKHR* geometries = ALLOCATE_SCRATCH!<VkAccelerationStructureGeometryKHR>(m_Device, geometryObjectNum);
			VkAccelerationStructureBuildRangeInfoKHR* ranges = ALLOCATE_SCRATCH!<VkAccelerationStructureBuildRangeInfoKHR>(m_Device, geometryObjectNum);

			ConvertGeometryObjectsVK(m_PhysicalDeviceIndex, geometries, ranges, geometryObjects, geometryObjectNum);

			VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfo = .() { };
			buildGeometryInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
			buildGeometryInfo.mode = .VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR;
			buildGeometryInfo.type = .VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR;
			buildGeometryInfo.flags = GetAccelerationStructureBuildFlags(flags);
			buildGeometryInfo.srcAccelerationStructure = srcASHandle;
			buildGeometryInfo.dstAccelerationStructure = dstASHandle;
			buildGeometryInfo.geometryCount = geometryObjectNum;
			buildGeometryInfo.pGeometries = geometries;
			buildGeometryInfo.scratchData.deviceAddress = scratchAddress;

			/*readonly*/ VkAccelerationStructureBuildRangeInfoKHR*[1] rangeArrays = .(ranges);

			vkCmdBuildAccelerationStructuresKHR(m_Handle, 1, &buildGeometryInfo, &rangeArrays);

			FREE_SCRATCH!(m_Device, ranges, geometryObjectNum);
			FREE_SCRATCH!(m_Device, geometries, geometryObjectNum);
		}

		public override void CopyAccelerationStructure(ref AccelerationStructure dst, in AccelerationStructure src, CopyMode copyMode)
		{
			readonly VkAccelerationStructureKHR dstASHandle = ((AccelerationStructureVK)dst).GetHandle(m_PhysicalDeviceIndex);
			readonly VkAccelerationStructureKHR srcASHandle = ((AccelerationStructureVK)src).GetHandle(m_PhysicalDeviceIndex);

			VkCopyAccelerationStructureInfoKHR info = .() { };
			info.sType = .VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_INFO_KHR;
			info.src = srcASHandle;
			info.dst = dstASHandle;
			info.mode = GetCopyMode(copyMode);

			vkCmdCopyAccelerationStructureKHR(m_Handle, &info);
		}

		public override void WriteAccelerationStructureSize(in AccelerationStructure* accelerationStructures, uint32 accelerationStructureNum, ref QueryPool queryPool, uint32 queryPoolOffset)
		{
			VkAccelerationStructureKHR* ASes = ALLOCATE_SCRATCH!<VkAccelerationStructureKHR>(m_Device, accelerationStructureNum);

			for (uint32 i = 0; i < accelerationStructureNum; i++)
				ASes[i] = ((AccelerationStructureVK)accelerationStructures[i]).GetHandle(m_PhysicalDeviceIndex);

			readonly VkQueryPool queryPoolHandle = ((QueryPoolVK)queryPool).GetHandle(m_PhysicalDeviceIndex);

			vkCmdWriteAccelerationStructuresPropertiesKHR(m_Handle, accelerationStructureNum, ASes, .VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_KHR,
				queryPoolHandle, queryPoolOffset);

			FREE_SCRATCH!(m_Device, ASes, accelerationStructureNum);
		}

		public override void DispatchRays(in DispatchRaysDesc dispatchRaysDesc)
		{
			VkStridedDeviceAddressRegionKHR raygen = .() { };
			raygen.deviceAddress = GetBufferDeviceAddress(dispatchRaysDesc.raygenShader.buffer, m_PhysicalDeviceIndex) + dispatchRaysDesc.raygenShader.offset;
			raygen.size = dispatchRaysDesc.raygenShader.size;
			raygen.stride = dispatchRaysDesc.raygenShader.stride;

			VkStridedDeviceAddressRegionKHR miss = .() { };
			miss.deviceAddress = GetBufferDeviceAddress(dispatchRaysDesc.missShaders.buffer, m_PhysicalDeviceIndex) + dispatchRaysDesc.missShaders.offset;
			miss.size = dispatchRaysDesc.missShaders.size;
			miss.stride = dispatchRaysDesc.missShaders.stride;

			VkStridedDeviceAddressRegionKHR hit = .() { };
			hit.deviceAddress = GetBufferDeviceAddress(dispatchRaysDesc.hitShaderGroups.buffer, m_PhysicalDeviceIndex) + dispatchRaysDesc.hitShaderGroups.offset;
			hit.size = dispatchRaysDesc.hitShaderGroups.size;
			hit.stride = dispatchRaysDesc.hitShaderGroups.stride;

			VkStridedDeviceAddressRegionKHR callable = .() { };
			callable.deviceAddress = GetBufferDeviceAddress(dispatchRaysDesc.callableShaders.buffer, m_PhysicalDeviceIndex) + dispatchRaysDesc.callableShaders.offset;
			callable.size = dispatchRaysDesc.callableShaders.size;
			callable.stride = dispatchRaysDesc.callableShaders.stride;

			vkCmdTraceRaysKHR(m_Handle, &raygen, &miss, &hit, &callable, dispatchRaysDesc.width, dispatchRaysDesc.height, dispatchRaysDesc.depth);
		}

		public override void DispatchMeshTasks(uint32 taskNum)
		{
			vkCmdDrawMeshTasksNV(m_Handle, taskNum, 0);
		}
	}
}
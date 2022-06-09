using System;
using Bulkan;
using Sedulous.Graphics;
using System.Collections;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	/// <summary>
	/// This class represent a queue where commandbuffers waits to be executing by the GPU.
	/// </summary>
	public class VKCommandQueue : CommandQueue
	{
		private bool disposed;

		private VKGraphicsContext vkContext;

		private String name;

		private Queue<VKCommandBuffer> queue;

		private VKCommandBuffer[] executionArray;

		internal VkQueue CommandQueue;

		internal CommandQueueType QueueType;

		private int32 executionArraySize;

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
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_QUEUE, (uint64)(int64)CommandQueue.Handle, name);
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKCommandQueue" /> class.
		/// </summary>
		/// <param name="context">The graphics context instance.</param>
		/// <param name="queueType">The commandqueue elements type.</param>
		public  this(VKGraphicsContext context, CommandQueueType queueType)
		{
			vkContext = context;
			queue = new Queue<VKCommandBuffer>();
			executionArray = new VKCommandBuffer[64];
			executionArraySize = 0;
			QueueType = queueType;
			uint32 queueFamilyIndex = 0u;
			switch (queueType)
			{
			case CommandQueueType.Graphics:
				queueFamilyIndex = (uint32)vkContext.QueueIndices.GraphicsFamily;
				break;
			case CommandQueueType.Compute:
				queueFamilyIndex = (uint32)vkContext.QueueIndices.ComputeFamily;
				break;
			case CommandQueueType.Copy:
				queueFamilyIndex = (uint32)vkContext.QueueIndices.CopyFamily;
				break;
			}
			VkQueue commandQueue = default(VkQueue);
			VulkanNative.vkGetDeviceQueue(vkContext.VkDevice, queueFamilyIndex, 0u, &commandQueue);
			CommandQueue = commandQueue;
		}

		/// <inheritdoc />
		public override CommandBuffer CommandBuffer()
		{
			VKCommandBuffer vKCommandBuffer;
			if (queue.Count == 0)
			{
				vKCommandBuffer = new VKCommandBuffer(vkContext, this);
			}
			else
			{
				vKCommandBuffer = queue.PopFront();
				VulkanNative.vkResetCommandBuffer(vKCommandBuffer.CommandBuffer, VkCommandBufferResetFlags.None);
				vKCommandBuffer.Reset();
			}
			return vKCommandBuffer;
		}

		/// <inheritdoc />
		public  override void Submit()
		{
			if (vkContext.BufferUploader.Count != 0 || vkContext.TextureUploader.Count != 0)
			{
				vkContext.SyncUpcopyQueue();
			}
			for (int32 i = 0; i < executionArraySize; i++)
			{
				VKCommandBuffer vKCommandBuffer = executionArray[i];
				VkCommandBuffer commandBuffer = vKCommandBuffer.CommandBuffer;
				VkPipelineStageFlags vkPipelineStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
				VkSubmitInfo vkSubmitInfo = default(VkSubmitInfo);
				vkSubmitInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_SUBMIT_INFO;
				vkSubmitInfo.commandBufferCount = 1u;
				vkSubmitInfo.pCommandBuffers = &commandBuffer;
				vkSubmitInfo.pWaitDstStageMask = &vkPipelineStageFlags;
				VulkanNative.vkQueueSubmit(CommandQueue, 1u, &vkSubmitInfo, VkFence.Null);
				queue.Add(vKCommandBuffer);
			}
			ClearExecutionArray();
		}

		/// <inheritdoc />
		public override void WaitIdle()
		{
			VulkanNative.vkQueueWaitIdle(CommandQueue);
		}

		/// <summary>
		/// Add a new commandbuffer ready to be executed.
		/// </summary>
		/// <param name="commandBuffer">The new commandbuffer.</param>
		internal void CommitCommandBuffer(VKCommandBuffer commandBuffer)
		{
			if (executionArray.Count == executionArraySize)
			{
				Array.Resize(ref executionArray, executionArray.Count + 64);
			}
			executionArray[executionArraySize++] = commandBuffer;
		}

		/// <inheritdoc />
		public override void Dispose()
		{
			//Dispose(disposing: true);
			//GC.SuppressFinalize(this);
		}

		/// <summary>
		///  Clear the execution commandbuffer array.
		/// </summary>
		private void ClearExecutionArray()
		{
			for (int32 i = 0; i < executionArraySize; i++)
			{
				executionArray[i] = null;
			}
			executionArraySize = 0;
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing">
		/// <c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.
		/// </param>
		protected virtual void Dispose(bool disposing)
		{
			if (!disposed && disposing)
			{
				WaitIdle();
				while (queue.Count > 0)
				{
					queue.PopFront().Dispose();
				}
				disposed = true;
			}
		}
	}
}

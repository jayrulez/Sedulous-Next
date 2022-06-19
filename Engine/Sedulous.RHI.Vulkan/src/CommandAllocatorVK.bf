using Bulkan;
using System;
using static Bulkan.VulkanNative;
using static Sedulous.RHI.Vulkan.VulkanUtils;
namespace Sedulous.RHI.Vulkan
{
	class CommandAllocatorVK : CommandAllocator
	{
		private VkCommandPool m_Handle = .Null;
		private CommandQueueType m_Type = (CommandQueueType)0;
		private DeviceVK m_Device;
		private bool m_OwnsNativeObjects = false;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////

		/////////////////////////////Internal Methods//////////////////////////////
		public static implicit operator VkCommandPool(Self self) => self.m_Handle;

		public readonly ref DeviceVK GetDevice() => ref m_Device;

		public Result Create(CommandQueue commandQueue, uint32 physicalDeviceMask)
		{
	//MaybeUnused(physicalDeviceMask); // TODO: use it

			m_OwnsNativeObjects = true;
			readonly CommandQueueVK commandQueueImpl = (CommandQueueVK)commandQueue;

			m_Type = commandQueueImpl.GetCommandQueueType();

			VkCommandPoolCreateInfo info = .()
				{
					sType = .VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
					pNext = null,
					flags = .VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
					queueFamilyIndex = commandQueueImpl.GetFamilyIndex()
				};

			readonly VkResult result = vkCreateCommandPool(m_Device, &info, m_Device.GetAllocationCallbacks(), &m_Handle);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a command pool: vkCreateCommandPool returned {0}.", (int32)result);

			return Result.SUCCESS;
		}

		public Result Create(CommandAllocatorVulkanDesc commandAllocatorDesc)
		{
			m_OwnsNativeObjects = false;
			m_Handle = (VkCommandPool)commandAllocatorDesc.vkCommandPool;
			m_Type = commandAllocatorDesc.commandQueueType;
			return Result.SUCCESS;
		}

		///////////////////////////////////////////////////////////////////////////
		public this(DeviceVK device)
		{
			m_Device = device;
		}

		public ~this()
		{
			if (m_Handle != .Null && m_OwnsNativeObjects)
				vkDestroyCommandPool(m_Device, m_Handle, m_Device.GetAllocationCallbacks());
		}

		public override void SetDebugName(StringView name)
		{
			m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_COMMAND_POOL, (uint64)m_Handle.Handle, name);
		}


		public override Result CreateCommandBuffer(out CommandBuffer commandBuffer)
		{
			commandBuffer = ?;
			VkCommandBufferAllocateInfo info = .()
				{
					sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
					pNext = null,
					commandPool = m_Handle,
					level = .VK_COMMAND_BUFFER_LEVEL_PRIMARY,
					commandBufferCount = 1
				};

			VkCommandBuffer commandBufferHandle = .Null;
			readonly VkResult result = vkAllocateCommandBuffers(m_Device, &info, &commandBufferHandle);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create the command buffer: vkAllocateCommandBuffers returned {0}.", (int32)result);

			CommandBufferVK commandBufferImpl = Allocate!<CommandBufferVK>(m_Device.GetDeviceAllocator(), m_Device);
			commandBufferImpl.Create(m_Handle, commandBufferHandle, m_Type);

			commandBuffer = (CommandBuffer)commandBufferImpl;

			return Result.SUCCESS;
		}

		public override void Reset()
		{
			readonly VkResult result = vkResetCommandPool(m_Device, m_Handle, (VkCommandPoolResetFlags)0);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, void(),
				"Can't reset a command pool. vkResetCommandPool returned {0}.", (int32)result);
		}
	}
}
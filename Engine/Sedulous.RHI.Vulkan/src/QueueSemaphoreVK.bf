using Bulkan;
using System;
using static Bulkan.VulkanNative;
using static Sedulous.RHI.Vulkan.VulkanUtils;
namespace Sedulous.RHI.Vulkan
{
	class QueueSemaphoreVK : QueueSemaphore
	{
		private VkSemaphore m_Handle = .Null;
		private DeviceVK m_Device;
		private bool m_OwnsNativeObjects = false;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////

		/////////////////////////////Internal Methods//////////////////////////////

		public static implicit operator VkSemaphore(Self self) => self.m_Handle;

		public readonly ref DeviceVK GetDevice() => ref m_Device;

		public Result Create()
		{
			m_OwnsNativeObjects = true;

			VkSemaphoreCreateInfo semaphoreInfo = .()
				{
					sType = .VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
					pNext = null,
					flags = /*(VkSemaphoreCreateFlags)*/ 0
				};

			readonly VkResult result = vkCreateSemaphore(m_Device, &semaphoreInfo, m_Device.GetAllocationCallbacks(), &m_Handle);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a semaphore: vkCreateSemaphore returned {0}.", (int32)result);

			return Result.SUCCESS;
		}

		public Result Create(VkSemaphore vkSemaphore)
		{
			m_OwnsNativeObjects = false;
			m_Handle = vkSemaphore;

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
				vkDestroySemaphore(m_Device, m_Handle, m_Device.GetAllocationCallbacks());
		}

		public override void SetDebugName(StringView name)
		{
			m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_SEMAPHORE, (uint64)m_Handle.Handle, name);
		}
	}
}
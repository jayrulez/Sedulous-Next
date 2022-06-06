using Bulkan;
using System;
using static Bulkan.VulkanNative;
using static Sedulous.RHI.Vulkan.VulkanUtils;
namespace Sedulous.RHI.Vulkan
{
	class DeviceSemaphoreVK : DeviceSemaphore
	{
		private VkFence m_Handle = .Null;
		private DeviceVK m_Device;
		private bool m_OwnsNativeObjects = false;

		 //////////////////////////////Private Methods//////////////////////////////

		 ///////////////////////////////////////////////////////////////////////////

		 /////////////////////////////Internal Methods//////////////////////////////
		public static implicit operator VkFence(Self self) => self.m_Handle;

		public readonly ref DeviceVK GetDevice() => ref m_Device;

		public Result Create(bool signaled)
		{
			m_OwnsNativeObjects = true;

			VkFenceCreateInfo fenceInfo = .()
				{
					sType = .VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
					pNext = null,
					flags = signaled ? .VK_FENCE_CREATE_SIGNALED_BIT : (VkFenceCreateFlags)0
				};

			readonly VkResult result = vkCreateFence(m_Device, &fenceInfo, m_Device.GetAllocationCallbacks(), &m_Handle);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a semaphore: vkCreateFence returned {0}.", (int32)result);

			return Result.SUCCESS;
		}

		public Result Create(VkFence vkFence)
		{
			m_OwnsNativeObjects = false;
			m_Handle = (VkFence)vkFence;

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
				vkDestroyFence(m_Device, m_Handle, m_Device.GetAllocationCallbacks());
		}

		public override void SetDebugName(in StringView name)
		{
			m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_FENCE, (uint64)m_Handle.Handle, name);
		}
	}
}
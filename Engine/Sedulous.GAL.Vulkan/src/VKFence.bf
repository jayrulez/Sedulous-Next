using Bulkan;
using System;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.Vulkan
{
	using internal Sedulous.GAL.Vulkan;

    internal  class VKFence : Fence
    {
        private readonly VKGraphicsDevice _gd;
        private Bulkan.VkFence _fence;
        private String _name;
        private bool _destroyed;

        public Bulkan.VkFence DeviceFence => _fence;

        public this(VKGraphicsDevice gd, bool signaled)
        {
            _gd = gd;
            VkFenceCreateInfo fenceCI = VkFenceCreateInfo();
            fenceCI.flags = signaled ? VkFenceCreateFlags.VK_FENCE_CREATE_SIGNALED_BIT : VkFenceCreateFlags.None;
            VkResult result = vkCreateFence(_gd.Device, &fenceCI, null, &_fence);
            VulkanUtil.CheckResult(result);
        }

        public override void Reset()
        {
            _gd.ResetFence(this);
        }

        public override bool Signaled => vkGetFenceStatus(_gd.Device, _fence) == VkResult.VK_SUCCESS;
        public override bool IsDisposed => _destroyed;

        public override String Name
        {
            get => _name;
            set
            {
                _name = value; _gd.SetResourceName(this, value);
            }
        }

        public override void Dispose()
        {
            if (!_destroyed)
            {
                vkDestroyFence(_gd.Device, _fence, null);
                _destroyed = true;
            }
        }
    }
}

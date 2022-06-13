#if !EXCLUDE_VULKAN_BACKEND
using System;
using Sedulous.GAL.Vulkan;
using Bulkan;
using System.Collections;

namespace Sedulous.GAL.Vulkan
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.Vulkan;

    /// <summary>
    /// Exposes Vulkan-specific functionality,
    /// useful for interoperating with native components which interface directly with Vulkan.
    /// Can only be used on <see cref="GraphicsBackend.Vulkan"/>.
    /// </summary>
    public class BackendInfoVulkan
    {
        private readonly VKGraphicsDevice _gd;
        private readonly List<String> _instanceLayers;
        private readonly List<String> _instanceExtensions;
        private readonly List<String> _deviceExtensions;

        internal this(VKGraphicsDevice gd)
        {
            _gd = gd;
            _instanceLayers = VulkanUtil.EnumerateInstanceLayers(..?);
            _instanceExtensions = VulkanUtil.EnumerateInstanceExtensions(..?);
            _deviceExtensions = VulkanUtil.EnumerateDeviceExtensions(_gd.PhysicalDevice, .. ?);
        }

		public ~this(){
			DeleteContainerAndItems!(_instanceLayers);
			DeleteContainerAndItems!(_instanceExtensions);
			DeleteContainerAndItems!(_deviceExtensions);
		}

        /// <summary>
        /// Gets the underlying VkInstance used by the GraphicsDevice.
        /// </summary>
        public VkInstance Instance => _gd.Instance.Handle;

        /// <summary>
        /// Gets the underlying VkDevice used by the GraphicsDevice.
        /// </summary>
        public VkDevice Device => _gd.Device.Handle;

        /// <summary>
        /// Gets the underlying VkPhysicalDevice used by the GraphicsDevice.
        /// </summary>
        public VkPhysicalDevice PhysicalDevice => _gd.PhysicalDevice.Handle;

        /// <summary>
        /// Gets the VkQueue which is used by the GraphicsDevice to submit graphics work.
        /// </summary>
        public VkQueue GraphicsQueue => _gd.GraphicsQueue.Handle;

        /// <summary>
        /// Gets the queue family index of the graphics VkQueue.
        /// </summary>
        public uint32 GraphicsQueueFamilyIndex => _gd.GraphicsQueueIndex;

        /// <summary>
        /// Gets the driver name of the device. May be null.
        /// </summary>
        public String DriverName => _gd.DriverName;

        /// <summary>
        /// Gets the driver information of the device. May be null.
        /// </summary>
        public String DriverInfo => _gd.DriverInfo;

        public Span<String> AvailableInstanceLayers => _instanceLayers;

        public Span<String> AvailableInstanceExtensions => _instanceExtensions;

        public Span<String> AvailableDeviceExtensions => _deviceExtensions;

        /// <summary>
        /// Overrides the current VkImageLayout tracked by the given Texture. This should be used when a VkImage is created by
        /// an external library to inform Sedulous.GAL about its initial layout.
        /// </summary>
        /// <param name="texture">The Texture whose currently-tracked VkImageLayout will be overridden.</param>
        /// <param name="layout">The new VkImageLayout value.</param>
        public void OverrideImageLayout(Texture texture, uint32 layout)
        {
            VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(texture);
            for (uint32 layer = 0; layer < vkTex.ArrayLayers; layer++)
            {
                for (uint32 level = 0; level < vkTex.MipLevels; level++)
                {
                    vkTex.SetImageLayout(level, layer, (VkImageLayout)layout);
                }
            }
        }

        /// <summary>
        /// Gets the underlying VkImage wrapped by the given Sedulous.GAL Texture. This method can not be used on Textures with
        /// TextureUsage.Staging.
        /// </summary>
        /// <param name="texture">The Texture whose underlying VkImage will be returned.</param>
        /// <returns>The underlying VkImage for the given Texture.</returns>
        public uint64 GetVkImage(Texture texture)
        {
            VKTexture vkTexture = Util.AssertSubtype<Texture, VKTexture>(texture);
            if ((vkTexture.Usage & TextureUsage.Staging) != 0)
            {
				//Runtime.FatalError(scope $"{nameof(GetVkImage)} cannot be used if the {nameof(Texture)} has {nameof(TextureUsage)}.{nameof(TextureUsage.Staging)}.");
                Runtime.FatalError(scope $"GetVkImage cannot be used if the Texture has TextureUsage.Staging.");
            }

            return vkTexture.OptimalDeviceImage.Handle;
        }

        /// <summary>
        /// Transitions the given Texture's underlying VkImage into a new layout.
        /// </summary>
        /// <param name="texture">The Texture whose underlying VkImage will be transitioned.</param>
        /// <param name="layout">The new VkImageLayout value.</param>
        public void TransitionImageLayout(Texture texture, uint32 layout)
        {
            _gd.TransitionImageLayout(Util.AssertSubtype<Texture, VKTexture>(texture), (VkImageLayout)layout);
        }
    }
}
#endif

using System;
using System.Diagnostics;
using Bulkan;
using Sedulous.Graphics;
using Sedulous.Platform;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	using static Sedulous.Graphics.Vulkan.VKHelpers;
	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;

	/// <summary>
	/// This class represents a native swapchain Object on Vulkan.
	/// </summary>
	public class VKSwapChain : SwapChain
	{
		internal VkSwapchainKHR vkSwapChain;

		internal VkSurfaceKHR vkSurface;

		internal VkSurfaceFormatKHR vkSurfaceFormat;

		internal VkSwapchainCreateInfoKHR swapchainInfo;

		private VkQueue vkPresentQueue;

		private int32 currentBackBufferIndex;

		private VKGraphicsContext vkContext;

		private String name;

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
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_SWAPCHAIN_KHR, vkSwapChain.Handle, name);
			}
		}

		/// <summary>
		/// Gets or sets the active backbuffer index.
		/// </summary>
		public int32 CurrentBackBufferIndex
		{
			get
			{
				return currentBackBufferIndex;
			}
			set
			{
				currentBackBufferIndex = value;
				(base.FrameBuffer as VKSwapChainFrameBuffer).CurrentBackBufferIndex = value;
			}
		}

		/// <inheritdoc />
		public override bool VerticalSync
		{
			get
			{
				return base.VerticalSync;
			}
			set
			{
				if (base.VerticalSync != value)
				{
					base.VerticalSync = value;
					CreateSwapChain();
					AcquireNextImage();
				}
			}
		}

		/// <summary>
		/// Create a ANativeWindows surface.
		/// </summary>
		/// <param name="jniEnv">The jni environment pointer.</param>
		/// <param name="surface">The native surface pointer.</param>
		/// <returns>A new ANativeWindows surface.</returns>
		//[Import("android.so")]
		//public static extern void* ANativeWindow_fromSurface(void* jniEnv, void* surface);

		/// <inheritdoc />
		public override Texture GetCurrentFramebufferTexture()
		{
			return (base.FrameBuffer as VKSwapChainFrameBuffer).ColorTargets[0].Texture;
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKSwapChain" /> class.
		/// </summary>
		/// <param name="context">Graphics Context.</param>
		/// <param name="description">SwapChain description.</param>
		public this(GraphicsContext context, SwapChainDescription description)
		{
			GraphicsContext = context;
			vkContext = context as VKGraphicsContext;
			base.SwapChainDescription = description;
			CreateSurface();
			CreateSwapChain();
			AcquireNextImage();
		}

		private  void CreateSurface()
		{
			if (vkSurface != VkSurfaceKHR.Null)
			{
				VulkanNative.vkDestroySurfaceKHR(vkContext.VkInstance, vkSurface, null);
				vkSurface = VkSurfaceKHR.Null;
			}
			VKHelpers.OS currentPlatfom = VKHelpers.GetCurrentPlatfom();
			VkSurfaceKHR @null = VkSurfaceKHR.Null;
			switch (currentPlatfom)
			{
			case VKHelpers.OS.Windows:
				{
					VkWin32SurfaceCreateInfoKHR vkWin32SurfaceCreateInfoKHR = default(VkWin32SurfaceCreateInfoKHR);
					vkWin32SurfaceCreateInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
					vkWin32SurfaceCreateInfoKHR.hwnd = base.SwapChainDescription.SurfaceInfo.Handles[0];
					vkWin32SurfaceCreateInfoKHR.hinstance = (void*)(int)System.Windows.GetModuleHandleA(null); //Environment.ModuleHandle;//Process.GetCurrentProcess().Handle;
					VulkanNative.vkCreateWin32SurfaceKHR(vkContext.VkInstance, &vkWin32SurfaceCreateInfoKHR, null, &@null);
					break;
				}
			case VKHelpers.OS.Linux:
				if (base.SwapChainDescription.SurfaceInfo.Type == SurfaceInfo.SurfaceTypes.Wayland)
				{
					VkWaylandSurfaceCreateInfoKHR vkWaylandSurfaceCreateInfoKHR = default(VkWaylandSurfaceCreateInfoKHR);
					vkWaylandSurfaceCreateInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR;
					vkWaylandSurfaceCreateInfoKHR.display = base.SwapChainDescription.SurfaceInfo.Handles[0];
					vkWaylandSurfaceCreateInfoKHR.surface = base.SwapChainDescription.SurfaceInfo.Handles[1];
					VulkanNative.vkCreateWaylandSurfaceKHR(vkContext.VkInstance, &vkWaylandSurfaceCreateInfoKHR, null, &@null);
				}
				else
				{
					VkXlibSurfaceCreateInfoKHR vkXlibSurfaceCreateInfoKHR = default(VkXlibSurfaceCreateInfoKHR);
					vkXlibSurfaceCreateInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR;
					vkXlibSurfaceCreateInfoKHR.dpy = base.SwapChainDescription.SurfaceInfo.Handles[0];
					vkXlibSurfaceCreateInfoKHR.window = base.SwapChainDescription.SurfaceInfo.Handles[1];
					VulkanNative.vkCreateXlibSurfaceKHR(vkContext.VkInstance, &vkXlibSurfaceCreateInfoKHR, null, &@null);
				}
				break;
			/*case VKHelpers.OS.Android:
			{
				void* window = ANativeWindow_fromSurface(base.SwapChainDescription.SurfaceInfo.Handles[0], base.SwapChainDescription.SurfaceInfo.Handles[1]);
				VkAndroidSurfaceCreateInfoKHR vkAndroidSurfaceCreateInfoKHR = default(VkAndroidSurfaceCreateInfoKHR);
				vkAndroidSurfaceCreateInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR;
				vkAndroidSurfaceCreateInfoKHR.window = window;
				VulkanNative.vkCreateAndroidSurfaceKHR(vkContext.VkInstance, &vkAndroidSurfaceCreateInfoKHR, null, &@null);
				break;
			}*/
			case VKHelpers.OS.MacOS:
				{
					VkMacOSSurfaceCreateInfoMVK vkMacOSSurfaceCreateInfoMVK = default(VkMacOSSurfaceCreateInfoMVK);
					vkMacOSSurfaceCreateInfoMVK.sType = VkStructureType.VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK;
					vkMacOSSurfaceCreateInfoMVK.pView = (void*)base.SwapChainDescription.SurfaceInfo.Handles[0];
					VulkanNative.vkCreateMacOSSurfaceMVK(vkContext.VkInstance, &vkMacOSSurfaceCreateInfoMVK, null, &@null);
					break;
				}
			case VKHelpers.OS.iOS:
				{
					VkIOSSurfaceCreateInfoMVK vkIOSSurfaceCreateInfoMVK = default(VkIOSSurfaceCreateInfoMVK);
					vkIOSSurfaceCreateInfoMVK.sType = VkStructureType.VK_STRUCTURE_TYPE_IOS_SURFACE_CREATE_INFO_MVK;
					vkIOSSurfaceCreateInfoMVK.pView = (void*)base.SwapChainDescription.SurfaceInfo.Handles[0];
					VulkanNative.vkCreateIOSSurfaceMVK(vkContext.VkInstance, &vkIOSSurfaceCreateInfoMVK, null, &@null);
					break;
				}
			default:
				GraphicsContext.ValidationLayer?.Notify("Vulkan", "Invalid OperationSystem.");
				break;
			}
			vkSurface = @null;
		}

		private  void CreateSwapChain()
		{
			DestroySwapChain();
			VkSurfaceCapabilitiesKHR capabilities = .();
			VulkanNative.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(vkContext.VkPhysicalDevice, vkSurface, &capabilities);
			uint32 num = 0;
			VulkanNative.vkGetPhysicalDeviceSurfaceFormatsKHR(vkContext.VkPhysicalDevice, vkSurface, &num, null);
			VkSurfaceFormatKHR* ptr = scope VkSurfaceFormatKHR[(int32)num]*;
			VulkanNative.vkGetPhysicalDeviceSurfaceFormatsKHR(vkContext.VkPhysicalDevice, vkSurface, &num, ptr);
			uint32 num2 = 0;
			VulkanNative.vkGetPhysicalDeviceSurfacePresentModesKHR(vkContext.VkPhysicalDevice, vkSurface, &num2, null);
			VkPresentModeKHR* ptr2 = scope VkPresentModeKHR[(int32)num2]*;
			VulkanNative.vkGetPhysicalDeviceSurfacePresentModesKHR(vkContext.VkPhysicalDevice, vkSurface, &num2, ptr2);
			vkSurfaceFormat = ChooseSwapSurfaceFormat(ptr, (int32)num);
			VkPresentModeKHR presentMode = ChooseSwapPresentMode(ptr2, (int32)num2);
			VkExtent2D imageExtent = ChooseSwapExtent(capabilities, base.SwapChainDescription.Width, base.SwapChainDescription.Height);
			uint32 num3 = capabilities.minImageCount + 1;
			if (capabilities.maxImageCount != 0)
			{
				num3 = Math.Min(num3, capabilities.maxImageCount);
			}
			VkCompositeAlphaFlagsKHR compositeAlpha = (capabilities.supportedCompositeAlpha.HasFlag(VkCompositeAlphaFlagsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR) ? VkCompositeAlphaFlagsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR : VkCompositeAlphaFlagsKHR.VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR);
			VkSwapchainCreateInfoKHR vkSwapchainCreateInfoKHR = default(VkSwapchainCreateInfoKHR);
			vkSwapchainCreateInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
			vkSwapchainCreateInfoKHR.minImageCount = num3;
			vkSwapchainCreateInfoKHR.imageFormat = vkSurfaceFormat.format;
			vkSwapchainCreateInfoKHR.imageColorSpace = vkSurfaceFormat.colorSpace;
			vkSwapchainCreateInfoKHR.imageExtent = imageExtent;
			vkSwapchainCreateInfoKHR.imageArrayLayers = 1u;
			vkSwapchainCreateInfoKHR.imageUsage = VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
			vkSwapchainCreateInfoKHR.preTransform = VkSurfaceTransformFlagsKHR.VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
			vkSwapchainCreateInfoKHR.compositeAlpha = compositeAlpha;
			vkSwapchainCreateInfoKHR.presentMode = presentMode;
			vkSwapchainCreateInfoKHR.surface = vkSurface;
			vkSwapchainCreateInfoKHR.clipped = true;
			vkContext.QueueIndices = VKQueueFamilyIndices.FindQueueFamilies(vkContext, vkContext.VkPhysicalDevice, vkSurface);
			uint32 graphicsFamily = (uint32)vkContext.QueueIndices.GraphicsFamily;
			uint32 presentfamily = (uint32)vkContext.QueueIndices.Presentfamily;
			uint32* pQueueFamilyIndices = scope uint32[2]* (graphicsFamily, presentfamily);
			if (graphicsFamily != presentfamily)
			{
				vkSwapchainCreateInfoKHR.imageSharingMode = VkSharingMode.VK_SHARING_MODE_CONCURRENT;
				vkSwapchainCreateInfoKHR.queueFamilyIndexCount = 2;
				vkSwapchainCreateInfoKHR.pQueueFamilyIndices = pQueueFamilyIndices;
			}
			else
			{
				vkSwapchainCreateInfoKHR.imageSharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
				vkSwapchainCreateInfoKHR.queueFamilyIndexCount = 0;
			}
			swapchainInfo = vkSwapchainCreateInfoKHR;
			VkSwapchainKHR vkSwapchainKHR = default(VkSwapchainKHR);
			VulkanNative.vkCreateSwapchainKHR(vkContext.VkDevice, &vkSwapchainCreateInfoKHR, null, &vkSwapchainKHR);
			vkSwapChain = vkSwapchainKHR;
			if (vkPresentQueue == VkQueue.Null)
			{
				VkQueue vkQueue = default(VkQueue);
				VulkanNative.vkGetDeviceQueue(vkContext.VkDevice, presentfamily, 0, &vkQueue);
				vkPresentQueue = vkQueue;
			}
			VKSwapChainFrameBuffer vKSwapChainFrameBuffer = new VKSwapChainFrameBuffer(GraphicsContext as VKGraphicsContext, this);
			if (base.FrameBuffer != null)
			{
				vKSwapChainFrameBuffer.IntermediateBufferAssociated = base.FrameBuffer.IntermediateBufferAssociated;
			}
			base.FrameBuffer = vKSwapChainFrameBuffer;
		}

		private  void DestroySwapChain()
		{
			if (vkSwapChain != VkSwapchainKHR.Null)
			{
				VulkanNative.vkDestroySwapchainKHR(vkContext.VkDevice, vkSwapChain, null);
				vkSwapChain = VkSwapchainKHR.Null;
				base.FrameBuffer?.Dispose();
			}
		}

		/// <inheritdoc />
		public override void RefreshSurfaceInfo(SurfaceInfo surfaceInfo)
		{
			SwapChainDescription swapChainDescription = base.SwapChainDescription;
			swapChainDescription.SurfaceInfo = surfaceInfo;
			base.SwapChainDescription = swapChainDescription;
			VulkanNative.vkDeviceWaitIdle(vkContext.VkDevice);
			DestroySwapChain();
			CreateSurface();
			CreateSwapChain();
			AcquireNextImage();
		}

		/// <inheritdoc />
		public override void ResizeSwapChain(uint32 width, uint32 height)
		{
			SwapChainDescription swapChainDescription = base.SwapChainDescription;
			swapChainDescription.Width = width;
			swapChainDescription.Height = height;
			base.SwapChainDescription = swapChainDescription;
			CreateSwapChain();
			AcquireNextImage();
		}

		/// <inheritdoc />
		public  override void Present()
		{
			VkSwapchainKHR vkSwapchainKHR = vkSwapChain;
			uint32 num = (uint32)currentBackBufferIndex;
			VkPresentInfoKHR vkPresentInfoKHR = default(VkPresentInfoKHR);
			vkPresentInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
			vkPresentInfoKHR.pNext = null;
			vkPresentInfoKHR.swapchainCount = 1u;
			vkPresentInfoKHR.pSwapchains = &vkSwapchainKHR;
			vkPresentInfoKHR.pImageIndices = &num;
			VulkanNative.vkQueuePresentKHR(vkPresentQueue, &vkPresentInfoKHR);
			AcquireNextImage();
		}

		/// <inheritdoc />
		public override void Dispose()
		{
			Dispose( /*disposing:*/true);
			/*GC.SuppressFinalize(this);*/
		}

		private  void AcquireNextImage()
		{
			uint32 num = (uint32)currentBackBufferIndex;
			VulkanNative.vkAcquireNextImageKHR(vkContext.VkDevice, vkSwapChain, uint64.MaxValue, VkSemaphore.Null, vkContext.vkImageAvailableFence, &num);
			CurrentBackBufferIndex = (int32)num;
			VkFence vkImageAvailableFence = vkContext.vkImageAvailableFence;
			VulkanNative.vkWaitForFences(vkContext.VkDevice, 1u, &vkImageAvailableFence, true, uint64.MaxValue);
			VulkanNative.vkResetFences(vkContext.VkDevice, 1u, &vkImageAvailableFence);
		}

		private  VkSurfaceFormatKHR ChooseSwapSurfaceFormat(VkSurfaceFormatKHR* formats, int32 length)
		{
			if (length == 1 && formats.format == VkFormat.VK_FORMAT_UNDEFINED)
			{
				VkSurfaceFormatKHR result = default(VkSurfaceFormatKHR);
				result.format = VkFormat.VK_FORMAT_B8G8R8A8_UNORM;
				result.colorSpace = VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;
				return result;
			}
			for (int32 i = 0; i < length; i++)
			{
				VkSurfaceFormatKHR result2 = formats[i];
				if (result2.format == base.SwapChainDescription.ColorTargetFormat.ToVulkan( /*depthFormat:*/false) && result2.colorSpace == VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
				{
					return result2;
				}
			}
			return *formats;
		}

		private  VkPresentModeKHR ChooseSwapPresentMode(VkPresentModeKHR* presentModes, int32 length)
		{
			VkPresentModeKHR result = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_KHR;
			if (VerticalSync)
			{
				if (Contains(presentModes, length, VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR))
				{
					result = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR;
				}
			}
			else if (Contains(presentModes, length, VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR))
			{
				result = VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR;
			}
			else if (Contains(presentModes, length, VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR))
			{
				result = VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR;
			}
			return result;
		}

		private  bool Contains(VkPresentModeKHR* allPresents, int32 length, VkPresentModeKHR presentMode)
		{
			for (int32 i = 0; i < length; i++)
			{
				if (allPresents[i] == presentMode)
				{
					return true;
				}
			}
			return false;
		}

		private VkExtent2D ChooseSwapExtent(VkSurfaceCapabilitiesKHR capabilities, uint32 width, uint32 height)
		{
			if (capabilities.currentExtent.width != uint32.MaxValue)
			{
				return capabilities.currentExtent;
			}
			VkExtent2D result = default(VkExtent2D);
			result.width = Clamp(width, capabilities.minImageExtent.width, capabilities.maxImageExtent.width);
			result.height = Clamp(height, capabilities.minImageExtent.height, capabilities.maxImageExtent.height);
			return result;
		}

		/// <summary>
		/// Clamp a uint32 value.
		/// </summary>
		/// <param name="value">Value to clamp.</param>
		/// <param name="min">Min value range.</param>
		/// <param name="max">Max value range.</param>
		/// <returns>clamped value.</returns>
		private uint32 Clamp(uint32 value, uint32 min, uint32 max)
		{
			if (value <= min)
			{
				return min;
			}
			if (value >= max)
			{
				return max;
			}
			return value;
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
		private  void Dispose(bool disposing)
		{
			if (!disposed)
			{
				if (disposing)
				{
					base.FrameBuffer?.Dispose();
					if(base.FrameBuffer != null)
						delete base.FrameBuffer;
					VulkanNative.vkDestroySwapchainKHR(vkContext.VkDevice, vkSwapChain, null);
					VulkanNative.vkDestroySurfaceKHR(vkContext.VkInstance, vkSurface, null);
				}
				disposed = true;
			}
		}
	}
}

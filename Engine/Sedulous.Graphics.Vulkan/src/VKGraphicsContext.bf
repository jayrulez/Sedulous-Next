using System;
using System.Text;
using Bulkan;
using Sedulous.Graphics;
using System.Collections;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;
	using internal Sedulous.Graphics.Vulkan;
	using Sedulous.Foundation.Utilities;

	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;

	/// <summary>
	/// Graphics context on Vulkan.
	/// </summary>
	public class VKGraphicsContext : GraphicsContext
	{
		internal  delegate VkResult vkDebugMarkerSetObjectNameEXT_t(VkDevice device, VkDebugMarkerObjectNameInfoEXT* pNameInfo);

		internal  delegate VkResult vkCreateDebugReportCallbackEXT_d(VkInstance instance, VkDebugReportCallbackCreateInfoEXT* createInfo, void* allocatorPtr, out VkDebugReportCallbackEXT ret);

		internal  delegate void vkDestroyDebugReportCallbackEXT_d(VkInstance instance, VkDebugReportCallbackEXT callback, VkAllocationCallbacks* pAllocator);

		internal  delegate VkResult vkDebugMarkerSetObjectNameEXT_d(VkDevice device, VkDebugMarkerObjectNameInfoEXT* pNameInfo);

		private const String PhysicalDevicePointerKey = "PhysicalDevice";

		private const String InstancePointerKey = "Instance";

		private const String GraphicsQueuePointerKey = "GraphicsQueue";

		private const String QueueIndicesPointerKey = "QueueIndices";

		private VKCapabilities capabilities;

		internal static readonly uint32 Version_1_2 = VKHelpers.Version(1, 2, 0);

		internal static readonly uint32 Version_1_1 = VKHelpers.Version(1, 1, 0);

		internal static readonly uint32 Version_1_0 = VKHelpers.Version(1, 0, 0);

		/// <summary>
		/// Vulkan device Object.
		/// </summary>
		public VkDevice VkDevice;

		/// <summary>
		/// Vulkan instance Object.
		/// </summary>
		public VkInstance VkInstance;

		/// <summary>
		/// Vulkan physical device Object.
		/// </summary>
		public VkPhysicalDevice VkPhysicalDevice;

		/// <summary>
		/// Vulkan physical device properties.
		/// </summary>
		public VkPhysicalDeviceProperties2 VkPhysicalDeviceProperties2;

		/// <summary>
		/// Vulkan physical device features.
		/// </summary>
		public VkPhysicalDeviceFeatures2 VkPhysicalDeviceFeatures2;

		/// <summary>
		/// Vulkan physical device memory properties.
		/// </summary>
		public VkPhysicalDeviceMemoryProperties VkPhysicalDeviceMemoryProperties;

		/// <summary>
		/// Structure describing the Vulkan 1.1 features that can be supported by an implementation.
		/// </summary>
		public VkPhysicalDeviceVulkan11Features features_1_1;

		/// <summary>
		/// Structure describing the Vulkan 1.2 features that can be supported by an implementation.
		/// </summary>
		public VkPhysicalDeviceVulkan12Features features_1_2;

		/// <summary>
		/// The vulkan command buffer used to copy commands.
		/// </summary>
		public VkCommandBuffer copyCommandBuffer;

		/// <summary>
		/// The supported queue indices.
		/// </summary>
		internal VKQueueFamilyIndices QueueIndices;

		private VkQueue vkGraphicsQueue;

		private VkCommandPool copyCommandPool;

		private VkQueue vkCopyQueue;

		private VkFence vkCopyFence;

		internal VkFence vkImageAvailableFence;

		internal VKDescriptorSetPool DescriptorPool;

		internal VKUploadBuffer BufferUploader;

		internal VKUploadBuffer TextureUploader;

		internal bool DebugUtilsEnabled;

		internal bool DebugMarkerEnabled;

		internal bool ClipSpaceYInvertedSupported;

		internal bool CopyQueueSupported;

		internal bool raytracingSupported;

		/// <summary>
		/// Whether the Object is disposed.
		/// </summary>
		protected bool disposed;

		private VkDebugUtilsMessengerEXT debugUtilsCallbackHandle;

		private PFN_vkDebugUtilsMessengerCallbackEXT debugUtilsMessegerCallbackFunc;

		private VkDebugReportCallbackEXT debugCallbackHandle;

		private PFN_vkDebugReportCallbackEXT debugCallbackFunc;

		/// <summary>
		/// Set of device extensions to be enabled for this application.
		/// </summary>
		/// <remarks>
		/// Must be set before create device.
		/// </remarks>
		public readonly Span<String> DeviceExtensionsToEnable;

		/// <summary>
		/// Set of device instance extensions to be enabled for this application.
		/// </summary>
		/// <remarks>
		/// Must be set before create device.
		/// </remarks>
		public readonly Span<String> InstanceExtensionsToEnable;

		/// <inheritdoc />
		public override void* NativeDevicePointer => (void*)VkDevice.Handle;

		/// <inheritdoc />
		public override GraphicsBackend BackendType => GraphicsBackend.Vulkan;

		/// <inheritdoc />
		public override GraphicsContextCapabilities Capabilities => capabilities;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKGraphicsContext" /> class.
		/// </summary>
		public this()
			: this(Span<String>(), Span<String>())
		{
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKGraphicsContext" /> class.
		/// </summary>
		/// <param name="deviceExtensionsToEnable">Set of device extensions to be enabled for this application.</param>
		/// <param name="instanceExtensionsToEnable">Set of device instance extensions to be enabled for this application.</param>
		public this(Span<String> deviceExtensionsToEnable, Span<String> instanceExtensionsToEnable)
		{
			base.Factory = new VKResourceFactory(this);
			DeviceExtensionsToEnable = deviceExtensionsToEnable;
			InstanceExtensionsToEnable = instanceExtensionsToEnable;
		}

		/// <inheritdoc />
		public override void CreateDeviceInternal()
		{
			VulkanNative.Initialize();
			VulkanNative.SetLoadFunctionErrorCallBack(new (functionName) =>
			{
				//GetLogger().LogError(scope $"Failed to load function: '{functionName}'.");
				Console.WriteLine(scope $"Failed to load function: '{functionName}'.");
			} );
			
			VulkanNative.LoadPreInstanceFunctions();
			CreateInstance();
			//VulkanNative.LoadPostInstanceFunctions();
			CreatePhysicalDevice();
			CreateLogicalDevice();
			CreateResourcesForCopyQueue();
			CreateSemaphoresAndFences();
			capabilities = new VKCapabilities(this);
			DescriptorPool = new VKDescriptorSetPool(this);
			BufferUploader = new VKUploadBuffer(this, base.DefaultBufferUploaderSize);
			TextureUploader = new VKUploadBuffer(this, base.DefaultTextureUploaderSize);
		}

		/// <inheritdoc />
		public override SwapChain CreateSwapChain(SwapChainDescription description)
		{
			//_ = VkDevice;
			return new VKSwapChain(this, description);
		}

		/// <inheritdoc />
		public override CompilationResult ShaderCompile(String shaderSource, String entryPoint, ShaderStages stage, CompilerParameters parameters)
		{
			return default(CompilationResult);
		}

		/// <inheritdoc />
		public override bool GenerateTextureMipmapping(Texture texture)
		{
			return false;
		}

		/// <inheritdoc />
		public  override MappedResource MapMemory(GraphicsResource resource, MapMode mode, uint32 subResource = 0u)
		{
			if (resource is VKBuffer)
			{
				VKBuffer vKBuffer = resource as VKBuffer;
				void* ptr = default(void*);
				VulkanNative.vkMapMemory(VkDevice, vKBuffer.BufferMemory, 0uL, vKBuffer.Description.SizeInBytes, 0u, &ptr);
				return MappedResource(resource, mode, (void*)ptr, vKBuffer.Description.SizeInBytes);
			}
			if (resource is VKTexture)
			{
				VKTexture vKTexture = resource as VKTexture;
				SubResourceInfo subResourceInfo = Helpers.GetSubResourceInfo(vKTexture.Description, subResource);
				if ((vKTexture.Description.Usage & ResourceUsage.Staging) != 0)
				{
					void* ptr2 = default(void*);
					VulkanNative.vkMapMemory(VkDevice, vKTexture.BufferMemory, subResourceInfo.Offset, subResourceInfo.SizeInBytes, 0u, &ptr2);
					return MappedResource(resource, mode, (void*)ptr2, subResourceInfo.SizeInBytes, subResource, subResourceInfo.RowPitch, subResourceInfo.SlicePitch);
				}
				void* ptr3 = default(void*);
				VulkanNative.vkMapMemory(VkDevice, vKTexture.ImageMemory, subResourceInfo.Offset, subResourceInfo.SizeInBytes, 0u, &ptr3);
				return MappedResource(resource, mode, (void*)ptr3, (uint32)vKTexture.MemoryRequirements.size, subResource, subResourceInfo.RowPitch, subResourceInfo.SlicePitch);
			}
			base.ValidationLayer?.Notify("Vulkan", "This operation is only supported to buffers and textures.");
			return default(MappedResource);
		}

		/// <inheritdoc />
		public override void UnmapMemory(GraphicsResource resource, uint32 subResource = 0)
		{
			if (resource is VKBuffer)
			{
				VKBuffer vKBuffer = resource as VKBuffer;
				VulkanNative.vkUnmapMemory(VkDevice, vKBuffer.BufferMemory);
			}
			else if (resource is VKTexture)
			{
				VKTexture vKTexture = resource as VKTexture;
				if ((vKTexture.Description.Usage & ResourceUsage.Staging) != 0)
				{
					VulkanNative.vkUnmapMemory(VkDevice, vKTexture.BufferMemory);
				}
				else
				{
					VulkanNative.vkUnmapMemory(VkDevice, vKTexture.ImageMemory);
				}
			}
			else
			{
				base.ValidationLayer?.Notify("Vulkan", "This operation is only supported to buffers and textures.");
			}
		}

		/// <inheritdoc />
		protected override void InternalUpdateBufferData(Sedulous.Graphics.Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
		{
			(buffer as VKBuffer).SetData(copyCommandBuffer, source, sourceSizeInBytes, destinationOffsetInBytes);
		}

		/// <inheritdoc />
		public override void UpdateTextureData(Texture texture, void* source, uint32 sourceSizeInBytes, uint32 subResource)
		{
			(texture as VKTexture).SetData(copyCommandBuffer, source, sourceSizeInBytes, subResource);
		}

		/// <inheritdoc />
		public  override void SyncUpcopyQueue()
		{
			VkCommandBuffer commandBuffer = copyCommandBuffer;
			VulkanNative.vkEndCommandBuffer(commandBuffer);
			VkSubmitInfo vkSubmitInfo = default(VkSubmitInfo);
			vkSubmitInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_SUBMIT_INFO;
			vkSubmitInfo.commandBufferCount = 1;
			vkSubmitInfo.pCommandBuffers = &commandBuffer;
			VulkanNative.vkQueueSubmit(vkCopyQueue, 1, &vkSubmitInfo, vkCopyFence);
			VkFence vkFence = vkCopyFence;
			VulkanNative.vkWaitForFences(VkDevice, 1, &vkFence, VkBool32.True, uint64.MaxValue);
			VulkanNative.vkResetFences(VkDevice, 1, &vkFence);
			VulkanNative.vkResetCommandPool(VkDevice, copyCommandPool, VkCommandPoolResetFlags.None);
			VkCommandBufferBeginInfo vkCommandBufferBeginInfo = default(VkCommandBufferBeginInfo);
			vkCommandBufferBeginInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
			vkCommandBufferBeginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
			VulkanNative.vkBeginCommandBuffer(copyCommandBuffer, &vkCommandBufferBeginInfo);
			BufferUploader.Clear();
			TextureUploader.Clear();
		}

		private  void CreateInstance()
		{
			String[] availableInstanceLayers = VKHelpers.EnumerateInstanceLayers(this, .. ?);
			defer {DeleteContainerAndItems!(availableInstanceLayers);}

			String[] availableInstanceExtensions = VKHelpers.EnumerateInstanceExtensions(this, .. ?);
			defer {DeleteContainerAndItems!(availableInstanceExtensions);}

			List<char8*> instanceExtensionEnabled = scope List<char8*>();
			List<char8*> instanceLayersEnabled = scope List<char8*>();
			CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_KHR_surface");
			switch (VKHelpers.GetCurrentPlatfom())
			{
			case VKHelpers.OS.Windows:
				CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_KHR_win32_surface");
				break;
			case VKHelpers.OS.Linux:
				CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_KHR_xlib_surface");
				break;
			case VKHelpers.OS.Android:
				CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_KHR_android_surface");
				break;
			case VKHelpers.OS.MacOS:
				CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_MVK_macos_surface");
				break;
			case VKHelpers.OS.iOS:
				CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_MVK_ios_surface");
				break;
			}
			for (String instanceExtensionToEnable in InstanceExtensionsToEnable)
			{
				CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, instanceExtensionToEnable);
			}
			if (availableInstanceExtensions.Contains("VK_KHR_get_physical_device_properties2"))
			{
				instanceExtensionEnabled.Add("VK_KHR_get_physical_device_properties2");
			}
			if (base.IsValidationLayerEnabled)
			{
				if (availableInstanceExtensions.Contains("VK_EXT_debug_utils"))
				{
					instanceExtensionEnabled.Add("VK_EXT_debug_utils");
					DebugUtilsEnabled = true;
					DebugMarkerEnabled = true;
				}
				else
				{
					instanceExtensionEnabled.Add("VK_EXT_debug_report");
				}
				switch (VKHelpers.GetCurrentPlatfom())
				{
				case VKHelpers.OS.Windows:
					if (availableInstanceLayers.Contains("VK_LAYER_KHRONOS_validation"))
					{
						instanceLayersEnabled.Add("VK_LAYER_KHRONOS_validation");
					}
					break;
				case VKHelpers.OS.Android:
					if (availableInstanceLayers.Contains("VK_LAYER_LUNARG_core_validation"))
					{
						instanceLayersEnabled.Add("VK_LAYER_LUNARG_core_validation");
					}
					if (availableInstanceLayers.Contains("VK_LAYER_LUNARG_swapchain"))
					{
						instanceLayersEnabled.Add("VK_LAYER_LUNARG_swapchain");
					}
					if (availableInstanceLayers.Contains("VK_LAYER_LUNARG_parameter_validation"))
					{
						instanceLayersEnabled.Add("VK_LAYER_LUNARG_parameter_validation");
					}
					break;
				default:break;
				}
			}
			VkApplicationInfo vkApplicationInfo = default(VkApplicationInfo);
			vkApplicationInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_APPLICATION_INFO;
			vkApplicationInfo.apiVersion = Version_1_2;
			vkApplicationInfo.applicationVersion = Version_1_0;
			vkApplicationInfo.engineVersion = Version_1_0;
			vkApplicationInfo.pEngineName = "Sedulous";
			vkApplicationInfo.pApplicationName = "Sedulous";
			VkApplicationInfo vkApplicationInfo2 = vkApplicationInfo;

			VkInstanceCreateInfo vkInstanceCreateInfo = default(VkInstanceCreateInfo);
			vkInstanceCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
			vkInstanceCreateInfo.pApplicationInfo = &vkApplicationInfo2;
			vkInstanceCreateInfo.enabledLayerCount = (uint32)instanceLayersEnabled.Count;
			vkInstanceCreateInfo.ppEnabledLayerNames = instanceLayersEnabled.Ptr;
			vkInstanceCreateInfo.enabledExtensionCount = (uint32)instanceExtensionEnabled.Count;
			vkInstanceCreateInfo.ppEnabledExtensionNames = instanceExtensionEnabled.Ptr;
			VkDebugUtilsMessengerCreateInfoEXT vkDebugUtilsMessengerCreateInfoEXT = .();
			VkDebugReportCallbackCreateInfoEXT vkDebugReportCallbackCreateInfoEXT = .();
			if (base.IsValidationLayerEnabled)
			{
				if (DebugUtilsEnabled)
				{
					vkDebugUtilsMessengerCreateInfoEXT.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
					vkDebugUtilsMessengerCreateInfoEXT.messageSeverity = VkDebugUtilsMessageSeverityFlagsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VkDebugUtilsMessageSeverityFlagsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
					vkDebugUtilsMessengerCreateInfoEXT.messageType = VkDebugUtilsMessageTypeFlagsEXT.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT;
					debugUtilsMessegerCallbackFunc = => DebugUtilsMessengerCallback;
					vkDebugUtilsMessengerCreateInfoEXT.pfnUserCallback = debugUtilsMessegerCallbackFunc;
					vkInstanceCreateInfo.pNext = &vkDebugUtilsMessengerCreateInfoEXT;
					vkDebugUtilsMessengerCreateInfoEXT.pUserData = Internal.UnsafeCastToPtr(this);
				}
				else
				{
					vkDebugReportCallbackCreateInfoEXT.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT;
					vkDebugReportCallbackCreateInfoEXT.flags = VkDebugReportFlagsEXT.VK_DEBUG_REPORT_WARNING_BIT_EXT | VkDebugReportFlagsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT;
					debugCallbackFunc = => DebugCallback;
					vkDebugReportCallbackCreateInfoEXT.pfnCallback = debugCallbackFunc;
					vkDebugReportCallbackCreateInfoEXT.pUserData = Internal.UnsafeCastToPtr(this);
					vkInstanceCreateInfo.pNext = &vkDebugReportCallbackCreateInfoEXT;
				}
			}
			VkInstance vkInstance = default(VkInstance);
			VkResult result = VulkanNative.vkCreateInstance(&vkInstanceCreateInfo, null, &vkInstance);
			if(result != .VK_SUCCESS){
				Runtime.FatalError("Failed to create instance.");
			}
			VkInstance = vkInstance;

			VulkanNative.LoadInstanceFunctions(vkInstance);

			VulkanNative.LoadPostInstanceFunctions();

			if (base.IsValidationLayerEnabled)
			{
				if (DebugUtilsEnabled)
				{
					VkDebugUtilsMessengerEXT vkDebugUtilsMessengerEXT = default(VkDebugUtilsMessengerEXT);
					VulkanNative.vkCreateDebugUtilsMessengerEXT(VkInstance, &vkDebugUtilsMessengerCreateInfoEXT, null, &vkDebugUtilsMessengerEXT);
					debugUtilsCallbackHandle = vkDebugUtilsMessengerEXT;
				}
				else
				{
					VkDebugReportCallbackEXT vkDebugReportCallbackEXT = default(VkDebugReportCallbackEXT);
					VulkanNative.vkCreateDebugReportCallbackEXT(VkInstance, &vkDebugReportCallbackCreateInfoEXT, null, &vkDebugReportCallbackEXT);
					debugCallbackHandle = vkDebugReportCallbackEXT;
				}
			}
		}

		private void CheckExtension(String[] availableinstanceExtensions, List<char8*> extensionsToEnable, String @extension)
		{
			if(availableinstanceExtensions.Contains(@extension)){
				extensionsToEnable.Add(@extension);
			}else{
				base.ValidationLayer?.Notify("Vulkan", scope $"The required instance extensions was not available: {@extension}");
			}
		}

		private static VkBool32 DebugUtilsMessengerCallback(VkDebugUtilsMessageSeverityFlagsEXT messageSeverity, uint32 messageTypes, VkDebugUtilsMessengerCallbackDataEXT* pCallbackData, void* pUserData)
		{
			GraphicsContext context = (VKGraphicsContext)Internal.UnsafeCastToObject(pUserData);
			int32 messageIdNumber = pCallbackData.messageIdNumber;
			String message = scope $"[{(VkDebugUtilsMessageTypeFlagsEXT)messageTypes}] ({messageIdNumber}) {scope String(pCallbackData.pMessage)}";
			if (messageSeverity == VkDebugUtilsMessageSeverityFlagsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT)
			{
				context.ValidationLayer?.Notify("Vulkan", message);
			}
			return false;
		}

		private static VkBool32 DebugCallback(uint32 flags, VkDebugReportObjectTypeEXT objectType, uint64 @Object, uint location, int32 messageCode, char8* pLayerPrefix, char8* pMessage, void* pUserData)
		{
			GraphicsContext context = (VKGraphicsContext)Internal.UnsafeCastToObject(pUserData);
			String message = scope $"[{(VkDebugReportFlagsEXT)flags}] ({objectType}) {scope String(pMessage)}";
			if (flags == 8)
			{
				context.ValidationLayer?.Notify("Vulkan", message);
			}
			return false;
		}

		private  void CreatePhysicalDevice()
		{
			uint32 num = 0u;
			VulkanNative.vkEnumeratePhysicalDevices(VkInstance, &num, null);
			if (num == 0)
			{
				base.ValidationLayer?.Notify("Vulkan", "No physical devices exist.");
			}
			VkPhysicalDevice* ptr = scope VkPhysicalDevice[(int32)num]*;
			VulkanNative.vkEnumeratePhysicalDevices(VkInstance, &num, ptr);
			VkPhysicalDeviceProperties2 vkPhysicalDeviceProperties = default(VkPhysicalDeviceProperties2);
			vkPhysicalDeviceProperties.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2;
			if (num != 0)
			{
				VkPhysicalDevice @null = /*VkPhysicalDevice*/.Null;
				for (uint32 num2 = 0u; num2 < num; num2++)
				{
					@null = ptr[num2];
					VulkanNative.vkGetPhysicalDeviceProperties2(@null, &vkPhysicalDeviceProperties);
					if (vkPhysicalDeviceProperties.properties.deviceType == VkPhysicalDeviceType.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU)
					{
						VkPhysicalDevice = @null;
						break;
					}
				}
				if (VkPhysicalDevice == /*VkPhysicalDevice*/.Null)
				{
					VkPhysicalDevice = *ptr;
				}
			}
			if (VkPhysicalDevice == /*VkPhysicalDevice*/.Null)
			{
				base.ValidationLayer?.Notify("Vulkan", "Failed to find a suitable GPU");
			}
			VkPhysicalDeviceVulkan11Properties vkPhysicalDeviceVulkan11Properties = default(VkPhysicalDeviceVulkan11Properties);
			vkPhysicalDeviceVulkan11Properties.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_PROPERTIES;
			VkPhysicalDeviceVulkan12Properties vkPhysicalDeviceVulkan12Properties = default(VkPhysicalDeviceVulkan12Properties);
			vkPhysicalDeviceVulkan12Properties.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_PROPERTIES;
			vkPhysicalDeviceProperties.pNext = &vkPhysicalDeviceVulkan11Properties;
			vkPhysicalDeviceVulkan11Properties.pNext = &vkPhysicalDeviceVulkan12Properties;
			VkPhysicalDeviceProperties2 = vkPhysicalDeviceProperties;
			if (VkPhysicalDeviceProperties2.properties.apiVersion >= Version_1_1)
			{
				vkPhysicalDeviceProperties.pNext = &vkPhysicalDeviceVulkan11Properties;
				if (VkPhysicalDeviceProperties2.properties.apiVersion >= Version_1_2)
				{
					vkPhysicalDeviceVulkan11Properties.pNext = &vkPhysicalDeviceVulkan12Properties;
				}
			}
			VulkanNative.vkGetPhysicalDeviceProperties2(VkPhysicalDevice, &vkPhysicalDeviceProperties);
			VkPhysicalDeviceFeatures2 vkPhysicalDeviceFeatures = default(VkPhysicalDeviceFeatures2);
			vkPhysicalDeviceFeatures.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2;
			VulkanNative.vkGetPhysicalDeviceFeatures2(VkPhysicalDevice, &vkPhysicalDeviceFeatures);
			VkPhysicalDeviceFeatures2 = vkPhysicalDeviceFeatures;
			VkPhysicalDeviceMemoryProperties vkPhysicalDeviceMemoryProperties = default(VkPhysicalDeviceMemoryProperties);
			VulkanNative.vkGetPhysicalDeviceMemoryProperties(VkPhysicalDevice, &vkPhysicalDeviceMemoryProperties);
			VkPhysicalDeviceMemoryProperties = vkPhysicalDeviceMemoryProperties;
			TimestampFrequency = (uint64)(1.0 / (double)vkPhysicalDeviceProperties.properties.limits.timestampPeriod * 1000.0 * 1000.0 * 1000.0);
		}

		private  void CreateLogicalDevice()
		{
			QueueIndices = VKQueueFamilyIndices.FindQueueFamilies(this, VkPhysicalDevice, null);
			float priorities = 1f;
			int32 queueCount = ((QueueIndices.CopyFamily == -1) ? 1 : 2);
			VkDeviceQueueCreateInfo vkDeviceQueueCreateInfo = default(VkDeviceQueueCreateInfo);
			vkDeviceQueueCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
			vkDeviceQueueCreateInfo.queueFamilyIndex = (uint32)QueueIndices.GraphicsFamily;
			vkDeviceQueueCreateInfo.queueCount = 1u;
			vkDeviceQueueCreateInfo.pQueuePriorities = &priorities;
			VkDeviceQueueCreateInfo* queueCreateInfos = scope VkDeviceQueueCreateInfo[queueCount]*;
			*queueCreateInfos = vkDeviceQueueCreateInfo;
			CopyQueueSupported = QueueIndices.CopyFamily != -1;
			if (CopyQueueSupported)
			{
				VkDeviceQueueCreateInfo vkDeviceQueueCreateInfo2 = default(VkDeviceQueueCreateInfo);
				vkDeviceQueueCreateInfo2.sType = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
				vkDeviceQueueCreateInfo2.queueFamilyIndex = (uint32)QueueIndices.CopyFamily;
				vkDeviceQueueCreateInfo2.queueCount = 1u;
				vkDeviceQueueCreateInfo2.pQueuePriorities = &priorities;
				queueCreateInfos[1] = vkDeviceQueueCreateInfo2;
			}
			uint32 deviceExtensionCount = 0u;
			VkResult result = VulkanNative.vkEnumerateDeviceExtensionProperties(VkPhysicalDevice, null, &deviceExtensionCount, null);
			//ReturnOnFailure!();
			if(result != .VK_SUCCESS){
				Runtime.FatalError("Failed to enumerate device extensions");
			}
			VkExtensionProperties* deviceExtensions = scope VkExtensionProperties[(int32)deviceExtensionCount]*;
			result = VulkanNative.vkEnumerateDeviceExtensionProperties(VkPhysicalDevice, null, &deviceExtensionCount, deviceExtensions);
			if(result != .VK_SUCCESS){
				Runtime.FatalError("Failed to enumerate device extensions");
			}
			List<char8*> enabledExtensions = scope List<char8*>();
			for (int i = 0; i < deviceExtensionCount; i++)
			{
				String availableExtension = scope :: String(&deviceExtensions[i].extensionName);
				switch (availableExtension)
				{
				case "VK_KHR_swapchain": fallthrough;
				case "VK_EXT_shader_viewport_index_layer": fallthrough;
				case "VK_NV_viewport_array2":
					enabledExtensions.Add(availableExtension);
					break;
				case "VK_EXT_debug_marker":
					enabledExtensions.Add(availableExtension);
					DebugMarkerEnabled = true;
					break;
				case "VK_KHR_maintenance1":
					ClipSpaceYInvertedSupported = true;
					enabledExtensions.Add(availableExtension);
					break;
				case "VK_KHR_spirv_1_4":
					enabledExtensions.Add(availableExtension);
					break;
				case "VK_KHR_acceleration_structure":
					enabledExtensions.Add(availableExtension);
					break;
				case "VK_KHR_ray_tracing_pipeline":
					raytracingSupported = true;
					enabledExtensions.Add(availableExtension);
					break;
				case "VK_KHR_deferred_host_operations":
					enabledExtensions.Add(availableExtension);
					break;
				}
			}

			for(String deviceExtensionToEnable in DeviceExtensionsToEnable){
				enabledExtensions.Add(deviceExtensionToEnable);
			}

			VkPhysicalDeviceFeatures2 vkPhysicalDeviceFeatures = default(VkPhysicalDeviceFeatures2);
			VkPhysicalDeviceVulkan11Features vkPhysicalDeviceVulkan11Features = default(VkPhysicalDeviceVulkan11Features);
			VkPhysicalDeviceVulkan12Features vkPhysicalDeviceVulkan12Features = default(VkPhysicalDeviceVulkan12Features);
			VkPhysicalDeviceAccelerationStructureFeaturesKHR vkPhysicalDeviceAccelerationStructureFeaturesKHR = default(VkPhysicalDeviceAccelerationStructureFeaturesKHR);
			VkPhysicalDeviceRayTracingPipelineFeaturesKHR vkPhysicalDeviceRayTracingPipelineFeaturesKHR = default(VkPhysicalDeviceRayTracingPipelineFeaturesKHR);
			vkPhysicalDeviceFeatures.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2;
			vkPhysicalDeviceFeatures.features.samplerAnisotropy = VkPhysicalDeviceFeatures2.features.samplerAnisotropy;
			vkPhysicalDeviceFeatures.features.fillModeNonSolid = VkPhysicalDeviceFeatures2.features.fillModeNonSolid;
			vkPhysicalDeviceFeatures.features.geometryShader = VkPhysicalDeviceFeatures2.features.geometryShader;
			vkPhysicalDeviceFeatures.features.depthClamp = VkPhysicalDeviceFeatures2.features.depthClamp;
			vkPhysicalDeviceFeatures.features.multiViewport = VkPhysicalDeviceFeatures2.features.multiViewport;
			vkPhysicalDeviceFeatures.features.textureCompressionBC = VkPhysicalDeviceFeatures2.features.textureCompressionBC;
			vkPhysicalDeviceFeatures.features.textureCompressionETC2 = VkPhysicalDeviceFeatures2.features.textureCompressionETC2;
			vkPhysicalDeviceFeatures.features.multiDrawIndirect = VkPhysicalDeviceFeatures2.features.multiDrawIndirect;
			vkPhysicalDeviceFeatures.features.drawIndirectFirstInstance = VkPhysicalDeviceFeatures2.features.drawIndirectFirstInstance;
			vkPhysicalDeviceFeatures.features.tessellationShader = VkPhysicalDeviceFeatures2.features.tessellationShader;
			vkPhysicalDeviceFeatures.features.imageCubeArray = VkPhysicalDeviceFeatures2.features.imageCubeArray;
			vkPhysicalDeviceFeatures.features.occlusionQueryPrecise = VkPhysicalDeviceFeatures2.features.occlusionQueryPrecise;
			vkPhysicalDeviceFeatures.features.shaderStorageImageMultisample = VkPhysicalDeviceFeatures2.features.shaderStorageImageMultisample;
			if (VkPhysicalDeviceProperties2.properties.apiVersion >= Version_1_1)
			{
				vkPhysicalDeviceFeatures.pNext = &vkPhysicalDeviceVulkan11Features;
				vkPhysicalDeviceVulkan11Features.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES;
				vkPhysicalDeviceVulkan11Features.multiview = VkBool32.True;
				if (VkPhysicalDeviceProperties2.properties.apiVersion >= Version_1_2)
				{
					vkPhysicalDeviceVulkan11Features.pNext = &vkPhysicalDeviceVulkan12Features;
					vkPhysicalDeviceVulkan12Features.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES;
					vkPhysicalDeviceVulkan12Features.shaderOutputViewportIndex = true;
					vkPhysicalDeviceVulkan12Features.shaderOutputLayer = true;
					vkPhysicalDeviceVulkan12Features.hostQueryReset = true;
					vkPhysicalDeviceVulkan12Features.bufferDeviceAddress = true;
				}
			}
			if (raytracingSupported)
			{
				vkPhysicalDeviceAccelerationStructureFeaturesKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR;
				vkPhysicalDeviceAccelerationStructureFeaturesKHR.accelerationStructure = true;
				vkPhysicalDeviceVulkan12Features.pNext = &vkPhysicalDeviceAccelerationStructureFeaturesKHR;
				vkPhysicalDeviceRayTracingPipelineFeaturesKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR;
				vkPhysicalDeviceRayTracingPipelineFeaturesKHR.rayTracingPipeline = true;
				vkPhysicalDeviceAccelerationStructureFeaturesKHR.pNext = &vkPhysicalDeviceRayTracingPipelineFeaturesKHR;
			}
			features_1_1 = vkPhysicalDeviceVulkan11Features;
			features_1_2 = vkPhysicalDeviceVulkan12Features;
			VkDeviceCreateInfo vkDeviceCreateInfo = default(VkDeviceCreateInfo);
			vkDeviceCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
			vkDeviceCreateInfo.enabledExtensionCount = (uint32)enabledExtensions.Count;
			vkDeviceCreateInfo.ppEnabledExtensionNames = enabledExtensions.Ptr;
			vkDeviceCreateInfo.queueCreateInfoCount = (uint32)queueCount;
			vkDeviceCreateInfo.pQueueCreateInfos = queueCreateInfos;
			vkDeviceCreateInfo.pEnabledFeatures = null;
			vkDeviceCreateInfo.pNext = &vkPhysicalDeviceFeatures;
			VkDevice vkDevice = default(VkDevice);
			result = VulkanNative.vkCreateDevice(VkPhysicalDevice, &vkDeviceCreateInfo, null, &vkDevice);
			if(result != .VK_SUCCESS){
				Runtime.FatalError("Failed to create device.");
			}
			VkDevice = vkDevice;
			VkQueue vkQueue = default(VkQueue);
			VulkanNative.vkGetDeviceQueue(VkDevice, (uint32)QueueIndices.GraphicsFamily, 0, &vkQueue);
			vkGraphicsQueue = vkQueue;
		}

		private  void CreateResourcesForCopyQueue()
		{
			uint32 queueFamilyIndex = (CopyQueueSupported ? ((uint32)QueueIndices.CopyFamily) : 0u);
			VkQueue vkQueue = default(VkQueue);
			VulkanNative.vkGetDeviceQueue(VkDevice, queueFamilyIndex, 0u, &vkQueue);
			vkCopyQueue = vkQueue;
			VkCommandPoolCreateInfo vkCommandPoolCreateInfo = default(VkCommandPoolCreateInfo);
			vkCommandPoolCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
			vkCommandPoolCreateInfo.queueFamilyIndex = queueFamilyIndex;
			VkCommandPool vkCommandPool = default(VkCommandPool);
			VulkanNative.vkCreateCommandPool(VkDevice, &vkCommandPoolCreateInfo, null, &vkCommandPool);
			copyCommandPool = vkCommandPool;
			VkCommandBufferAllocateInfo vkCommandBufferAllocateInfo = default(VkCommandBufferAllocateInfo);
			vkCommandBufferAllocateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
			vkCommandBufferAllocateInfo.commandBufferCount = 1u;
			vkCommandBufferAllocateInfo.commandPool = copyCommandPool;
			vkCommandBufferAllocateInfo.level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY;
			VkCommandBuffer vkCommandBuffer = default(VkCommandBuffer);
			VulkanNative.vkAllocateCommandBuffers(VkDevice, &vkCommandBufferAllocateInfo, &vkCommandBuffer);
			copyCommandBuffer = vkCommandBuffer;
			VkCommandBufferBeginInfo vkCommandBufferBeginInfo = default(VkCommandBufferBeginInfo);
			vkCommandBufferBeginInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
			vkCommandBufferBeginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
			VulkanNative.vkBeginCommandBuffer(copyCommandBuffer, &vkCommandBufferBeginInfo);
			VkFenceCreateInfo vkFenceCreateInfo = default(VkFenceCreateInfo);
			vkFenceCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
			VkFence vkFence = default(VkFence);
			VulkanNative.vkCreateFence(VkDevice, &vkFenceCreateInfo, null, &vkFence);
			vkCopyFence = vkFence;
		}

		private  void CreateSemaphoresAndFences()
		{
			VkFenceCreateInfo vkFenceCreateInfo = default(VkFenceCreateInfo);
			vkFenceCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
			VkFence vkFence = default(VkFence);
			VulkanNative.vkCreateFence(VkDevice, &vkFenceCreateInfo, null, &vkFence);
			vkImageAvailableFence = vkFence;
		}

		internal  void SetDebugName(VkObjectType type, uint64 target, String name)
		{
			if (DebugMarkerEnabled && !String.IsNullOrEmpty(name))
			{
				VkDebugUtilsObjectNameInfoEXT vkDebugUtilsObjectNameInfoEXT = default(VkDebugUtilsObjectNameInfoEXT);
				vkDebugUtilsObjectNameInfoEXT.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT;
				vkDebugUtilsObjectNameInfoEXT.objectHandle = target;
				vkDebugUtilsObjectNameInfoEXT.objectType = type;
				vkDebugUtilsObjectNameInfoEXT.pObjectName = name.CStr();
				VulkanNative.vkSetDebugUtilsObjectNameEXT(VkDevice, &vkDebugUtilsObjectNameInfoEXT);
			}
		}

		public ~this(){

			OnDestroy();

			if(BufferUploader!= null)
			delete BufferUploader;
			
			if(TextureUploader!= null)
			delete TextureUploader;

			if(capabilities != null)
				delete capabilities;

			if(DescriptorPool != null){
			DescriptorPool.DestroyAll();
				delete DescriptorPool;
			}
			
			delete Factory;
			
			VulkanNative.vkDestroyFence(VkDevice, vkCopyFence, null);
			VulkanNative.vkDestroyCommandPool(VkDevice, copyCommandPool, null);
			VulkanNative.vkDestroyFence(VkDevice, vkImageAvailableFence, null);
			VulkanNative.vkDestroyDevice(VkDevice, null);

			if (debugCallbackFunc != null)
			{
				debugCallbackFunc = null;
				VulkanNative.vkDestroyDebugReportCallbackEXTFunction destroyFunction = => VulkanNative.vkDestroyDebugReportCallbackEXT;//(.)VulkanNative.vkGetInstanceProcAddr(VkInstance, "vkDestroyDebugReportCallbackEXT");
				destroyFunction(VkInstance, debugCallbackHandle, null);
			}
			VulkanNative.vkDestroyInstance(VkInstance, null);
		}

		/// <inheritdoc />
		/*protected  override void Dispose(bool disposing)
		{
			if (!disposed)
			{
				if (debugCallbackFunc != null)
				{
					//BufferUploader?.Dispose();
					//TextureUploader?.Dispose();
					//VulkanNative.vkDestroyFence(VkDevice, vkCopyFence, null);
					//DescriptorPool.DestroyAll();
					//VulkanNative.vkDestroyCommandPool(VkDevice, copyCommandPool, null);
					//VulkanNative.vkDestroyFence(VkDevice, vkImageAvailableFence, null);
					//VulkanNative.vkDestroyDevice(VkDevice, null);
					//debugCallbackFunc = null;
					//VulkanNative.vkDestroyDebugReportCallbackEXTFunction destroyFunction = (.)VulkanNative.vkGetInstanceProcAddr(VkInstance, "vkDestroyDebugReportCallbackEXT");
					//destroyFunction(VkInstance, debugCallbackHandle, null);
					//VulkanNative.vkDestroyInstance(VkInstance, null);
				}
				disposed = true;
			}
		}*/
	}
}

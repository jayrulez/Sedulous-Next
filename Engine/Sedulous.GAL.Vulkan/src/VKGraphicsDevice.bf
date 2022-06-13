using System;
using System.Diagnostics;
using System.Text;
using Bulkan;
using System.Threading;
using System.Collections;
using static Sedulous.GAL.Vulkan.VulkanUtil;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.Vulkan
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.Vulkan;

	internal class Stack<T>
	{
		private Queue<T> _storage = new .() ~ delete _;

		public int Count => _storage.Count;

		public void Push(T item)
		{
			_storage.Add(item);
		}

		public T Pop()
		{
			return _storage.PopBack();
		}
	}

	internal  class VKGraphicsDevice : GraphicsDevice
	{
		private static readonly String s_name = "Sedulous.GAL-VkGraphicsDevice";

		private VkInstance _instance;
		private VkPhysicalDevice _physicalDevice;
		private GraphicsApiVersion _apiVersion;
		private String _deviceName = new String() ~ delete _;
		private String _vendorName = new String() ~ delete _;
		private String _driverName = new String() ~ delete _;
		private String _driverInfo = new String() ~ delete _;
		private VKDeviceMemoryManager _memoryManager;
		private VkPhysicalDeviceProperties _physicalDeviceProperties;
		private VkPhysicalDeviceFeatures _physicalDeviceFeatures;
		private VkPhysicalDeviceMemoryProperties _physicalDeviceMemProperties;
		private VkDevice _device;
		private uint32 _graphicsQueueIndex;
		private uint32 _presentQueueIndex;
		private VkCommandPool _graphicsCommandPool;
		private readonly Monitor _graphicsCommandPoolLock = new .() ~ delete _;
		private VkQueue _graphicsQueue;
		private readonly Monitor _graphicsQueueLock = new .() ~ delete _;
		private VkDebugReportCallbackEXT _debugCallbackHandle;
		private PFN_vkDebugReportCallbackEXT _debugCallbackFunc;
		private bool _debugMarkerEnabled;
		private vkDebugMarkerSetObjectNameEXTFunction _setObjectNameDelegate;
		private vkCmdDebugMarkerBeginEXTFunction _markerBegin;
		private vkCmdDebugMarkerEndEXTFunction _markerEnd;
		private vkCmdDebugMarkerInsertEXTFunction _markerInsert;
		private Monitor _filtersLock = new .() ~ delete _;
		private readonly Dictionary<VkFormat, VkFilter> _filters = new Dictionary<VkFormat, VkFilter>() ~ delete _;
		private readonly BackendInfoVulkan _vulkanInfo ~ delete _;

		private const int32 SharedCommandPoolCount = 4;
		private Stack<SharedCommandPool> _sharedGraphicsCommandPools = new Stack<SharedCommandPool>() ~ delete _;
		private VKDescriptorPoolManager _descriptorPoolManager;
		private bool _standardValidationSupported;
		private bool _khronosValidationSupported;
		private bool _standardClipYDirection;
		private vkGetBufferMemoryRequirements2Function _getBufferMemoryRequirements2;
		private vkGetImageMemoryRequirements2Function _getImageMemoryRequirements2;
		private vkGetPhysicalDeviceProperties2Function _getPhysicalDeviceProperties2;
		private vkCreateMetalSurfaceEXTFunction _createMetalSurfaceEXT;

		// Staging Resources
		private const uint32 MinStagingBufferSize = 64;
		private const uint32 MaxStagingBufferSize = 512;

		private readonly Monitor _stagingResourcesLock = new .() ~ delete _;
		private readonly List<VKTexture> _availableStagingTextures = new List<VKTexture>();
		private readonly List<VKBuffer> _availableStagingBuffers = new List<VKBuffer>();

		private readonly Dictionary<VkCommandBuffer, VKTexture> _submittedStagingTextures = new Dictionary<VkCommandBuffer, VKTexture>() ~ delete _;
		private readonly Dictionary<VkCommandBuffer, VKBuffer> _submittedStagingBuffers = new Dictionary<VkCommandBuffer, VKBuffer>() ~ delete _;
		private readonly Dictionary<VkCommandBuffer, SharedCommandPool> _submittedSharedCommandPools = new Dictionary<VkCommandBuffer, SharedCommandPool>() ~ delete _;

		public override String DeviceName => _deviceName;

		public override String VendorName => _vendorName;

		public override GraphicsApiVersion ApiVersion => _apiVersion;

		public override GraphicsBackend BackendType => GraphicsBackend.Vulkan;

		public override bool IsUvOriginTopLeft => true;

		public override bool IsDepthRangeZeroToOne => true;

		public override bool IsClipSpaceYInverted => !_standardClipYDirection;

		public override Swapchain MainSwapchain => _mainSwapchain;

		public override GraphicsDeviceFeatures Features { get; protected set; } ~ delete _;

		public bool GetVulkanInfo(out BackendInfoVulkan info)
		{
			info = _vulkanInfo;
			return true;
		}

		public VkInstance Instance => _instance;
		public VkDevice Device => _device;
		public VkPhysicalDevice PhysicalDevice => _physicalDevice;
		public VkPhysicalDeviceMemoryProperties PhysicalDeviceMemProperties => _physicalDeviceMemProperties;
		public VkQueue GraphicsQueue => _graphicsQueue;
		public uint32 GraphicsQueueIndex => _graphicsQueueIndex;
		public uint32 PresentQueueIndex => _presentQueueIndex;
		public String DriverName => _driverName;
		public String DriverInfo => _driverInfo;
		public VKDeviceMemoryManager MemoryManager => _memoryManager;
		public VKDescriptorPoolManager DescriptorPoolManager => _descriptorPoolManager;
		public vkCmdDebugMarkerBeginEXTFunction MarkerBegin => _markerBegin;
		public vkCmdDebugMarkerEndEXTFunction MarkerEnd => _markerEnd;
		public vkCmdDebugMarkerInsertEXTFunction MarkerInsert => _markerInsert;
		public vkGetBufferMemoryRequirements2Function GetBufferMemoryRequirements2 => _getBufferMemoryRequirements2;
		public vkGetImageMemoryRequirements2Function GetImageMemoryRequirements2 => _getImageMemoryRequirements2;
		public vkCreateMetalSurfaceEXTFunction CreateMetalSurfaceEXT => _createMetalSurfaceEXT;

		private readonly Monitor _submittedFencesLock = new .() ~ delete _;
		private readonly Monitor _availableSubmissionFencesLock = new .() ~ delete _;

		private readonly Queue<Bulkan.VkFence> _availableSubmissionFences = new Queue<Bulkan.VkFence>() ~ delete _;
		private readonly List<FenceSubmissionInfo> _submittedFences = new List<FenceSubmissionInfo>() ~ delete _;
		private readonly VKSwapchain _mainSwapchain;

		private readonly List<String> _surfaceExtensions = new List<String>() ~ delete _;

		public this(GraphicsDeviceOptions options, SwapchainDescription? scDesc)
			: this(options, scDesc, VulkanDeviceOptions(Span<String>(), Span<String>())) { }

		public this(GraphicsDeviceOptions options, SwapchainDescription? scDesc, VulkanDeviceOptions vkOptions)
		{
			VulkanNative.Initialize();

			VulkanNative.LoadPreInstanceFunctions();

			CreateInstance(options.Debug, vkOptions);

			VulkanNative.LoadInstanceFunctions(_instance);

			VulkanNative.LoadPostInstanceFunctions();

			VkSurfaceKHR surface = VkSurfaceKHR.Null;
			if (scDesc != null)
			{
				surface = VKSurfaceUtil.CreateSurface(this, _instance, scDesc.Value.Source);
			}

			CreatePhysicalDevice();
			CreateLogicalDevice(surface, options.PreferStandardClipSpaceYDirection, vkOptions);

			_memoryManager = new VKDeviceMemoryManager(
				_device,
				_physicalDevice,
				_physicalDeviceProperties.limits.bufferImageGranularity,
				_getBufferMemoryRequirements2,
				_getImageMemoryRequirements2);

			Features = new GraphicsDeviceFeatures( /*computeShader:*/true, /*geometryShader:*/ _physicalDeviceFeatures.geometryShader, /*tessellationShaders:*/ _physicalDeviceFeatures.tessellationShader, /*multipleViewports:*/ _physicalDeviceFeatures.multiViewport, /*samplerLodBias:*/ true, /*drawBaseVertex:*/ true, /*drawBaseInstance:*/ true, /*drawIndirect:*/ true, /*drawIndirectBaseInstance:*/ _physicalDeviceFeatures.drawIndirectFirstInstance, /*fillModeWireframe:*/ _physicalDeviceFeatures.fillModeNonSolid, /*samplerAnisotropy:*/ _physicalDeviceFeatures.samplerAnisotropy, /*depthClipDisable:*/ _physicalDeviceFeatures.depthClamp, /*texture1D:*/ true, /*independentBlend:*/ _physicalDeviceFeatures.independentBlend, /*structuredBuffer:*/ true, /*subsetTextureView:*/ true, /*commandListDebugMarkers:*/ _debugMarkerEnabled, /*bufferRangeBinding:*/ true, /*shaderFloat64:*/ _physicalDeviceFeatures.shaderFloat64);

			ResourceFactory = new VKResourceFactory(this);

			if (scDesc != null)
			{
				SwapchainDescription desc = scDesc.Value;
				_mainSwapchain = new VKSwapchain(this, ref desc, surface);
			}

			CreateDescriptorPool();
			CreateGraphicsCommandPool();
			for (int32 i = 0; i < SharedCommandPoolCount; i++)
			{
				_sharedGraphicsCommandPools.Push(new SharedCommandPool(this, true));
			}

			_vulkanInfo = new BackendInfoVulkan(this);

			PostDeviceCreated();
		}

		public override ResourceFactory ResourceFactory { get; protected set; } ~ delete _;

		internal protected override void SubmitCommandsCore(CommandList cl, Fence fence)
		{
			SubmitCommandList(cl, 0, null, 0, null, fence);
		}

		private void SubmitCommandList(
			CommandList cl,
			uint32 waitSemaphoreCount,
			VkSemaphore* waitSemaphoresPtr,
			uint32 signalSemaphoreCount,
			VkSemaphore* signalSemaphoresPtr,
			Fence fence)
		{
			VKCommandList vkCL = Util.AssertSubtype<CommandList, VKCommandList>(cl);
			VkCommandBuffer vkCB = vkCL.CommandBuffer;

			vkCL.CommandBufferSubmitted(vkCB);
			SubmitCommandBuffer(vkCL, vkCB, waitSemaphoreCount, waitSemaphoresPtr, signalSemaphoreCount, signalSemaphoresPtr, fence);
		}

		private void SubmitCommandBuffer(
			VKCommandList vkCL,
			VkCommandBuffer vkCB,
			uint32 waitSemaphoreCount,
			VkSemaphore* waitSemaphoresPtr,
			uint32 signalSemaphoreCount,
			VkSemaphore* signalSemaphoresPtr,
			Fence fence)
		{
			CheckSubmittedFences();

			bool useExtraFence = fence != null;
			VkSubmitInfo si = VkSubmitInfo();
			si.commandBufferCount = 1;
			si.pCommandBuffers = &vkCB;
			VkPipelineStageFlags waitDstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
			si.pWaitDstStageMask = &waitDstStageMask;

			si.pWaitSemaphores = waitSemaphoresPtr;
			si.waitSemaphoreCount = waitSemaphoreCount;
			si.pSignalSemaphores = signalSemaphoresPtr;
			si.signalSemaphoreCount = signalSemaphoreCount;

			Bulkan.VkFence vkFence = Bulkan.VkFence.Null;
			Bulkan.VkFence submissionFence = Bulkan.VkFence.Null;
			if (useExtraFence)
			{
				vkFence = Util.AssertSubtype<Fence, VKFence>(fence).DeviceFence;
				submissionFence = GetFreeSubmissionFence();
			}
			else
			{
				vkFence = GetFreeSubmissionFence();
				submissionFence = vkFence;
			}

			using (_graphicsQueueLock.Enter())
			{
				VkResult result = vkQueueSubmit(_graphicsQueue, 1, &si, vkFence);
				CheckResult(result);
				if (useExtraFence)
				{
					result = vkQueueSubmit(_graphicsQueue, 0, null, submissionFence);
					CheckResult(result);
				}
			}

			using (_submittedFencesLock.Enter())
			{
				_submittedFences.Add(FenceSubmissionInfo(submissionFence, vkCL, vkCB));
			}
		}

		private void CheckSubmittedFences()
		{
			using (_submittedFencesLock.Enter())
			{
				for (int32 i = 0; i < _submittedFences.Count; i++)
				{
					FenceSubmissionInfo fsi = _submittedFences[i];
					if (vkGetFenceStatus(_device, fsi.Fence) == VkResult.VK_SUCCESS)
					{
						CompleteFenceSubmission(fsi);
						_submittedFences.RemoveAt(i);
						i -= 1;
					}
					else
					{
						break; // Submissions are in order; later submissions cannot complete if this one hasn't.
					}
				}
			}
		}

		private void CompleteFenceSubmission(FenceSubmissionInfo fsi)
		{
			Bulkan.VkFence fence = fsi.Fence;
			VkCommandBuffer completedCB = fsi.CommandBuffer;
			fsi.CommandList?.CommandBufferCompleted(completedCB);
			VkResult resetResult = vkResetFences(_device, 1, &fence);
			CheckResult(resetResult);
			ReturnSubmissionFence(fence);
			using (_stagingResourcesLock.Enter())
			{
				if (_submittedStagingTextures.TryGetValue(completedCB, var stagingTex))
				{
					_submittedStagingTextures.Remove(completedCB);
					_availableStagingTextures.Add(stagingTex);
				}
				if (_submittedStagingBuffers.TryGetValue(completedCB, var stagingBuffer))
				{
					_submittedStagingBuffers.Remove(completedCB);
					if (stagingBuffer.SizeInBytes <= MaxStagingBufferSize)
					{
						_availableStagingBuffers.Add(stagingBuffer);
					}
					else
					{
						stagingBuffer.Dispose();

						delete stagingBuffer; // sedulous cleanup
					}
				}
				if (_submittedSharedCommandPools.TryGetValue(completedCB, var sharedPool))
				{
					_submittedSharedCommandPools.Remove(completedCB);
					using (_graphicsCommandPoolLock.Enter())
					{
						if (sharedPool.IsCached)
						{
							_sharedGraphicsCommandPools.Push(sharedPool);
						}
						else
						{
							sharedPool.Destroy();

							delete sharedPool; // sedulous cleanup
							sharedPool = null;
						}
					}
				}
			}
		}

		private void ReturnSubmissionFence(Bulkan.VkFence fence)
		{
			using (_availableSubmissionFencesLock.Enter())
			{
				_availableSubmissionFences.Add(fence);
			}
		}

		private Bulkan.VkFence GetFreeSubmissionFence()
		{
			using (_availableSubmissionFencesLock.Enter())
			{
				if (_availableSubmissionFences.TryPopFront() case .Ok(Bulkan.VkFence availableFence))
				{
					return availableFence;
				}
				else
				{
					Bulkan.VkFence newFence = .Null;
					VkFenceCreateInfo fenceCI = VkFenceCreateInfo();
					VkResult result = vkCreateFence(_device, &fenceCI, null, &newFence);
					CheckResult(result);
					return newFence;
				}
			}
		}

		internal protected override void SwapBuffersCore(Swapchain swapchain)
		{
			VKSwapchain vkSC = Util.AssertSubtype<Swapchain, VKSwapchain>(swapchain);
			VkSwapchainKHR deviceSwapchain = vkSC.DeviceSwapchain;
			VkPresentInfoKHR presentInfo = VkPresentInfoKHR();
			presentInfo.swapchainCount = 1;
			presentInfo.pSwapchains = &deviceSwapchain;
			uint32 imageIndex = vkSC.ImageIndex;
			presentInfo.pImageIndices = &imageIndex;

			Monitor presentLock = vkSC.PresentQueueIndex == _graphicsQueueIndex ? _graphicsQueueLock : vkSC.PresentLock;
			using (presentLock.Enter())
			{
				vkQueuePresentKHR(vkSC.PresentQueue, &presentInfo);
				if (vkSC.AcquireNextImage(_device, VkSemaphore.Null, vkSC.ImageAvailableFence))
				{
					Bulkan.VkFence fence = vkSC.ImageAvailableFence;
					vkWaitForFences(_device, 1, &fence, true, uint64.MaxValue);
					vkResetFences(_device, 1, &fence);
				}
			}
		}

		internal void SetResourceName(DeviceResource resource, String name)
		{
			if (_debugMarkerEnabled)
			{
				if (VKBuffer buffer = resource as VKBuffer)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_EXT, buffer.DeviceBuffer.Handle, name);
				}
				if (VKCommandList commandList = resource as VKCommandList)
				{
					SetDebugMarkerName(
						VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT,
						(uint64)commandList.CommandBuffer.Handle,
						scope String()..AppendF("{0}_CommandBuffer", name));
					SetDebugMarkerName(
						VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_POOL_EXT,
						commandList.CommandPool.Handle,
						scope String()..AppendF("{0}_CommandPool", name));
				}
				if (VKFramebuffer framebuffer = resource as VKFramebuffer)
				{
					SetDebugMarkerName(
						VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_FRAMEBUFFER_EXT,
						framebuffer.CurrentFramebuffer.Handle,
						name);
				}
				if (VKPipeline pipeline = resource as VKPipeline)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_EXT, pipeline.DevicePipeline.Handle, name);
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_LAYOUT_EXT, pipeline.PipelineLayout.Handle, name);
				}
				if (VKResourceLayout resourceLayout = resource as VKResourceLayout)
				{
					SetDebugMarkerName(
						VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT_EXT,
						resourceLayout.DescriptorSetLayout.Handle,
						name);
				}
				if (VKResourceSet resourceSet = resource as VKResourceSet)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_EXT, resourceSet.DescriptorSet.Handle, name);
				}
				if (VKSampler sampler = resource as VKSampler)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_EXT, sampler.DeviceSampler.Handle, name);
				}
				if (VKShader shader = resource as VKShader)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT, shader.ShaderModule.Handle, name);
				}
				if (VKTexture tex = resource as VKTexture)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_EXT, tex.OptimalDeviceImage.Handle, name);
				}
				if (VKTextureView texView = resource as VKTextureView)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_VIEW_EXT, texView.ImageView.Handle, name);
				}
				if (VKFence fence = resource as VKFence)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_FENCE_EXT, fence.DeviceFence.Handle, name);
				}
				if (VKSwapchain sc = resource as VKSwapchain)
				{
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SWAPCHAIN_KHR_EXT, sc.DeviceSwapchain.Handle, name);
				}
			}
		}

		private void SetDebugMarkerName(VkDebugReportObjectTypeEXT type, uint64 target, String name)
		{
			Debug.Assert(_setObjectNameDelegate != null);

			VkDebugMarkerObjectNameInfoEXT nameInfo = VkDebugMarkerObjectNameInfoEXT();
			nameInfo.objectType = type;
			nameInfo.object = target;
			nameInfo.pObjectName = name.Ptr;
			VkResult result = _setObjectNameDelegate(_device, &nameInfo);
			CheckResult(result);
		}

		private void CreateInstance(bool debug, VulkanDeviceOptions options)
		{
			List<String> availableInstanceLayers = EnumerateInstanceLayers(.. ?);
			defer
			{
				DeleteContainerAndItems!(availableInstanceLayers);
			}

			List<String> availableInstanceExtensions = EnumerateInstanceExtensions(.. ?);
			defer
			{
				DeleteContainerAndItems!(availableInstanceExtensions);
			}

			VkInstanceCreateInfo instanceCI = VkInstanceCreateInfo();
			VkApplicationInfo applicationInfo = VkApplicationInfo();
			applicationInfo.apiVersion = VKVersion(1, 0, 0);
			applicationInfo.applicationVersion = VKVersion(1, 0, 0);
			applicationInfo.engineVersion = VKVersion(1, 0, 0);
			applicationInfo.pApplicationName = s_name;
			applicationInfo.pEngineName = s_name;

			instanceCI.pApplicationInfo = &applicationInfo;

			List<char8*> instanceExtensions = scope List<char8*>();
			List<char8*> instanceLayers = scope List<char8*>();

			if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_portability_subset))
			{
				_surfaceExtensions.Add(CommonStrings.VK_KHR_portability_subset);
			}

			if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_SURFACE_EXTENSION_NAME))
			{
				_surfaceExtensions.Add(CommonStrings.VK_KHR_SURFACE_EXTENSION_NAME);
			}

			if (Environment.OSVersion.Platform == PlatformID.Win32Windows || Environment.OSVersion.Platform == .Win32NT)
			{
				if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_WIN32_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
				}
			}
			/*else if (OperatingSystem.IsAndroid() ||RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
			{
				if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME);
				}
				if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_XLIB_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_KHR_XLIB_SURFACE_EXTENSION_NAME);
				}
				if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME);
				}
			}
			else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
			{
				if (availableInstanceExtensions.Contains(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME);
				}
				else // Legacy MoltenVK extensions
				{
					if (availableInstanceExtensions.Contains(CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME))
					{
						_surfaceExtensions.Add(CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME);
					}
					if (availableInstanceExtensions.Contains(CommonStrings.VK_MVK_IOS_SURFACE_EXTENSION_NAME))
					{
						_surfaceExtensions.Add(CommonStrings.VK_MVK_IOS_SURFACE_EXTENSION_NAME);
					}
				}
			}*/

			for (var ext in _surfaceExtensions)
			{
				instanceExtensions.Add(ext);
			}

			bool hasDeviceProperties2 = availableInstanceExtensions.Contains(CommonStrings.VK_KHR_get_physical_device_properties2);
			if (hasDeviceProperties2)
			{
				instanceExtensions.Add(CommonStrings.VK_KHR_get_physical_device_properties2);
			}

			Span<String> requestedInstanceExtensions = options.InstanceExtensions;
			for (String requiredExt in requestedInstanceExtensions)
			{
				if (!availableInstanceExtensions.Contains(requiredExt))
				{
					Runtime.FatalError(scope $"The required instance extension was not available: {requiredExt}");
				}

				instanceExtensions.Add(requiredExt);
			}

			bool debugReportExtensionAvailable = false;
			if (debug)
			{
				if (availableInstanceExtensions.Contains(CommonStrings.VK_EXT_DEBUG_REPORT_EXTENSION_NAME))
				{
					debugReportExtensionAvailable = true;
					instanceExtensions.Add(CommonStrings.VK_EXT_DEBUG_REPORT_EXTENSION_NAME);
				}
				if (availableInstanceLayers.Contains(CommonStrings.StandardValidationLayerName))
				{
					_standardValidationSupported = true;
					instanceLayers.Add(CommonStrings.StandardValidationLayerName);
				}
				if (availableInstanceLayers.Contains(CommonStrings.KhronosValidationLayerName))
				{
					_khronosValidationSupported = true;
					instanceLayers.Add(CommonStrings.KhronosValidationLayerName);
				}
			}

			instanceCI.enabledExtensionCount = (.)instanceExtensions.Count;
			instanceCI.ppEnabledExtensionNames = instanceExtensions.Ptr;

			instanceCI.enabledLayerCount = (.)instanceLayers.Count;
			if (instanceLayers.Count > 0)
			{
				instanceCI.ppEnabledLayerNames = instanceLayers.Ptr;
			}

			VkResult result = vkCreateInstance(&instanceCI, null, &_instance);
			CheckResult(result);

			VulkanNative.LoadInstanceFunctions(_instance);

			if (HasSurfaceExtension(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME))
			{
				_createMetalSurfaceEXT = VulkanNative.LoadFunction<vkCreateMetalSurfaceEXTFunction>("vkCreateMetalSurfaceEXT", .. ?);
			}

			if (debug && debugReportExtensionAvailable)
			{
				EnableDebugCallback();
			}

			if (hasDeviceProperties2)
			{
				_getPhysicalDeviceProperties2 = VulkanNative.LoadFunction<vkGetPhysicalDeviceProperties2Function>("vkGetPhysicalDeviceProperties2", .. ?);
			}
		}

		public bool HasSurfaceExtension(String @extension)
		{
			return _surfaceExtensions.Contains(@extension);
		}

		public void EnableDebugCallback(VkDebugReportFlagsEXT flags = VkDebugReportFlagsEXT.VK_DEBUG_REPORT_WARNING_BIT_EXT | VkDebugReportFlagsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT)
		{
			Debug.WriteLine("Enabling Vulkan Debug callbacks.");
			_debugCallbackFunc = => DebugCallback;
			VkDebugReportCallbackCreateInfoEXT debugCallbackCI = VkDebugReportCallbackCreateInfoEXT();
			debugCallbackCI.flags = flags;
			debugCallbackCI.pfnCallback = _debugCallbackFunc;
			debugCallbackCI.pUserData = Internal.UnsafeCastToPtr(this);

			vkCreateDebugReportCallbackEXTFunction createFnPtr = VulkanNative.LoadFunction<vkCreateDebugReportCallbackEXTFunction>("vkCreateDebugReportCallbackEXT", .. ?);
			if (createFnPtr == null)
				return;

			VkResult result = createFnPtr(_instance, &debugCallbackCI, null, &_debugCallbackHandle);
			CheckResult(result);
		}

		private static VkBool32 DebugCallback(
			uint32 flags,
			VkDebugReportObjectTypeEXT objectType,
			uint64 @object,
			uint location,
			int32 messageCode,
			char8* pLayerPrefix,
			char8* pMessage,
			void* pUserData)
		{
			String message = scope String(pMessage);
			VkDebugReportFlagsEXT debugReportFlags = (VkDebugReportFlagsEXT)flags;

#if DEBUG
			/*if (Debugger.IsAttached)
			{
				Debugger.Break();
			}*/
#endif

			String fullMessage = scope $"[{debugReportFlags}] ({objectType}) {message}";

			if (debugReportFlags == VkDebugReportFlagsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT)
			{
				Console.WriteLine(scope $"A Vulkan validation error was encountered: {fullMessage}");
				Debug.WriteLine(scope $"A Vulkan validation error was encountered: {fullMessage}");
				Runtime.FatalError(scope $"A Vulkan validation error was encountered: {fullMessage}");
			}

			Console.WriteLine(fullMessage);
			return 0;
		}

		private void CreatePhysicalDevice()
		{
			uint32 deviceCount = 0;
			vkEnumeratePhysicalDevices(_instance, &deviceCount, null);
			if (deviceCount == 0)
			{
				Runtime.FatalError("No physical devices exist.");
			}

			VkPhysicalDevice[] physicalDevices = scope VkPhysicalDevice[deviceCount];
			vkEnumeratePhysicalDevices(_instance, &deviceCount, physicalDevices.Ptr);
			// Just use the first one.
			_physicalDevice = physicalDevices[0];

			vkGetPhysicalDeviceProperties(_physicalDevice, &_physicalDeviceProperties);
			_apiVersion = GraphicsApiVersion.Unknown;
			_deviceName.Set(scope String(&_physicalDeviceProperties.deviceName));

			_vendorName.Set(scope String()..AppendF("id:{0:x8}", _physicalDeviceProperties.vendorID.ToString(.. scope .())));
			_driverInfo.Set(scope String()..AppendF("version:{0:x8}", _physicalDeviceProperties.driverVersion.ToString(.. scope .())));

			vkGetPhysicalDeviceFeatures(_physicalDevice, &_physicalDeviceFeatures);

			vkGetPhysicalDeviceMemoryProperties(_physicalDevice, &_physicalDeviceMemProperties);
		}

		private void CreateLogicalDevice(VkSurfaceKHR surface, bool preferStandardClipY, VulkanDeviceOptions options)
		{
			GetQueueFamilyIndices(surface);

			HashSet<uint32> familyIndices = scope HashSet<uint32>()
				..Add(_graphicsQueueIndex)
				..Add(_presentQueueIndex);
			VkDeviceQueueCreateInfo* queueCreateInfos = scope VkDeviceQueueCreateInfo[familyIndices.Count]*;
			uint32 queueCreateInfosCount = (uint32)familyIndices.Count;

			int32 i = 0;
			for (uint32 index in familyIndices)
			{
				VkDeviceQueueCreateInfo queueCreateInfo = VkDeviceQueueCreateInfo();
				queueCreateInfo.queueFamilyIndex = _graphicsQueueIndex;
				queueCreateInfo.queueCount = 1;
				float priority = 1f;
				queueCreateInfo.pQueuePriorities = &priority;
				queueCreateInfos[i] = queueCreateInfo;
				i += 1;
			}

			VkPhysicalDeviceFeatures deviceFeatures = _physicalDeviceFeatures;

			List<String> deviceExtensions = VulkanNative.EnumerateDeviceExtensions(_physicalDevice,  .. ?);
			defer
			{
				DeleteContainerAndItems!(deviceExtensions);
			}

			List<String> requiredInstanceExtensions = scope List<String>()
				..AddRange(options.DeviceExtensions);

			bool hasMemReqs2 = false;
			bool hasDedicatedAllocation = false;
			bool hasDriverProperties = false;
			char8*[] activeExtensions = scope char8*[deviceExtensions.Count];
			uint32 activeExtensionCount = 0;

			//fixed (VkExtensionProperties* extensionNames = deviceExtensions)

			for (int32 property = 0; property < deviceExtensions.Count; property++)
			{
				String extensionName = deviceExtensions[property];
				if (extensionName == "VK_EXT_debug_marker")
				{
					activeExtensions[activeExtensionCount++] = CommonStrings.VK_EXT_DEBUG_MARKER_EXTENSION_NAME;
					requiredInstanceExtensions.Remove(extensionName);
					_debugMarkerEnabled = true;
				}
				else if (extensionName == "VK_KHR_swapchain")
				{
					activeExtensions[activeExtensionCount++] = deviceExtensions[property];
					requiredInstanceExtensions.Remove(extensionName);
				}
				else if (preferStandardClipY && extensionName == "VK_KHR_maintenance1")
				{
					activeExtensions[activeExtensionCount++] = deviceExtensions[property];
					requiredInstanceExtensions.Remove(extensionName);
					_standardClipYDirection = true;
				}
				else if (extensionName == "VK_KHR_get_memory_requirements2")
				{
					activeExtensions[activeExtensionCount++] = deviceExtensions[property];
					requiredInstanceExtensions.Remove(extensionName);
					hasMemReqs2 = true;
				}
				else if (extensionName == "VK_KHR_dedicated_allocation")
				{
					activeExtensions[activeExtensionCount++] = deviceExtensions[property];
					requiredInstanceExtensions.Remove(extensionName);
					hasDedicatedAllocation = true;
				}
				else if (extensionName == "VK_KHR_driver_properties")
				{
					activeExtensions[activeExtensionCount++] = deviceExtensions[property];
					requiredInstanceExtensions.Remove(extensionName);
					hasDriverProperties = true;
				}
				else if (extensionName == CommonStrings.VK_KHR_portability_subset)
				{
					activeExtensions[activeExtensionCount++] = deviceExtensions[property];
					requiredInstanceExtensions.Remove(extensionName);
				}
				else if (requiredInstanceExtensions.Remove(extensionName))
				{
					activeExtensions[activeExtensionCount++] = deviceExtensions[property];
				}
			}

			if (requiredInstanceExtensions.Count != 0)
			{
				String missingList = scope String()..Join(", ", requiredInstanceExtensions.GetEnumerator());
				Runtime.FatalError(scope $"The following Vulkan device extensions were not available: {missingList}");
			}

			VkDeviceCreateInfo deviceCreateInfo = VkDeviceCreateInfo();
			deviceCreateInfo.queueCreateInfoCount = queueCreateInfosCount;
			deviceCreateInfo.pQueueCreateInfos = queueCreateInfos;

			deviceCreateInfo.pEnabledFeatures = &deviceFeatures;

			List<char8*> layerNames = scope List<char8*>();
			if (_standardValidationSupported)
			{
				layerNames.Add(CommonStrings.StandardValidationLayerName);
			}
			if (_khronosValidationSupported)
			{
				layerNames.Add(CommonStrings.KhronosValidationLayerName);
			}
			deviceCreateInfo.enabledLayerCount = (.)layerNames.Count;
			deviceCreateInfo.ppEnabledLayerNames = layerNames.Ptr;

			deviceCreateInfo.enabledExtensionCount = activeExtensionCount;
			deviceCreateInfo.ppEnabledExtensionNames = activeExtensions.Ptr;

			VkResult result = vkCreateDevice(_physicalDevice, &deviceCreateInfo, null, &_device);
			CheckResult(result);

			vkGetDeviceQueue(_device, _graphicsQueueIndex, 0, &_graphicsQueue);

			if (_debugMarkerEnabled)
			{
				_setObjectNameDelegate = VulkanNative.LoadFunction<vkDebugMarkerSetObjectNameEXTFunction>("vkDebugMarkerSetObjectNameEXT", .. ?);
				_markerBegin = VulkanNative.LoadFunction<vkCmdDebugMarkerBeginEXTFunction>("vkCmdDebugMarkerBeginEXT", .. ?);
				_markerEnd = VulkanNative.LoadFunction<vkCmdDebugMarkerEndEXTFunction>("vkCmdDebugMarkerEndEXT", .. ?);
				_markerInsert = VulkanNative.LoadFunction<vkCmdDebugMarkerInsertEXTFunction>("vkCmdDebugMarkerInsertEXT", .. ?);
			}
			if (hasDedicatedAllocation && hasMemReqs2)
			{
				_getBufferMemoryRequirements2 = VulkanNative.LoadFunction<vkGetBufferMemoryRequirements2Function>("vkGetBufferMemoryRequirements2", .. ?);
				_getImageMemoryRequirements2 = VulkanNative.LoadFunction<vkGetImageMemoryRequirements2Function>("vkGetImageMemoryRequirements2", .. ?);
			}
			if (_getPhysicalDeviceProperties2 != null && hasDriverProperties)
			{
				VkPhysicalDeviceProperties2 deviceProps = VkPhysicalDeviceProperties2();
				VkPhysicalDeviceDriverProperties driverProps = VkPhysicalDeviceDriverProperties();

				deviceProps.pNext = &driverProps;
				_getPhysicalDeviceProperties2(_physicalDevice, &deviceProps);

				VkConformanceVersion conforming = driverProps.conformanceVersion;
				_apiVersion = GraphicsApiVersion(conforming.major, conforming.minor, conforming.subminor, conforming.patch);
				_driverName.Set(scope String(&driverProps.driverName));
				_driverInfo.Set(scope String(&driverProps.driverInfo));
			}
		}

		private void GetQueueFamilyIndices(VkSurfaceKHR surface)
		{
			uint32 queueFamilyCount = 0;
			vkGetPhysicalDeviceQueueFamilyProperties(_physicalDevice, &queueFamilyCount, null);
			VkQueueFamilyProperties[] qfp = scope VkQueueFamilyProperties[queueFamilyCount];
			vkGetPhysicalDeviceQueueFamilyProperties(_physicalDevice, &queueFamilyCount, qfp.Ptr);

			bool foundGraphics = false;
			bool foundPresent = surface == VkSurfaceKHR.Null;

			for (uint32 i = 0; i < qfp.Count; i++)
			{
				if ((qfp[i].queueFlags & VkQueueFlags.VK_QUEUE_GRAPHICS_BIT) != 0)
				{
					_graphicsQueueIndex = i;
					foundGraphics = true;
				}

				if (!foundPresent)
				{
					VkBool32 presentSupported = default;
					vkGetPhysicalDeviceSurfaceSupportKHR(_physicalDevice, i, surface, &presentSupported);
					if (presentSupported)
					{
						_presentQueueIndex = i;
						foundPresent = true;
					}
				}

				if (foundGraphics && foundPresent)
				{
					return;
				}
			}
		}

		private void CreateDescriptorPool()
		{
			_descriptorPoolManager = new VKDescriptorPoolManager(this);
		}

		private void CreateGraphicsCommandPool()
		{
			VkCommandPoolCreateInfo commandPoolCI = VkCommandPoolCreateInfo();
			commandPoolCI.flags = VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
			commandPoolCI.queueFamilyIndex = _graphicsQueueIndex;
			VkResult result = vkCreateCommandPool(_device, &commandPoolCI, null, &_graphicsCommandPool);
			CheckResult(result);
		}

		protected override MappedResource MapCore(MappableResource resource, MapMode mode, uint32 subresource)
		{
			VKMemoryBlock memoryBlock = default(VKMemoryBlock);
			void* mappedPtr = null;
			uint32 sizeInBytes;
			uint32 offset = 0;
			uint32 rowPitch = 0;
			uint32 depthPitch = 0;
			if (var buffer = resource as VKBuffer)
			{
				memoryBlock = buffer.Memory;
				sizeInBytes = buffer.SizeInBytes;
			}
			else
			{
				VKTexture texture = Util.AssertSubtype<MappableResource, VKTexture>(resource);
				VkSubresourceLayout layout = texture.GetSubresourceLayout(subresource);
				memoryBlock = texture.Memory;
				sizeInBytes = (uint32)layout.size;
				offset = (uint32)layout.offset;
				rowPitch = (uint32)layout.rowPitch;
				depthPitch = (uint32)layout.depthPitch;
			}

			if (memoryBlock.DeviceMemory.Handle != 0)
			{
				if (memoryBlock.IsPersistentMapped)
				{
					mappedPtr = (void*)memoryBlock.BlockMappedPointer;
				}
				else
				{
					mappedPtr = _memoryManager.Map(memoryBlock);
				}
			}

			uint8* dataPtr = (uint8*)mappedPtr + offset;
			return MappedResource(
				resource,
				mode,
				(void*)dataPtr,
				sizeInBytes,
				subresource,
				rowPitch,
				depthPitch);
		}

		protected override void UnmapCore(MappableResource resource, uint32 subresource)
		{
			VKMemoryBlock memoryBlock = default(VKMemoryBlock);
			if (var buffer = resource as VKBuffer)
			{
				memoryBlock = buffer.Memory;
			}
			else
			{
				VKTexture tex = Util.AssertSubtype<MappableResource, VKTexture>(resource);
				memoryBlock = tex.Memory;
			}

			if (memoryBlock.DeviceMemory.Handle != 0 && !memoryBlock.IsPersistentMapped)
			{
				vkUnmapMemory(_device, memoryBlock.DeviceMemory);
			}
		}

		protected override void PlatformDispose()
		{
			Debug.Assert(_submittedFences.Count == 0);
			using (_availableSubmissionFencesLock.Enter())
			{
				for (Bulkan.VkFence fence in _availableSubmissionFences)
				{
					vkDestroyFence(_device, fence, null);
				}
			}

			_mainSwapchain?.Dispose();
			if (_mainSwapchain != null)
			{
				delete _mainSwapchain; // sedulous cleanup
			}
			if (_debugCallbackFunc != null)
			{
				_debugCallbackFunc = null;
				// todo: load on _instance
				vkDestroyDebugReportCallbackEXTFunction destroyFuncPtr = VulkanNative.LoadFunction<vkDestroyDebugReportCallbackEXTFunction>("vkDestroyDebugReportCallbackEXT", .. ?);
				destroyFuncPtr(_instance, _debugCallbackHandle, null);
			}

			_descriptorPoolManager.DestroyAll();
			delete _descriptorPoolManager; // sedulous cleanup

			vkDestroyCommandPool(_device, _graphicsCommandPool, null);

			Debug.Assert(_submittedStagingTextures.Count == 0);
			for (VKTexture tex in _availableStagingTextures)
			{
				tex.Dispose();
				delete tex; // sedulous cleanup
			}
			delete _availableStagingTextures;

			Debug.Assert(_submittedStagingBuffers.Count == 0);
			for (VKBuffer buffer in _availableStagingBuffers)
			{
				buffer.Dispose();
				delete buffer;// sedulous cleanup
			}
			delete _availableStagingBuffers;

			using (_graphicsCommandPoolLock.Enter())
			{
				while (_sharedGraphicsCommandPools.Count > 0)
				{
					SharedCommandPool sharedPool = _sharedGraphicsCommandPools.Pop();
					sharedPool.Destroy();
					delete sharedPool; //sedulous cleanup
					sharedPool = null;
				}
			}

			_memoryManager.Dispose();
			delete _memoryManager; // sedulous cleanup

			VkResult result = vkDeviceWaitIdle(_device);
			CheckResult(result);
			vkDestroyDevice(_device, null);
			vkDestroyInstance(_instance, null);
		}

		internal protected override void WaitForIdleCore()
		{
			using (_graphicsQueueLock.Enter())
			{
				vkQueueWaitIdle(_graphicsQueue);
			}

			CheckSubmittedFences();
		}

		public override TextureSampleCount GetSampleCountLimit(PixelFormat format, bool depthFormat)
		{
			VkImageUsageFlags usageFlags = VkImageUsageFlags.VK_IMAGE_USAGE_SAMPLED_BIT;
			usageFlags |= depthFormat ? VkImageUsageFlags.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT : VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

			VkImageFormatProperties formatProperties = .();
			vkGetPhysicalDeviceImageFormatProperties(
				_physicalDevice,
				VKFormats.VdToVkPixelFormat(format),
				VkImageType.VK_IMAGE_TYPE_2D,
				VkImageTiling.VK_IMAGE_TILING_OPTIMAL,
				usageFlags,
				VkImageCreateFlags.None,
				&formatProperties);

			VkSampleCountFlags vkSampleCounts = formatProperties.sampleCounts;
			if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_32_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_32_BIT)
			{
				return TextureSampleCount.Count32;
			}
			else if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_16_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_16_BIT)
			{
				return TextureSampleCount.Count16;
			}
			else if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_8_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_8_BIT)
			{
				return TextureSampleCount.Count8;
			}
			else if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_4_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_4_BIT)
			{
				return TextureSampleCount.Count4;
			}
			else if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_2_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_2_BIT)
			{
				return TextureSampleCount.Count2;
			}

			return TextureSampleCount.Count1;
		}

		internal protected override bool GetPixelFormatSupportCore(
			PixelFormat format,
			TextureType type,
			TextureUsage usage,
			out PixelFormatProperties properties)
		{
			VkFormat vkFormat = VKFormats.VdToVkPixelFormat(format, (usage & TextureUsage.DepthStencil) != 0);
			VkImageType vkType = VKFormats.VdToVkTextureType(type);
			VkImageTiling tiling = usage == TextureUsage.Staging ? VkImageTiling.VK_IMAGE_TILING_LINEAR : VkImageTiling.VK_IMAGE_TILING_OPTIMAL;
			VkImageUsageFlags vkUsage = VKFormats.VdToVkTextureUsage(usage);

			VkImageFormatProperties vkProps = .();
			VkResult result = vkGetPhysicalDeviceImageFormatProperties(
				_physicalDevice,
				vkFormat,
				vkType,
				tiling,
				vkUsage,
				VkImageCreateFlags.None,
				&vkProps);

			if (result == VkResult.VK_ERROR_FORMAT_NOT_SUPPORTED)
			{
				properties = default(PixelFormatProperties);
				return false;
			}
			CheckResult(result);

			properties = PixelFormatProperties(
				vkProps.maxExtent.width,
				vkProps.maxExtent.height,
				vkProps.maxExtent.depth,
				vkProps.maxMipLevels,
				vkProps.maxArrayLayers,
				(uint32)vkProps.sampleCounts);
			return true;
		}

		internal VkFilter GetFormatFilter(VkFormat format)
		{
			using (_filtersLock.Enter())
			{
				if (!_filters.TryGetValue(format, var filter))
				{
					VkFormatProperties vkFormatProps = .();
					vkGetPhysicalDeviceFormatProperties(_physicalDevice, format, &vkFormatProps);
					filter = (vkFormatProps.optimalTilingFeatures & VkFormatFeatureFlags.VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) != 0
						? VkFilter.VK_FILTER_LINEAR
						: VkFilter.VK_FILTER_NEAREST;
					_filters.TryAdd(format, filter);
				}

				return filter;
			}
		}

		internal protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, void* source, uint32 sizeInBytes)
		{
			VKBuffer vkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(buffer);
			VKBuffer copySrcVkBuffer = null;
			void* mappedPtr;
			uint8* destPtr;
			bool isPersistentMapped = vkBuffer.Memory.IsPersistentMapped;
			if (isPersistentMapped)
			{
				mappedPtr = (void*)vkBuffer.Memory.BlockMappedPointer;
				destPtr = (uint8*)mappedPtr + bufferOffsetInBytes;
			}
			else
			{
				copySrcVkBuffer = GetFreeStagingBuffer(sizeInBytes);
				mappedPtr = (void*)copySrcVkBuffer.Memory.BlockMappedPointer;
				destPtr = (uint8*)mappedPtr;
			}

			Internal.MemCpy(destPtr, source, sizeInBytes);

			if (!isPersistentMapped)
			{
				SharedCommandPool pool = GetFreeCommandPool();
				VkCommandBuffer cb = pool.BeginNewCommandBuffer();

				VkBufferCopy copyRegion = VkBufferCopy()
					{
						dstOffset = bufferOffsetInBytes,
						size = sizeInBytes
					};
				vkCmdCopyBuffer(cb, copySrcVkBuffer.DeviceBuffer, vkBuffer.DeviceBuffer, 1, &copyRegion);

				pool.EndAndSubmit(cb);
				using (_stagingResourcesLock.Enter())
				{
					_submittedStagingBuffers.Add(cb, copySrcVkBuffer);
				}
			}
		}

		private SharedCommandPool GetFreeCommandPool()
		{
			SharedCommandPool sharedPool = null;
			using (_graphicsCommandPoolLock.Enter())
			{
				if (_sharedGraphicsCommandPools.Count > 0)
					sharedPool = _sharedGraphicsCommandPools.Pop();
			}

			if (sharedPool == null)
				sharedPool = new SharedCommandPool(this, false);

			return sharedPool;
		}

		private void* MapBuffer(VKBuffer buffer, uint32 numBytes)
		{
			if (buffer.Memory.IsPersistentMapped)
			{
				return (void*)buffer.Memory.BlockMappedPointer;
			}
			else
			{
				void* mappedPtr = null;
				VkResult result = vkMapMemory(Device, buffer.Memory.DeviceMemory, buffer.Memory.Offset, numBytes, 0, &mappedPtr);
				CheckResult(result);
				return (void*)mappedPtr;
			}
		}

		private void UnmapBuffer(VKBuffer buffer)
		{
			if (!buffer.Memory.IsPersistentMapped)
			{
				vkUnmapMemory(Device, buffer.Memory.DeviceMemory);
			}
		}

		internal protected override void UpdateTextureCore(
			Texture texture,
			void* source,
			uint32 sizeInBytes,
			uint32 x,
			uint32 y,
			uint32 z,
			uint32 width,
			uint32 height,
			uint32 depth,
			uint32 mipLevel,
			uint32 arrayLayer)
		{
			VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(texture);
			bool isStaging = (vkTex.Usage & TextureUsage.Staging) != 0;
			if (isStaging)
			{
				VKMemoryBlock memBlock = vkTex.Memory;
				uint32 subresource = texture.CalculateSubresource(mipLevel, arrayLayer);
				VkSubresourceLayout layout = vkTex.GetSubresourceLayout(subresource);
				uint8* imageBasePtr = (uint8*)memBlock.BlockMappedPointer + layout.offset;

				uint32 srcRowPitch = FormatHelpers.GetRowPitch(width, texture.Format);
				uint32 srcDepthPitch = FormatHelpers.GetDepthPitch(srcRowPitch, height, texture.Format);
				Util.CopyTextureRegion(
					source,
					0, 0, 0,
					srcRowPitch, srcDepthPitch,
					imageBasePtr,
					x, y, z,
					(uint32)layout.rowPitch, (uint32)layout.depthPitch,
					width, height, depth,
					texture.Format);
			}
			else
			{
				VKTexture stagingTex = GetFreeStagingTexture(width, height, depth, texture.Format);
				UpdateTexture(stagingTex, source, sizeInBytes, 0, 0, 0, width, height, depth, 0, 0);
				SharedCommandPool pool = GetFreeCommandPool();
				VkCommandBuffer cb = pool.BeginNewCommandBuffer();
				VKCommandList.CopyTextureCore_VkCommandBuffer(
					cb,
					stagingTex, 0, 0, 0, 0, 0,
					texture, x, y, z, mipLevel, arrayLayer,
					width, height, depth, 1);
				using (_stagingResourcesLock.Enter())
				{
					_submittedStagingTextures.Add(cb, stagingTex);
				}
				pool.EndAndSubmit(cb);
			}
		}

		private VKTexture GetFreeStagingTexture(uint32 width, uint32 height, uint32 depth, PixelFormat format)
		{
			uint32 totalSize = FormatHelpers.GetRegionSize(width, height, depth, format);
			using (_stagingResourcesLock.Enter())
			{
				for (int32 i = 0; i < _availableStagingTextures.Count; i++)
				{
					VKTexture tex = _availableStagingTextures[i];
					if (tex.Memory.Size >= totalSize)
					{
						_availableStagingTextures.RemoveAt(i);
						tex.SetStagingDimensions(width, height, depth, format);
						return tex;
					}
				}
			}

			uint32 texWidth = Math.Max(256, width);
			uint32 texHeight = Math.Max(256, height);
			VKTexture newTex = (VKTexture)ResourceFactory.CreateTexture(TextureDescription.Texture3D(
				texWidth, texHeight, depth, 1, format, TextureUsage.Staging));
			newTex.SetStagingDimensions(width, height, depth, format);

			return newTex;
		}

		private VKBuffer GetFreeStagingBuffer(uint32 size)
		{
			using (_stagingResourcesLock.Enter())
			{
				for (int32 i = 0; i < _availableStagingBuffers.Count; i++)
				{
					VKBuffer buffer = _availableStagingBuffers[i];
					if (buffer.SizeInBytes >= size)
					{
						_availableStagingBuffers.RemoveAt(i);
						return buffer;
					}
				}
			}

			uint32 newBufferSize = Math.Max(MinStagingBufferSize, size);
			VKBuffer newBuffer = (VKBuffer)ResourceFactory.CreateBuffer(
				BufferDescription(newBufferSize, BufferUsage.Staging));
			return newBuffer;
		}

		public override void ResetFence(Fence fence)
		{
			Bulkan.VkFence vkFence = Util.AssertSubtype<Fence, VKFence>(fence).DeviceFence;
			vkResetFences(_device, 1, &vkFence);
		}

		public override bool WaitForFence(Fence fence, uint64 nanosecondTimeout)
		{
			Bulkan.VkFence vkFence = Util.AssertSubtype<Fence, VKFence>(fence).DeviceFence;
			VkResult result = vkWaitForFences(_device, 1, &vkFence, true, nanosecondTimeout);
			return result == VkResult.VK_SUCCESS;
		}

		public override bool WaitForFences(Fence[] fences, bool waitAll, uint64 nanosecondTimeout)
		{
			int fenceCount = fences.Count;
			Bulkan.VkFence* fencesPtr = scope Bulkan.VkFence[fenceCount]*;
			for (int32 i = 0; i < fenceCount; i++)
			{
				fencesPtr[i] = Util.AssertSubtype<Fence, VKFence>(fences[i]).DeviceFence;
			}

			VkResult result = vkWaitForFences(_device, (uint32)fenceCount, fencesPtr, waitAll, nanosecondTimeout);
			return result == VkResult.VK_SUCCESS;
		}

		/*internal static bool IsSupported()
		{
			return s_isSupported.Value;
		}

		private static bool CheckIsSupported()
		{
			if (!IsVulkanLoaded())
			{
				return false;
			}

			VkInstanceCreateInfo instanceCI = VkInstanceCreateInfo();
			VkApplicationInfo applicationInfo = VkApplicationInfo();
			applicationInfo.apiVersion = VKVersion(1, 0, 0);
			applicationInfo.applicationVersion = VKVersion(1, 0, 0);
			applicationInfo.engineVersion = VKVersion(1, 0, 0);
			applicationInfo.pApplicationName = s_name;
			applicationInfo.pEngineName = s_name;

			instanceCI.pApplicationInfo = &applicationInfo;
			VkInstance testInstance = .Null;
			VkResult result = vkCreateInstance(&instanceCI, null, &testInstance);
			if (result != VkResult.VK_SUCCESS)
			{
				return false;
			}

			uint32 physicalDeviceCount = 0;
			result = vkEnumeratePhysicalDevices(testInstance, &physicalDeviceCount, null);
			if (result != VkResult.VK_SUCCESS || physicalDeviceCount == 0)
			{
				vkDestroyInstance(testInstance, null);
				return false;
			}

			vkDestroyInstance(testInstance, null);

			HashSet<String> instanceExtensions = new HashSet<String>(GetInstanceExtensions());
			if (!instanceExtensions.Contains(CommonStrings.VK_KHR_SURFACE_EXTENSION_NAME))
			{
				return false;
			}
			if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
			{
				return instanceExtensions.Contains(CommonStrings.VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
			}
			else if (OperatingSystem.IsAndroid())
			{
				return instanceExtensions.Contains(CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME);
			}
			else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
			{
				if (RuntimeInformation.OSDescription.Contains("Unix")) // Android
				{
					return instanceExtensions.Contains(CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME);
				}
				else
				{
					return instanceExtensions.Contains(CommonStrings.VK_KHR_XLIB_SURFACE_EXTENSION_NAME);
				}
			}
			else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
			{
				if (RuntimeInformation.OSDescription.Contains("Darwin")) // macOS
				{
					return instanceExtensions.Contains(CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME);
				}
				else // iOS
				{
					return instanceExtensions.Contains(CommonStrings.VK_MVK_IOS_SURFACE_EXTENSION_NAME);
				}
			}

			return false;
		}*/

		internal void ClearColorTexture(VKTexture texture, VkClearColorValue color)
		{
			var color;

			uint32 effectiveLayers = texture.ArrayLayers;
			if ((texture.Usage & TextureUsage.Cubemap) != 0)
			{
				effectiveLayers *= 6;
			}
			VkImageSubresourceRange range = VkImageSubresourceRange()
				{
					aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
					baseMipLevel = 0,
					levelCount = texture.MipLevels,
					baseArrayLayer = 0,
					layerCount = effectiveLayers
				};
			SharedCommandPool pool = GetFreeCommandPool();
			VkCommandBuffer cb = pool.BeginNewCommandBuffer();
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, effectiveLayers, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
			vkCmdClearColorImage(cb, texture.OptimalDeviceImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, &color, 1, &range);
			VkImageLayout colorLayout = texture.IsSwapchainTexture ? VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR : VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, effectiveLayers, colorLayout);
			pool.EndAndSubmit(cb);
		}

		internal void ClearDepthTexture(VKTexture texture, VkClearDepthStencilValue clearValue)
		{
			var clearValue;

			uint32 effectiveLayers = texture.ArrayLayers;
			if ((texture.Usage & TextureUsage.Cubemap) != 0)
			{
				effectiveLayers *= 6;
			}
			VkImageAspectFlags aspect = FormatHelpers.IsStencilFormat(texture.Format)
				? VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT
				: VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
			VkImageSubresourceRange range = VkImageSubresourceRange()
				{
					aspectMask = aspect,
					baseMipLevel = 0,
					levelCount = texture.MipLevels,
					baseArrayLayer = 0,
					layerCount = effectiveLayers
				};
			SharedCommandPool pool = GetFreeCommandPool();
			VkCommandBuffer cb = pool.BeginNewCommandBuffer();
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, effectiveLayers, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
			vkCmdClearDepthStencilImage(
				cb,
				texture.OptimalDeviceImage,
				VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
				&clearValue,
				1,
				&range);
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, effectiveLayers, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL);
			pool.EndAndSubmit(cb);
		}

		internal protected override uint32 GetUniformBufferMinOffsetAlignmentCore()
			=> (uint32)_physicalDeviceProperties.limits.minUniformBufferOffsetAlignment;

		internal protected override uint32 GetStructuredBufferMinOffsetAlignmentCore()
			=> (uint32)_physicalDeviceProperties.limits.minStorageBufferOffsetAlignment;

		internal void TransitionImageLayout(VKTexture texture, VkImageLayout layout)
		{
			SharedCommandPool pool = GetFreeCommandPool();
			VkCommandBuffer cb = pool.BeginNewCommandBuffer();
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, texture.ActualArrayLayers, layout);
			pool.EndAndSubmit(cb);
		}

		private class SharedCommandPool
		{
			private readonly VKGraphicsDevice _gd;
			private readonly VkCommandPool _pool;
			private readonly VkCommandBuffer _cb;

			public bool IsCached { get; }

			public this(VKGraphicsDevice gd, bool isCached)
			{
				_gd = gd;
				IsCached = isCached;

				VkCommandPoolCreateInfo commandPoolCI = VkCommandPoolCreateInfo();
				commandPoolCI.flags = VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_TRANSIENT_BIT | VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
				commandPoolCI.queueFamilyIndex = _gd.GraphicsQueueIndex;
				VkResult result = vkCreateCommandPool(_gd.Device, &commandPoolCI, null, &_pool);
				CheckResult(result);

				VkCommandBufferAllocateInfo allocateInfo = VkCommandBufferAllocateInfo();
				allocateInfo.commandBufferCount = 1;
				allocateInfo.level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY;
				allocateInfo.commandPool = _pool;
				result = vkAllocateCommandBuffers(_gd.Device, &allocateInfo, &_cb);
				CheckResult(result);
			}

			public VkCommandBuffer BeginNewCommandBuffer()
			{
				VkCommandBufferBeginInfo beginInfo = VkCommandBufferBeginInfo();
				beginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
				VkResult result = vkBeginCommandBuffer(_cb, &beginInfo);
				CheckResult(result);

				return _cb;
			}

			public void EndAndSubmit(VkCommandBuffer cb)
			{
				VkResult result = vkEndCommandBuffer(cb);
				CheckResult(result);
				_gd.SubmitCommandBuffer(null, cb, 0, null, 0, null, null);
				using (_gd._stagingResourcesLock.Enter())
				{
					_gd._submittedSharedCommandPools.Add(cb, this);
				}
			}

			internal void Destroy()
			{
				vkDestroyCommandPool(_gd.Device, _pool, null);
			}
		}

		private struct FenceSubmissionInfo
		{
			public Bulkan.VkFence Fence;
			public VKCommandList CommandList;
			public VkCommandBuffer CommandBuffer;
			public this(Bulkan.VkFence fence, VKCommandList commandList, VkCommandBuffer commandBuffer)
			{
				Fence = fence;
				CommandList = commandList;
				CommandBuffer = commandBuffer;
			}
		}

		/// <summary>
		/// Tries to get a <see cref="BackendInfoVulkan"/> for this instance. This method will only succeed if this is a Vulkan
		/// GraphicsDevice.
		/// </summary>
		/// <param name="info">If successful, this will contain the <see cref="BackendInfoVulkan"/> for this instance.</param>
		/// <returns>True if this is a Vulkan GraphicsDevice and the operation was successful. False otherwise.</returns>
		//public virtual bool GetVulkanInfo(out BackendInfoVulkan info) { info = null; return false; }

		/// <summary>
		/// Gets a <see cref="BackendInfoVulkan"/> for this instance. This method will only succeed if this is a Vulkan
		/// GraphicsDevice. Otherwise, this method will throw an exception.
		/// </summary>
		/// <returns>The <see cref="BackendInfoVulkan"/> for this instance.</returns>
		/*public BackendInfoVulkan GetVulkanInfo()
		{
			if (!GetVulkanInfo(out BackendInfoVulkan info))
			{
				Runtime.FatalError(scope $"{nameof(GetVulkanInfo)} can only be used on a Vulkan GraphicsDevice.");
			}

			return info;
		}*/

		/// <summary>
		/// Creates a new <see cref="GraphicsDevice"/> using Vulkan.
		/// </summary>
		/// <param name="options">Describes several common properties of the GraphicsDevice.</param>
		/// <returns>A new <see cref="GraphicsDevice"/> using the Vulkan API.</returns>
		public static GraphicsDevice CreateVulkan(GraphicsDeviceOptions options)
		{
			return new VKGraphicsDevice(options, null);
		}

		/// <summary>
		/// Creates a new <see cref="GraphicsDevice"/> using Vulkan.
		/// </summary>
		/// <param name="options">Describes several common properties of the GraphicsDevice.</param>
		/// <param name="vkOptions">The Vulkan-specific options used to create the device.</param>
		/// <returns>A new <see cref="GraphicsDevice"/> using the Vulkan API.</returns>
		public static GraphicsDevice CreateVulkan(GraphicsDeviceOptions options, VulkanDeviceOptions vkOptions)
		{
			return new VKGraphicsDevice(options, null, vkOptions);
		}

		/// <summary>
		/// Creates a new <see cref="GraphicsDevice"/> using Vulkan, with a main Swapchain.
		/// </summary>
		/// <param name="options">Describes several common properties of the GraphicsDevice.</param>
		/// <param name="swapchainDescription">A description of the main Swapchain to create.</param>
		/// <returns>A new <see cref="GraphicsDevice"/> using the Vulkan API.</returns>
		public static GraphicsDevice CreateVulkan(GraphicsDeviceOptions options, SwapchainDescription swapchainDescription)
		{
			return new VKGraphicsDevice(options, swapchainDescription);
		}

		/// <summary>
		/// Creates a new <see cref="GraphicsDevice"/> using Vulkan, with a main Swapchain.
		/// </summary>
		/// <param name="options">Describes several common properties of the GraphicsDevice.</param>
		/// <param name="vkOptions">The Vulkan-specific options used to create the device.</param>
		/// <param name="swapchainDescription">A description of the main Swapchain to create.</param>
		/// <returns>A new <see cref="GraphicsDevice"/> using the Vulkan API.</returns>
		public static GraphicsDevice CreateVulkan(
			GraphicsDeviceOptions options,
			SwapchainDescription swapchainDescription,
			VulkanDeviceOptions vkOptions)
		{
			return new VKGraphicsDevice(options, swapchainDescription, vkOptions);
		}

		/// <summary>
		/// Creates a new <see cref="GraphicsDevice"/> using Vulkan, with a main Swapchain.
		/// </summary>
		/// <param name="options">Describes several common properties of the GraphicsDevice.</param>
		/// <param name="surfaceSource">The source from which a Vulkan surface can be created.</param>
		/// <param name="width">The initial width of the window.</param>
		/// <param name="height">The initial height of the window.</param>
		/// <returns>A new <see cref="GraphicsDevice"/> using the Vulkan API.</returns>
		public static GraphicsDevice CreateVulkan(GraphicsDeviceOptions options, VKSurfaceSource surfaceSource, uint32 width, uint32 height)
		{
			SwapchainDescription scDesc = SwapchainDescription(
				surfaceSource.GetSurfaceSource(),
				width, height,
				options.SwapchainDepthFormat,
				options.SyncToVerticalBlank,
				options.SwapchainSrgbFormat);

			return new VKGraphicsDevice(options, scDesc);
		}
	}

	internal  delegate VkResult vkCreateDebugReportCallbackEXT_d(
		VkInstance instance,
		VkDebugReportCallbackCreateInfoEXT* createInfo,
		void* allocatorPtr,
		out VkDebugReportCallbackEXT ret);

	internal  delegate void vkDestroyDebugReportCallbackEXT_d(
		VkInstance instance,
		VkDebugReportCallbackEXT callback,
		VkAllocationCallbacks* pAllocator);

	internal  delegate VkResult vkDebugMarkerSetObjectNameEXT_t(VkDevice device, VkDebugMarkerObjectNameInfoEXT* pNameInfo);
	internal  delegate void vkCmdDebugMarkerBeginEXT_t(VkCommandBuffer commandBuffer, VkDebugMarkerMarkerInfoEXT* pMarkerInfo);
	internal  delegate void vkCmdDebugMarkerEndEXT_t(VkCommandBuffer commandBuffer);
	internal  delegate void vkCmdDebugMarkerInsertEXT_t(VkCommandBuffer commandBuffer, VkDebugMarkerMarkerInfoEXT* pMarkerInfo);

	internal  delegate void vkGetBufferMemoryRequirements2_t(VkDevice device, VkBufferMemoryRequirementsInfo2* pInfo, VkMemoryRequirements2* pMemoryRequirements);
	internal  delegate void vkGetImageMemoryRequirements2_t(VkDevice device, VkImageMemoryRequirementsInfo2* pInfo, VkMemoryRequirements2* pMemoryRequirements);

	internal  delegate void vkGetPhysicalDeviceProperties2_t(VkPhysicalDevice physicalDevice, void* properties);

	// VK_EXT_metal_surface

	internal  delegate VkResult vkCreateMetalSurfaceEXT_t(
		VkInstance instance,
		VkMetalSurfaceCreateInfoEXT* pCreateInfo,
		VkAllocationCallbacks* pAllocator,
		VkSurfaceKHR* pSurface);

	internal  struct VkMetalSurfaceCreateInfoEXT
	{
		public const VkStructureType VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT = (VkStructureType)1000217000;

		public VkStructureType sType;
		public void* pNext;
		public uint32 flags;
		public void* pLayer;
	}

	internal struct VkPhysicalDeviceDriverProperties
	{
		public const int32 DriverNameLength = 256;
		public const int32 DriverInfoLength = 256;
		public const VkStructureType VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES = (VkStructureType)1000196000;

		public VkStructureType sType;
		public void* pNext;
		public VkDriverId driverID;
		public char8[DriverNameLength] driverName;
		public char8[DriverInfoLength] driverInfo;
		public VkConformanceVersion conformanceVersion;

		public static VkPhysicalDeviceDriverProperties New()
		{
			return VkPhysicalDeviceDriverProperties() { sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES };
		}
	}

	internal enum VkDriverId
	{
	}

	internal struct VkConformanceVersion
	{
		public uint8 major;
		public uint8 minor;
		public uint8 subminor;
		public uint8 patch;
	}
}

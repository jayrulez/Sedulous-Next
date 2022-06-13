using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Platform;
using SDL2;
using Sedulous.Renderer;
using Sedulous.Audio;
using System.Collections;
using Sedulous.GAL;
using Sedulous.GAL.Vulkan;
namespace Sedulous.Framework.SDL;

class SDLApplication : Application
{
	private readonly SDLApplicationSettings mApplicationSettings ~ delete _;
	private Sedulous.Platform.Window mWindow = null;
	//private RendererPlugin mRendererPlugin = null;
	//private AudioPlugin mAudioPlugin = null;
	//private Device mDevice = null;
	//private DeviceAllocator mDeviceAllocator = new DeviceAllocator() ~ delete _;

	private GraphicsDevice mGraphicsDevice = null;
	private SwapchainSource mSwapchainSource = null;
	private Swapchain mSwapchain = null;
	private bool _colorSrgb = true;

	protected GraphicsDevice GraphicsDevice => mGraphicsDevice;

	public this(ILogger logger, in StringView windowTitle, uint32 windowWidth, uint32 windowHeight)
		: base(mApplicationSettings = new .()
		{
			Logger = logger,
			WindowTitle = windowTitle,
			WindowWidth = windowWidth,
			WindowHeight = windowHeight
		})
	{
	}

	// Does critical initialization
	// If this method fails, OnShutdown is not called by the main loop
	protected override Result<void> OnStartup()
	{
		if (SDL.Init(.Everything) < 0)
		{
			Logger.LogCritical("SDL initialization failed: {0}", SDL.GetError());
			return .Err;
		}

		return .Ok;
	}

	protected override Result<void> OnInitialize()
	{
		mWindow = new SDLWindow(mApplicationSettings.WindowTitle, mApplicationSettings.WindowWidth, mApplicationSettings.WindowHeight);
		mWindow.Closing.Subscribe(new () =>
			{
				this.Stop();
			});

		mSwapchainSource = SwapchainSource.CreateWin32(mWindow.SurfaceInfo.Handles[0], Environment.ModuleHandle);

		/*DeviceCreationDesc deviceDesc = .()
			{
				enableAPIValidation = true,
				enableNRIValidation = true
			};

		Result result = CreateDeviceVK(deviceDesc, mDeviceAllocator, Logger, out mDevice);
		if (result != .SUCCESS)
		{
			Logger.LogError("Failed to create Device");
			return .Err;
		}*/

		//mApplicationSettings.Plugins.Add(mRendererPlugin = new RendererPlugin(mEngine, mDevice));
		//mApplicationSettings.Plugins.Add(mAudioPlugin = new AudioPlugin(mEngine));

		GraphicsDeviceOptions options = .(true, null, false, ResourceBindingModel.Improved, true, true, _colorSrgb);

		SwapchainDescription scDesc = SwapchainDescription(
			mSwapchainSource,
			(.)mWindow.Width,
			(.)mWindow.Height,
			options.SwapchainDepthFormat,
			options.SyncToVerticalBlank,
			_colorSrgb);

		mGraphicsDevice = VKGraphicsDevice.CreateVulkan(options, scDesc);

		mSwapchain = mGraphicsDevice.MainSwapchain;

		SDL.PumpEvents();
		return .Ok;
	}

	protected override void OnShutdown()
	{
		/*if (mAudioPlugin != null)
			delete mAudioPlugin;

		if (mRendererPlugin != null)
			delete mRendererPlugin;

		if (mDevice != null)
			delete mDevice;*/

		/*if (mSwapchain != null)
			delete mSwapchain;*/

		if (mGraphicsDevice != null){
			mGraphicsDevice.Dispose();
			delete mGraphicsDevice;
		}

		/*if (mGraphicsValidationLayer != null)
			delete mGraphicsValidationLayer;*/

		if(mSwapchainSource != null){
			delete mSwapchainSource;
		}

		if (mWindow != null)
			delete mWindow;

		SDL.Quit();
	}

	protected override void OnFrameBegin()
	{
		if (let sdlWindow = mWindow as SDLWindow)
		{
			while (SDL.PollEvent(let ev) != 0)
			{
				sdlWindow.[Friend]OnEvent(ev);

				if (ev.type == .Quit)
				{
					Stop();
				}
			}
		}
	}

	protected override void OnFrameEnd()
	{
		 // do rendering here
	}
}
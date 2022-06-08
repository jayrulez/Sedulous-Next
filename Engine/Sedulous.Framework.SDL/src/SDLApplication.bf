using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Platform;
using SDL2;
using Sedulous.Renderer;
using Sedulous.RHI;
using Sedulous.RHI.Vulkan;
using Sedulous.Audio;
using System.Collections;
namespace Sedulous.Framework.SDL;

public class SDLApplicationSettings : ApplicationSettings
{
	public StringView WindowTitle;
	public uint32 WindowWidth;
	public uint32 WindowHeight;
}

class SDLApplication : Application
{
	private readonly SDLApplicationSettings mApplicationSettings ~ delete _;
	private Sedulous.Platform.Window mWindow = null;
	private RendererPlugin mRendererPlugin = null;
	private AudioPlugin mAudioPlugin = null;
	private Device mDevice = null;
	private DeviceAllocator mDeviceAllocator = new DeviceAllocator() ~ delete _;

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
		mWindow.OnClosing.Subscribe(new () =>
			{
				this.Stop();
			});

		DeviceCreationDesc deviceDesc = .()
			{
				enableAPIValidation = true,
				enableNRIValidation = true
			};

		Result result = CreateDeviceVK(deviceDesc, mDeviceAllocator, Logger, out mDevice);
		if (result != .SUCCESS)
		{
			Logger.LogError("Failed to create Device");
			return .Err;
		}

		uint32 numDisplays = 0;
		mDevice.GetDisplays(null, ref numDisplays);

		List<Display*> displays = scope .(){Count = numDisplays};

		mDevice.GetDisplays(displays.Ptr, ref numDisplays);

		mApplicationSettings.Plugins.Add(mRendererPlugin = new RendererPlugin(mEngine, mDevice));
		mApplicationSettings.Plugins.Add(mAudioPlugin = new AudioPlugin(mEngine));

		SDL.PumpEvents();
		return .Ok;
	}

	protected override void OnShutdown()
	{
		if (mAudioPlugin != null)
			delete mAudioPlugin;

		if (mRendererPlugin != null)
			delete mRendererPlugin;

		if (mDevice != null)
			delete mDevice;

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
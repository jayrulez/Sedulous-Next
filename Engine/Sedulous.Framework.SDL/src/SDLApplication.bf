using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Platform;
using SDL2;
using Sedulous.Renderer;
using Sedulous.RHI;
using Sedulous.RHI.Vulkan;
using Sedulous.Audio;
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

	protected override Result<void> OnStartup()
	{
		if (SDL.Init(.Everything) < 0)
		{
			Logger.LogCritical("SDL initialization failed: {0}", SDL.GetError());
			return .Err;
		}

		mWindow = new SDLWindow(mApplicationSettings.WindowTitle, mApplicationSettings.WindowWidth, mApplicationSettings.WindowHeight);
		mWindow.OnClosing.Subscribe(new () =>
			{
				this.Stop();
			});

		mDevice = new DeviceVK(Logger, null);

		mApplicationSettings.Plugins.Add(mRendererPlugin = new RendererPlugin(mEngine, mDevice));
		mApplicationSettings.Plugins.Add(mAudioPlugin = new AudioPlugin(mEngine));

		return .Ok;
	}

	protected override Result<void> OnInitialize()
	{
		SDL.PumpEvents();
		return .Ok;
	}

	protected override void OnShutdown()
	{
		delete mAudioPlugin;

		delete mRendererPlugin;

		delete mDevice;

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
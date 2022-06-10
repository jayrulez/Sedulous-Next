using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Platform;
using SDL2;
using Sedulous.Renderer;
using Sedulous.Audio;
using System.Collections;
using Sedulous.Graphics;
using Sedulous.Graphics.Vulkan;
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
	//private RendererPlugin mRendererPlugin = null;
	//private AudioPlugin mAudioPlugin = null;
	//private Device mDevice = null;
	//private DeviceAllocator mDeviceAllocator = new DeviceAllocator() ~ delete _;

	private ValidationLayer mGraphicsValidationLayer = null;
	private GraphicsContext mGraphicsContext = null;
	private SwapChain mSwapChain = null;

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

	protected TextureSampleCount SampleCount = TextureSampleCount.None;

	private SwapChainDescription CreateSwapChainDescription(uint32 width, uint32 height, ref SurfaceInfo surfaceInfo){
		return SwapChainDescription()
		{
		    Width = width,
		    Height = height,
		    SurfaceInfo = surfaceInfo,
		    ColorTargetFormat = PixelFormat.R8G8B8A8_UNorm,
		    ColorTargetFlags = TextureFlags.RenderTarget | TextureFlags.ShaderResource,
		    DepthStencilTargetFormat = PixelFormat.D24_UNorm_S8_UInt,
		    DepthStencilTargetFlags = TextureFlags.DepthStencil,
		    SampleCount = this.SampleCount,
		    IsWindowed = true,
		    RefreshRate = 60,
		};
	}

	protected override Result<void> OnInitialize()
	{
		mWindow = new SDLWindow(mApplicationSettings.WindowTitle, mApplicationSettings.WindowWidth, mApplicationSettings.WindowHeight);
		mWindow.Closing.Subscribe(new () =>
			{
				this.Stop();
			});

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


		mGraphicsValidationLayer = new ValidationLayer(.Trace);
		mGraphicsContext = new VKGraphicsContext();

		mGraphicsContext.DefaultTextureUploaderSize = 128 * 1024 * 1024;
		mGraphicsContext.DefaultBufferUploaderSize = 64 * 1024 * 1024;

		mGraphicsContext.CreateDevice(mGraphicsValidationLayer);

		SwapChainDescription swapChainDescription = CreateSwapChainDescription(mWindow.Width, mWindow.Height, ref mWindow.SurfaceInfo);
		mSwapChain = mGraphicsContext.CreateSwapChain(swapChainDescription);

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

		if (mSwapChain != null)
			delete mSwapChain;

		if (mGraphicsContext != null)
			delete mGraphicsContext;

		if (mGraphicsValidationLayer != null)
			delete mGraphicsValidationLayer;

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
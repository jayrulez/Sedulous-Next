using SDL2;
using Sedulous.Framework;
using System;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Platform;
namespace Sedulous.SDL;

class SDLApplication : Application
{
	public Window Window { get; private set; } ~ delete _;

	private bool mSDLInitialized = false;

	public this(ILogger logger, String windowTitle, uint windowWidth, uint windowHeight)
		: base(logger)
	{
		if (SDL.Init(.Everything) < 0)
		{
			Runtime.FatalError(scope $"SDL initialization failed: {SDL.GetError()}");
		}
		mSDLInitialized = true;

		Window = new SDLWindow(windowTitle, (.)windowWidth, (.)windowHeight);

		SDL.PumpEvents();
	}

	protected override Result<void> OnInitialize() => .Ok;

	protected override void OnFrameBegin()
	{
		if (let sdlWindow = Window as SDLWindow)
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

	public ~this()
	{
		if (mSDLInitialized)
		{
			SDL.Quit();
		}
	}
}
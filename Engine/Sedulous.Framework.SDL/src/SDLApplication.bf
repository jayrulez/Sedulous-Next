using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Platform;
using SDL2;
namespace Sedulous.Framework.SDL
{
	struct ApplicationDesc
	{
		public StringView WindowTitle;
		public uint32 WindowWidth;
		public uint32 WindowHeight;
	}

	class SDLApplication : Application
	{
		private readonly ApplicationDesc mApplicationDesc;
		private Window mWindow;



		public this(ILogger logger, in StringView windowTitle, uint32 windowWidth, uint32 windowHeight) : base(logger)
		{
			mApplicationDesc = .()
				{
					WindowTitle = windowTitle,
					WindowWidth = windowWidth,
					WindowHeight = windowHeight
				};
		}

		protected override Result<void> OnStartup()
		{
			if (SDL.Init(.Everything) < 0)
			{
				Logger.LogCritical("SDL initialization failed: {0}", SDL.GetError());
				return .Err;
			}

			mWindow = new SDLWindow(mApplicationDesc.WindowTitle, mApplicationDesc.WindowWidth, mApplicationDesc.WindowHeight);
			mWindow.OnClosing.Subscribe(new () =>
				{
					this.Stop();
				});

			return .Ok;
		}

		protected override Result<void> OnInitialize()
		{
			SDL.PumpEvents();
			return .Ok;
		}

		protected override void OnShutdown()
		{
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
}
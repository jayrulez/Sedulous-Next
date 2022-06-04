using Sedulous.Platform;
using SDL2;
using System;
namespace Sedulous.Framework.SDL
{
	class SDLWindow : Window
	{
		private SDL.Window* SDLNativeWindow;
		//private WindowHandleInfo mNativeWindowHandleInfo;
		private String mTitle = new String() ~ delete _;

		//public override readonly ref WindowHandleInfo NativeWindowInfo => ref mNativeWindowHandleInfo;

		public override String Title
		{
			get
			{
				mTitle.Clear();
				mTitle.Append(SDL.GetWindowTitle(SDLNativeWindow));
				return mTitle;
			}

			set
			{
				SDL.SetWindowTitle(SDLNativeWindow, value);
				mTitle.Set(value);
			}
		}

		public override bool Visible
		{
			get
			{
				return (SDL.GetWindowFlags(SDLNativeWindow) | (uint32)SDL.WindowFlags.Shown) > 0;
			}

			set
			{
				SDL.HideWindow(SDLNativeWindow);
			}
		}

		public this(in StringView title, uint32 width, uint32 height)
			: base(title, width, height)
		{
			SDL.WindowFlags flags = .Shown | SDL.WindowFlags.Resizable; // | SDL.WindowFlags.Vulkan;
			SDLNativeWindow = SDL.CreateWindow(title.Ptr, .Undefined, .Undefined, (int32)width, (int32)height, flags);

			if (SDLNativeWindow == null)
			{
				Runtime.FatalError("Failed to create SDL window.");
			}

			SDL.SDL_SysWMinfo info = .();
			SDL.GetVersion(out info.version);
			SDL.GetWindowWMInfo(SDLNativeWindow, ref info);
			SDL.SDL_SYSWM_TYPE subsystem = info.subsystem;
			switch (subsystem) {
			case SDL.SDL_SYSWM_TYPE.SDL_SYSWM_WINDOWS:
				/*mNativeWindowHandleInfo = .()
					{
						windowSystemType = .WINDOWS,
						window = .()
							{
								windows = .()
									{
										hwnd = (void*)(int)info.info.win.window
									}
							}
					};*/
				break;

			case SDL.SDL_SYSWM_TYPE.SDL_SYSWM_UNKNOWN: fallthrough;
			default:
				Runtime.FatalError("Subsystem not currently supported.");
			}
		}

		public ~this()
		{
			if (SDLNativeWindow != null)
			{
				SDL.DestroyWindow(SDLNativeWindow);
				SDLNativeWindow = null;
			}
		}

		private void OnEvent(SDL.Event ev)
		{
			if (ev.type == SDL.EventType.WindowEvent)
			{
				var windowEvent = ev.window;
				if (windowEvent.windowEvent != .SizeChanged)
				{
					switch (windowEvent.windowEvent) {
					case .FocusGained:
						FocusGained();
						break;

					case .Focus_lost:
						FocusLost();
						break;

					case .Close:
						Closing();
						break;

					default:
						break;
					}
				} else
				{
					SDL.GetWindowSize(SDLNativeWindow, var width, var height);

					Width = (uint32)width;
					Height = (uint32)height;

					Resized();
				}
			}
		}
	}
}
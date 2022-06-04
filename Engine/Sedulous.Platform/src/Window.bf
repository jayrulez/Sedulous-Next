using Sedulous.Foundation.Utilities;
using System;
namespace Sedulous.Platform
{
	abstract class Window
	{
		public EventAccessor<delegate void()> OnFocusGained = new .();
		public EventAccessor<delegate void()> OnFocusLost = new .();
		public EventAccessor<delegate void(uint32 width, uint32 height)> OnResized = new .();
		public EventAccessor<delegate void()> OnClosing = new .();

		public abstract String Title { get; set; }
		public abstract bool Visible { get; set; }
		//public abstract readonly ref WindowHandleInfo NativeWindowInfo { get; }

		public uint32 Width { get; protected set; }
		public uint32 Height { get; protected set; }

		public this(StringView title, uint32 width, uint32 height)
		{
			Width = width;
			Height = height;
		}

		public ~this(){
			delete OnClosing;
			delete OnResized;
			delete OnFocusLost;
			delete OnFocusGained;
		}

		protected virtual void FocusGained()
		{
			if (OnFocusGained.[Friend]mEvent.HasListeners)
				OnFocusGained.[Friend]mEvent();
		}

		protected virtual void FocusLost()
		{
			if (OnFocusLost.[Friend]mEvent.HasListeners)
				OnFocusLost.[Friend]mEvent();
		}

		protected virtual void Resized()
		{
			if (OnResized.[Friend]mEvent.HasListeners)
				OnResized.[Friend]mEvent(Width, Height);
		}

		protected virtual void Closing()
		{
			if (OnClosing.[Friend]mEvent.HasListeners)
				OnClosing.[Friend]mEvent();
		}
	}
}
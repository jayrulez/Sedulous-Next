using System;
using Sedulous.Foundation.Utilities;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Represent a control/widget on a WindowSystem.
	/// </summary>
	public abstract class Surface : IDisposable
	{
		private bool disposed;

		/// <summary>
		/// Surface information.
		/// </summary>
		public SurfaceInfo SurfaceInfo;

		/// <summary>
		/// Surface Width.
		/// </summary>
		public uint32 Width;

		/// <summary>
		/// Surface Height.
		/// </summary>
		public uint32 Height;

		/// <summary>
		/// Gets or sets the surface DPI density.
		/// </summary>
		public float DPIDensity { get; protected set; } = 1f;


		/// <summary>
		/// Gets the keyboard events dispatcher associated to this surface.
		/// </summary>
		//public abstract KeyboardDispatcher KeyboardDispatcher { get; }

		/// <summary>
		/// Gets the mouse events dispatcher associated to this surface.
		/// </summary>
		//public abstract MouseDispatcher MouseDispatcher { get; }

		/// <summary>
		/// Gets the touch events dispatcher associated to this surface.
		/// </summary>
		//public abstract PointerDispatcher TouchDispatcher { get; }

		/// <summary>
		/// Occurs when surface size is changed.
		/// </summary>
		public EventAccessor<delegate void(uint32 width, uint32 height)> OnScreenSizeChanged;

		/// <summary>
		/// Occurs when surface info is changed.
		/// </summary>
		public EventAccessor<delegate void(in SurfaceInfo surfaceInfo)> OnSurfaceInfoChanged;

		/// <summary>
		/// Occurs when surface is closing
		/// </summary>
		public EventAccessor<delegate void()> Closing;

		/// <summary>
		/// Occurs when surface get focus
		/// </summary>
		public EventAccessor<delegate void()> GotFocus;

		/// <summary>
		/// Occurs when surface lost focus
		/// </summary>
		public EventAccessor<delegate void()> LostFocus;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Surface" /> class.
		/// </summary>
		/// <param name="width">surface width.</param>
		/// <param name="height">surface height.</param>
		public this(uint32 width, uint32 height)
		{
			Width = width;
			Height = height;
		}

		public ~this(){
			delete OnScreenSizeChanged;
			delete OnSurfaceInfoChanged;
			delete Closing;
			delete GotFocus;
			delete LostFocus;
		}

		/// <summary>
		/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
		/// </summary>
		public void Dispose()
		{
			//Dispose(disposing: true);
			//GC.SuppressFinalize(this);
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing">
		/// <c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.
		/// </param>
		private void Dispose(bool disposing)
		{
			if (!disposed && disposing)
			{
				Destroy();
				disposed = true;
			}
		}

		/// <summary>
		/// Remove managed resources.
		/// </summary>
		protected virtual void Destroy()
		{
			int32 num = 0;
			while (SurfaceInfo.Handles != null && num < SurfaceInfo.Handles.Count)
			{
				SurfaceInfo.Handles[num] = null;
				num++;
			}

			SurfaceInfo.Dispose();
		}

		/// <summary>
		/// Raise base window closing event.
		/// </summary>
		protected virtual void OnClosing()
		{
			if(this.Closing.[Friend]mEvent.HasListeners)
			this.Closing.[Friend]mEvent();
		}

		/// <summary>
		/// Raise base got focus event.
		/// </summary>
		protected virtual void OnGotFocus()
		{
			if(this.GotFocus.[Friend]mEvent.HasListeners)
			this.GotFocus.[Friend]mEvent();
		}

		/// <summary>
		/// Raise base lost focus event.
		/// </summary>
		protected virtual void OnLostFocus()
		{
			if(this.LostFocus.[Friend]mEvent.HasListeners)
			this.LostFocus.[Friend]mEvent();
		}

		/// <summary>
		/// Raise base size changed event.
		/// </summary>
		protected virtual void OnSizeChanged()
		{
			if(this.OnScreenSizeChanged.[Friend]mEvent.HasListeners)
			this.OnScreenSizeChanged.[Friend]mEvent(Width, Height);
		}

		/// <summary>
		/// Raise surface info changed.
		/// </summary>
		protected virtual void OnInfoChanged()
		{
			if(this.OnSurfaceInfoChanged.[Friend]mEvent.HasListeners)
			this.OnSurfaceInfoChanged.[Friend]mEvent(SurfaceInfo);
		}
	}
}

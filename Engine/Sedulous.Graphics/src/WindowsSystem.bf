using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Represent a specify windows technology.
	/// </summary>
	public abstract class WindowsSystem : IDisposable
	{
		private bool disposed;

		/// <summary>
		/// Create a Window.
		/// </summary>
		/// <param name="title">Window title.</param>
		/// <param name="width">Window width.</param>
		/// <param name="height">Window height.</param>
		/// <param name="visible">Window visibility.</param>
		/// <returns>Window instance.</returns>
		public abstract Window CreateWindow(String title, uint32 width, uint32 height, bool visible = true);

		/// <summary>
		/// Create a surface.
		/// </summary>
		/// <param name="width">Surface width.</param>
		/// <param name="height">Surface height.</param>
		/// <returns>Surface instance.</returns>
		public abstract Surface CreateSurface(uint32 width, uint32 height);

		/// <summary>
		/// Create a surface.
		/// </summary>
		/// <param name="nativeSurface">The native surface control.</param>
		/// <returns>Surface instance.</returns>
		public abstract Surface CreateSurface(Object nativeSurface);

		/// <summary>
		/// Run the windows system.
		/// </summary>
		/// <param name="loadAction">Action does in load thread.</param>
		/// <param name="renderCallback">Action to be executed every render loop.</param>
		public void Run(Action loadAction, Action renderCallback)
		{
			CreateLoopThread(loadAction, renderCallback);
		}

		/// <summary>
		/// Creates a loop thread.
		/// </summary>
		/// <param name="loadAction">The load action.</param>
		/// <param name="renderCallback">The render callback action.</param>
		protected abstract void CreateLoopThread(Action loadAction, Action renderCallback);

		/// <summary>
		/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
		/// </summary>
		public void Dispose()
		{
			/*Dispose(disposing: true);
			GC.SuppressFinalize(this);*/
		}

		/// <summary>
		/// Destroy all resources.
		/// </summary>
		protected virtual void Destroy()
		{
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
	}
}

using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// A resource interface provides common actions on all resources.
	/// </summary>
	public abstract class GraphicsResource
	{
		/// <summary>
		/// The device context reference.
		/// </summary>
		public GraphicsContext Context;

		/// <summary>
		/// Gets the native pointer.
		/// </summary>
		public abstract void* NativePointer { get; }

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.GraphicsResource" /> class.
		/// </summary>
		/// <param name="context">The device context.</param>
		protected this(GraphicsContext context)
		{
			Context = context;
		}

		/// <summary>
		/// Dispose this instance.
		/// </summary>
		protected abstract void OnDestroy();
	}
}

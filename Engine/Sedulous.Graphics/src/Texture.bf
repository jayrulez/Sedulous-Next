using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This class represent a Texture graphics resource.
	/// </summary>
	public abstract class Texture : GraphicsResource
	{
		/// <summary>
		/// Gets or sets the <see cref="T:Sedulous.Graphics.TextureDescription" /> struct.
		/// </summary>
		public readonly TextureDescription Description;

		/// <summary>
		/// Gets or sets a String identifying this instance. Can be used in graphics debuggers tools.
		/// </summary>
		public abstract String Name { get; set; }

		/// <summary>
		/// Gets a value indicating whether this texture could be attached to a framebuffer.
		/// </summary>
		public virtual bool CouldBeAttachedToFramebuffer => true;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Texture" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The texture description.</param>
		protected this(GraphicsContext context, ref TextureDescription description)
			: base(context)
		{
			Description = description;
		}

		protected override void OnDestroy(){

		}

		/// <inheritdoc />
		public void ReleaseUnusedMemory()
		{
		}
	}
}

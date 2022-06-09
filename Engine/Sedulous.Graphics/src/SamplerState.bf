using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This class represent a sampler state.
	/// </summary>
	public abstract class SamplerState : GraphicsResource
	{
		/// <summary>
		/// The sampler state description.
		/// </summary>
		public readonly SamplerStateDescription Description;

		/// <summary>
		/// Gets or sets a String identifying this instance. Can be used in graphics debuggers tools.
		/// </summary>
		public abstract String Name { get; set; }

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.SamplerState" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The sampler state description.</param>
		protected this(GraphicsContext context, ref SamplerStateDescription description)
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

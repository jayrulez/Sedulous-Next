namespace Sedulous.Graphics.Raytracing
{
	/// <summary>
	/// Top Level Acceleration Structure.
	/// </summary>
	public abstract class TopLevelAS : GraphicsResource
	{
		/// <summary>
		/// Get the Acceleration Structure description.
		/// </summary>
		public TopLevelASDescription Description;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Raytracing.TopLevelAS" /> class.
		/// </summary>
		/// <param name="context">The device context.</param>
		/// <param name="description">The Top Level Acceleration Structure description.</param>
		protected this(GraphicsContext context, ref TopLevelASDescription description)
			: base(context)
		{
			Description = description;
		}

		

		protected override void OnDestroy(){

		}
	}
}

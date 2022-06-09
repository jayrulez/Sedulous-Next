using System;
namespace Sedulous.Graphics
{
	/// <summary>
	/// This class represent the GPU graphics pipeline.
	/// </summary>
	public abstract class ComputePipelineState : PipelineState
	{
		/// <summary>
		/// Gets the compute pipelinestate description.
		/// </summary>
		public readonly ComputePipelineDescription Description;

		/// <summary>
		/// Gets or sets a String identifying this instance. Can be used in graphics debuggers tools.
		/// </summary>
		public abstract String Name { get; set; }

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ComputePipelineState" /> class.
		/// </summary>
		/// <param name="description">The pipelineState description.</param>
		protected this(ref ComputePipelineDescription description)
		{
			Description = description;
		}
	}
}

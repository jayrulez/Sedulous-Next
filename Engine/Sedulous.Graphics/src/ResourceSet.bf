using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This class describes the elements inside a <see cref="T:Sedulous.Graphics.ResourceLayout" />.
	/// </summary>
	public abstract class ResourceSet : IDisposable
	{
		/// <summary>
		/// The resourceSet description <see cref="T:Sedulous.Graphics.ResourceSetDescription" />.
		/// </summary>
		public readonly ResourceSetDescription Description;

		/// <summary>
		/// Gets or sets a String identifying this instance. Can be used in graphics debuggers tools.
		/// </summary>
		public abstract String Name { get; set; }

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ResourceSet" /> class.
		/// </summary>
		/// <param name="description">The resourceSet description.</param>
		public this(ref ResourceSetDescription description)
		{
			Description = description;
		}

		/// <summary>
		/// /// Frees managed and unmanaged resources.
		/// </summary>
		public abstract void Dispose();
	}
}

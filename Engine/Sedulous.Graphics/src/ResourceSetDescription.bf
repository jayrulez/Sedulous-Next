namespace Sedulous.Graphics
{
	/// <summary>
	/// This class describes the elements inside a <see cref="T:Sedulous.Graphics.ResourceLayout" />.
	/// </summary>
	public struct ResourceSetDescription
	{
		/// <summary>
		/// The resourceLayout Object <see cref="T:Sedulous.Graphics.ResourceLayout" />.
		/// </summary>
		public ResourceLayout Layout;

		/// <summary>
		/// An array of <see cref="T:Sedulous.Graphics.GraphicsResource" /> elements as Textures, ConstantBuffers, Samples.
		/// </summary>
		public GraphicsResource[] Resources;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ResourceSetDescription" /> struct.
		/// </summary>
		/// <param name="layout">The resourceLayout Object.</param>
		/// <param name="resources">The list of resources.</param>
		public this(ResourceLayout layout, params GraphicsResource[] resources)
		{
			Layout = layout;
			Resources = resources;
		}
	}
}

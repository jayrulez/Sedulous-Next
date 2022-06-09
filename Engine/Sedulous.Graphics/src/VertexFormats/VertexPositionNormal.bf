using Sedulous.Foundation.Mathematics;

namespace Sedulous.Graphics.VertexFormats
{
	/// <summary>
	/// Represents a vertex with position and normal.
	/// </summary>
	public struct VertexPositionNormal
	{
		/// <summary>
		/// Vertex position.
		/// </summary>
		public Vector3 Position;

		/// <summary>
		/// Vertex normal.
		/// </summary>
		public Vector3 Normal;

		/// <summary>
		/// Vertex format.
		/// </summary>
		public static readonly LayoutDescription VertexFormat;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.VertexFormats.VertexPositionNormal" /> struct.
		/// </summary>
		/// <param name="position">The position.</param>
		/// <param name="normal">The normal.</param>
		public this(Vector3 position, Vector3 normal)
		{
			Position = position;
			Normal = normal;
		}

		/// <summary>
		/// Initializes static members of the <see cref="T:Sedulous.Graphics.VertexFormats.VertexPositionNormal" /> struct.
		/// </summary>
		static this()
		{
			VertexFormat = new LayoutDescription()
				.Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position))
				.Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Normal));
		}

		static ~this()
		{
			delete VertexFormat;
		}
	}
}

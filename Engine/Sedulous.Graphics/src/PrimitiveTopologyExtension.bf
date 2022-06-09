using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Helper methods for primitive topology.
	/// </summary>
	public static class PrimitiveTopologyExtension
	{
		/// <summary>
		/// Convert index count to primitive count.
		/// </summary>
		/// <param name="primitiveTopology">The primitive topology.</param>
		/// <param name="elementCount">The index count.</param>
		/// <returns>The primitive count.</returns>
		public static int32 ToPrimitiveCount(this PrimitiveTopology primitiveTopology, int32 elementCount)
		{
			switch (primitiveTopology)
			{
			case PrimitiveTopology.LineList:
				return elementCount / 2;
			case PrimitiveTopology.LineListWithAdjacency:
				return elementCount / 4;
			case PrimitiveTopology.LineStrip:
				return elementCount - 1;
			case PrimitiveTopology.LineStripWithAdjacency:
				return elementCount - 3;
			case PrimitiveTopology.TriangleList:
				return elementCount / 3;
			case PrimitiveTopology.TriangleListWithAdjacency:
				return elementCount / 6;
			case PrimitiveTopology.TriangleStrip:
				return elementCount - 2;
			case PrimitiveTopology.TriangleStripWithAdjacency:
				return (elementCount - 1) / 2;
			default:
				Runtime.FatalError(scope $"Primitive topology {primitiveTopology} not supported.");
			}
		}

		/// <summary>
		/// Convert primitive count to index count.
		/// </summary>
		/// <param name="primitiveTopology">The primitive topology.</param>
		/// <param name="primitiveCount">The primitive count.</param>
		/// <returns>The index count.</returns>
		public static int32 ToIndexCount(this PrimitiveTopology primitiveTopology, int32 primitiveCount)
		{
			switch (primitiveTopology)
			{
			case PrimitiveTopology.LineList:
				return primitiveCount * 2;
			case PrimitiveTopology.LineListWithAdjacency:
				return primitiveCount * 4;
			case PrimitiveTopology.LineStrip:
				return primitiveCount + 1;
			case PrimitiveTopology.LineStripWithAdjacency:
				return primitiveCount + 3;
			case PrimitiveTopology.TriangleList:
				return primitiveCount * 3;
			case PrimitiveTopology.TriangleListWithAdjacency:
				return primitiveCount * 6;
			case PrimitiveTopology.TriangleStrip:
				return primitiveCount + 2;
			case PrimitiveTopology.TriangleStripWithAdjacency:
				return primitiveCount * 2 + 1;
			default:
				Runtime.FatalError(scope $"Primitive topology {primitiveTopology} not supported.");
			}
		}
	}
}

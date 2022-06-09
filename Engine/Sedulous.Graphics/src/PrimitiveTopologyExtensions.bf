using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Primitive topology extensions.
	/// </summary>
	public static class PrimitiveTopologyExtensions
	{
		/// <summary>
		/// Interpret the vertex data as a patch list.
		/// </summary>
		/// <param name="topology">The primitive topology.</param>
		/// <param name="points">Number of control points. Valid range 1 - 32.</param>
		/// <returns>The result primitive topology.</returns>
		public static PrimitiveTopology ControlPoints(this PrimitiveTopology topology, int32 points)
		{
			if (topology != PrimitiveTopology.Patch_List)
			{
				Runtime.FatalError("Control points method apply only to PrimitiveTopology.Patch_List");
			}
			if (points < 1 || points > 32)
			{
				Runtime.FatalError("Control points value must be in between 1 and 32");
			}
			return (PrimitiveTopology)(33 + points - 1);
		}
	}
}

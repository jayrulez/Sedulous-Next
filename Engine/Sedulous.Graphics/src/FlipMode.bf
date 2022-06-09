using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Indicates the flip mode of a sprite, billboard, etc...
	/// </summary>
	//[Flags]
	public enum FlipMode : uint8
	{
		/// <summary>
		/// No flip.
		/// </summary>
		None = 0x0,
		/// <summary>
		/// Horizontal flip.
		/// </summary>
		FlipHorizontally = 0x1,
		/// <summary>
		/// Vertical flip.
		/// </summary>
		FlipVertically = 0x2
	}
}

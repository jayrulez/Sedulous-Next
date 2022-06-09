using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Specifies <see cref="T:Sedulous.Graphics.FrameBuffer" /> clearing modes.
	/// </summary>
	//[Flags]
	public enum ClearFlags
	{
		/// <summary>
		/// Do not clear.
		/// </summary>
		None = 0x0,
		/// <summary>
		/// Clear color target.
		/// </summary>
		Target = 0x1,
		/// <summary>
		/// Clear depth target.
		/// </summary>
		Depth = 0x2,
		/// <summary>
		/// Clear the stencil target
		/// </summary>
		Stencil = 0x4,
		/// <summary>
		/// Clear color, depth and stencil target
		/// </summary>
		All = 0x7
	}
}

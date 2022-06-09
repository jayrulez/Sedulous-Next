using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Identify which components of each pixel of a render target are writable during blending.
	/// </summary>
	//[Flags]
	public enum ColorWriteChannels
	{
		/// <summary>
		/// None of the data are stored.
		/// </summary>
		None = 0x0,
		/// <summary>
		/// Allow data to be stored in the red component.
		/// </summary>
		Red = 0x1,
		/// <summary>
		/// Allow data to be stored in the green component.
		/// </summary>
		Green = 0x2,
		/// <summary>
		/// Allow data to be stored in the blue component.
		/// </summary>
		Blue = 0x4,
		/// <summary>
		/// Allow data to be stored in the alpha component.
		/// </summary>
		Alpha = 0x8,
		/// <summary>
		/// Allow data to be stored in all components.
		/// </summary>
		All = 0xF
	}
}

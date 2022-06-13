using Sedulous.Foundation.Mathematics;
using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Structure specifying a clear value.
	/// </summary>
	public struct ClearValue
	{
		/// <summary>
		/// The array of color clear value to use when clearing each color attachment.
		/// </summary>
		public Span<Vector4> ColorValues;

		/// <summary>
		/// The depth clear value to use when clearing a depth/stencil attachment.
		/// </summary>
		public float Depth;

		/// <summary>
		/// The stencil clear value to use when clearing a depth/stencil attachment.
		/// </summary>
		public uint8 Stencil;

		/// <summary>
		/// Kind of clear to perfom <see cref="T:Sedulous.Graphics.ClearValue" />.
		/// </summary>
		public ClearFlags Flags;

		/// <summary>
		/// Gets default values for None clear value.
		/// </summary>
		public static ClearValue None
		{
			get
			{
				ClearValue result = default(ClearValue);
				result.Flags = ClearFlags.None;
				return result;
			}
		}

		/// <summary>
		/// Gets default values for clear value.
		/// </summary>
		/// <remarks>That mean one ColorAttachment using CornFlowerBlue as clear color and depth = 1 / stencil = 0.</remarks>
		/*public static ClearValue Default
		{
			get
			{
				ClearValue result = default(ClearValue);
				result.Flags = ClearFlags.All;
				result.ColorValues = new Vector4[1] ( Color.CornflowerBlue.ToVector4() );
				result.Depth = 1f;
				result.Stencil = 0;
				return result;
			}
		}*/

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ClearValue" /> struct.
		/// </summary>
		/// <param name="flags">Identify the textures to clear <see cref="T:Sedulous.Graphics.ClearFlags" />.</param>
		/// <param name="colorValues">The array of values to clear the color attachments.</param>
		/*public this(ClearFlags flags, params Color[] colorValues)
			: this(flags, 1f, 0, params colorValues)
		{
		}*/

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ClearValue" /> struct.
		/// </summary>
		/// <param name="flags">Identify the textures to clear <see cref="T:Sedulous.Graphics.ClearFlags" />.</param>
		/// <param name="colorValue">The value to clear the color attachment.</param>
		/*public this(ClearFlags flags, Color colorValue)
			: this(flags, 1f, 0, colorValue)
		{
		}*/

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ClearValue" /> struct.
		/// </summary>
		/// <param name="flags">Identify the textures to clear <see cref="T:Sedulous.Graphics.ClearFlags" />.</param>
		/// <param name="colorValues">The array of values to clear the color attachments.</param>
		/*public this(ClearFlags flags, params Vector4[] colorValues)
			: this(flags, 1f, 0, params colorValues)
		{
		}*/

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ClearValue" /> struct.
		/// </summary>
		/// <param name="flags">Identify the textures to clear <see cref="T:Sedulous.Graphics.ClearFlags" />.</param>
		/// <param name="depth">The value to clear the depth buffer.</param>
		/// <param name="stencil">The value to clear the stencil buffer.</param>
		/// <param name="colorValues">The array of values to clear the color attachments.</param>
		/*public this(ClearFlags flags, float depth, uint8 stencil, params Color[] colorValues)
		{
			Flags = flags;
			Depth = depth;
			Stencil = stencil;
			ColorValues = new Vector4[colorValues.Count];
			for (int32 i = 0; i < colorValues.Count; i++)
			{
				ColorValues[i] = colorValues[i].ToVector4();
			}
		}*/

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ClearValue" /> struct.
		/// </summary>
		/// <param name="flags">Identify the textures to clear <see cref="T:Sedulous.Graphics.ClearFlags" />.</param>
		/// <param name="depth">The value to clear the depth buffer.</param>
		/// <param name="stencil">The value to clear the stencil buffer.</param>
		/// <param name="colorValue">The value to clear the color attachment.</param>
		/*public this(ClearFlags flags, float depth, uint8 stencil, Color colorValue)
		{
			Flags = flags;
			Depth = depth;
			Stencil = stencil;
			ColorValues = new Vector4[1] { colorValue.ToVector4() };
		}*/

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ClearValue" /> struct.
		/// </summary>
		/// <param name="flags">Identify the textures to clear <see cref="T:Sedulous.Graphics.ClearFlags" />.</param>
		/// <param name="depth">The value to clear the depth buffer.</param>
		/// <param name="stencil">The value to clear the stencil buffer.</param>
		/// <param name="colorValues">The array of values to clear the color attachments.</param>
		public this(ClearFlags flags, float depth, uint8 stencil, params Vector4[] colorValues)
		{
			Flags = flags;
			Depth = depth;
			Stencil = stencil;
			ColorValues = colorValues;
		}
	}
}

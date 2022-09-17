using Sedulous.Foundation.Utilities;
using System;
namespace Sedulous.Platform;

/// <summary>
/// Represent a Window on WindowSystem.
/// </summary>
abstract class Window : Surface
{
	/// <summary>
	/// Gets or sets window title.
	/// </summary>
	public abstract String Title { get; set; }

	/// <summary>
	/// Gets or sets a value indicating whether the window is visible.
	/// </summary>
	public abstract bool Visible { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Window" /> class.
	/// </summary>
	/// <param name="title">Window title.</param>
	/// <param name="width">Window width.</param>
	/// <param name="height">Window height.</param>
	public this(StringView title, uint32 width, uint32 height)
		: base(width, height)
	{
	}
}
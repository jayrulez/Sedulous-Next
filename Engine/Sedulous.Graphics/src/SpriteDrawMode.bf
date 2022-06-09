namespace Sedulous.Graphics
{
	/// <summary>
	/// Specifies texture addressing mode.
	/// </summary>
	public enum SpriteDrawMode
	{
		/// <summary>
		/// Displays the full sprite.
		/// </summary>
		Simple,
		/// <summary>
		/// The SpriteRenderer will render the sprite as a nine patch image where the corners will remain constant and the other sections will scale.
		/// </summary>
		Sliced
	}
}

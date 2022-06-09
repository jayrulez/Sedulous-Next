namespace Sedulous.Graphics
{
	/// <summary>
	/// Default known values for <see cref="T:Sedulous.Graphics.DepthStencilStateDescription" />.
	/// </summary>
	public static class DepthStencilStates
	{
		/// <summary>
		/// Depth disable.
		/// </summary>
		public static readonly DepthStencilStateDescription None;

		/// <summary>
		/// Depth enable and writemask enable.
		/// </summary>
		public static readonly DepthStencilStateDescription ReadWrite;

		/// <summary>
		/// Depth enable but writemask zero.
		/// </summary>
		public static readonly DepthStencilStateDescription Read;

		/// <summary>
		/// Initializes static members of the <see cref="T:Sedulous.Graphics.DepthStencilStates" /> class.
		/// </summary>
		static this()
		{
			None = DepthStencilStateDescription.Default;
			None.DepthEnable = false;
			None.DepthWriteMask = false;
			ReadWrite = DepthStencilStateDescription.Default;
			Read = DepthStencilStateDescription.Default;
			Read.DepthWriteMask = false;
		}
	}
}

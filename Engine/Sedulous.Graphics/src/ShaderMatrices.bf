using Sedulous.Foundation.Mathematics;
using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Stores all the matrices needed by a shader.
	/// </summary>
	[CRepr]
	public struct ShaderMatrices
	{
		/// <summary>
		/// World * View * Projection matrix.
		/// </summary>
		public Matrix4x4 WorldViewProj;

		/// <summary>
		/// World matrix.
		/// </summary>
		public Matrix4x4 World;

		/// <summary>
		/// World inverse transpose matrix.
		/// </summary>
		public Matrix4x4 WorldInverseTranspose;
	}
}

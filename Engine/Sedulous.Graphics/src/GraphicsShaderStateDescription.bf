using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This struct contains all the shader stages.
	/// </summary>
	public class GraphicsShaderStateDescription : ShaderStateDescription, IEquatable<GraphicsShaderStateDescription>
	{
		/// <summary>
		/// Gets or sets the vertex shader program.
		/// </summary>
		public Shader VertexShader;

		/// <summary>
		/// Gets or sets the hull shader program.
		/// </summary>
		public Shader HullShader;

		/// <summary>
		/// Gets or sets the domain shader program.
		/// </summary>
		public Shader DomainShader;

		/// <summary>
		/// Gets or sets the geometry shader program.
		/// </summary>
		public Shader GeometryShader;

		/// <summary>
		/// Gets or sets the pixel shader program.
		/// </summary>
		public Shader PixelShader;

		/// <summary>
		/// Represent a relationship between semantics and shader locations.
		/// </summary>
		public InputLayouts ShaderInputLayout;

		/// <inheritdoc />
		public bool Equals(GraphicsShaderStateDescription other)
		{
			if (VertexShader != other.VertexShader || HullShader != other.HullShader || DomainShader != other.DomainShader || GeometryShader != other.GeometryShader || PixelShader != other.PixelShader)
			{
				return false;
			}
			return true;
		}

		/// <inheritdoc />
		public override int GetHashCode()
		{
			int num = 0;
			if (VertexShader != null)
			{
				num = (num * 397) ^ VertexShader.GetHashCode();
			}
			if (HullShader != null)
			{
				num = (num * 397) ^ HullShader.GetHashCode();
			}
			if (DomainShader != null)
			{
				num = (num * 397) ^ DomainShader.GetHashCode();
			}
			if (GeometryShader != null)
			{
				num = (num * 397) ^ GeometryShader.GetHashCode();
			}
			if (PixelShader != null)
			{
				num = (num * 397) ^ PixelShader.GetHashCode();
			}
			return num;
		}
	}
}

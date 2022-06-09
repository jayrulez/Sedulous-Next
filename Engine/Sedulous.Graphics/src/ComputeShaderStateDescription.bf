using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This struct contains all the shader stages.
	/// </summary>
	public class ComputeShaderStateDescription : ShaderStateDescription, IEquatable<ComputeShaderStateDescription>
	{
		/// <summary>
		/// Gets or sets the compute shader program.
		/// </summary>
		public Shader ComputeShader;

		/// <inheritdoc />
		public bool Equals(ComputeShaderStateDescription other)
		{
			if (ComputeShader != other.ComputeShader)
			{
				return false;
			}
			return true;
		}

		/// <inheritdoc />
		public override int GetHashCode()
		{
			int num = 0;
			if (ComputeShader != null)
			{
				num = (num * 397) ^ ComputeShader.GetHashCode();
			}
			return num;
		}
	}
}

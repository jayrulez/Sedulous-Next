using System;
using System.Collections;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Shader State Description.
	/// </summary>
	public abstract class ShaderStateDescription : IEquatable<ShaderStateDescription>, IHashable
	{
		/// <summary>
		/// ConstantBuffers bindings.
		/// Used in OpenGL 410 or minor and OpenGLES 300 or minor.
		/// </summary>
		public List<(String name, uint32 slot)> constantBuffersBindings;

		/// <summary>
		/// Textures bindings.
		/// Used in OpenGL 410 or minor and OpenGLES 300 or minor.
		/// </summary>
		public List<(String name, uint32 slot)> texturesBindings;

		/// <summary>
		/// Uniform parameters bindings.
		/// Used in WebGL1 and OpenGL ES 2.0.
		/// </summary>
		public Dictionary<String, BufferParameterBinding> bufferParametersBinding;

		/// <inheritdoc />
		public bool Equals(ShaderStateDescription other)
		{
			return false;
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator ==(ShaderStateDescription value1, ShaderStateDescription value2)
		{
			return value1.Equals(value2);
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator !=(ShaderStateDescription value1, ShaderStateDescription value2)
		{
			return !value1.Equals(value2);
		}

		/// <inheritdoc />
		public abstract int GetHashCode();
	}
}

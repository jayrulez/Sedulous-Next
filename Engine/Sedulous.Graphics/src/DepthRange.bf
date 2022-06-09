using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Abstracts a viewport used for defining rendering regions.
	/// </summary>
	public struct DepthRange : IEquatable<DepthRange>
	{
		/// <summary>
		/// Empty value for an undefined viewport.
		/// </summary>
		public static readonly DepthRange Default;

		/// <summary>
		/// Gets or sets the minimum Z (depth) value of the viewport.
		/// </summary>
		public float MinDepth;

		/// <summary>
		/// Gets or sets the maximum Z (depth) value of the viewport.
		/// </summary>
		public float MaxDepth;

		/// <summary>
		/// Initializes static members of the <see cref="T:Sedulous.Graphics.DepthRange" /> struct.
		/// </summary>
		static this()
		{
			Default = DepthRange(0f, 1f);
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.DepthRange" /> struct.
		/// </summary>
		/// <param name="minDepth">The min depth range.</param>
		/// <param name="maxDepth">The max depth range.</param>
		public this(float minDepth = 0f, float maxDepth = 1f)
		{
			MinDepth = minDepth;
			MaxDepth = maxDepth;
		}

		/// <summary>
		/// Computes the depth range applying it to a global depth range.
		/// </summary>
		/// <param name="globalDepthRange">The global depth range.</param>
		/// <param name="depthRange">The depth range to be applied.</param>
		/// <returns>The computed depth range.</returns>
		public static DepthRange ComputeDepthRange(ref DepthRange globalDepthRange, ref DepthRange depthRange)
		{
			if (globalDepthRange == Default)
			{
				return depthRange;
			}
			if (depthRange == Default)
			{
				return globalDepthRange;
			}
			float num = globalDepthRange.MaxDepth - globalDepthRange.MinDepth;
			return DepthRange(globalDepthRange.MinDepth + depthRange.MinDepth * num, globalDepthRange.MinDepth + depthRange.MaxDepth * num);
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <param name="other">Other used to compare.</param>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public bool Equals(DepthRange other)
		{
			if (MinDepth != other.MinDepth || MaxDepth != other.MaxDepth)
			{
				return false;
			}
			return true;
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public int GetHashCode()
		{
			return (MinDepth.GetHashCode() * 397) ^ MaxDepth.GetHashCode();
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator ==(DepthRange value1, DepthRange value2)
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
		public static bool operator !=(DepthRange value1, DepthRange value2)
		{
			return !value1.Equals(value2);
		}
	}
}

using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Contains properties that describe the characteristics of a new pipeline state Object.
	/// </summary>
	public struct OutputAttachmentDescription : IEquatable<OutputAttachmentDescription>
	{
		/// <summary>
		/// The pixel format.
		/// </summary>
		public PixelFormat Format;

		/// <summary>
		/// Indicates if the <see cref="T:Sedulous.Graphics.Texture" /> with MSAA attachment need to be resolved.
		/// </summary>
		public bool ResolveMSAA;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.OutputAttachmentDescription" /> struct.
		/// </summary>
		/// <param name="format">The format of the <see cref="T:Sedulous.Graphics.Texture" /> attachment.</param>
		/// <param name="resolveMSAA">Indicates if the <see cref="T:Sedulous.Graphics.Texture" /> with MSAA attachment need to be resolved.</param>
		public this(PixelFormat format, bool resolveMSAA = false)
		{
			Format = format;
			ResolveMSAA = resolveMSAA;
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <param name="other">Other used to compare.</param>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public bool Equals(OutputAttachmentDescription other)
		{
			if (Format != other.Format)
			{
				return ResolveMSAA == other.ResolveMSAA;
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
			return (int32)Format * (ResolveMSAA ? 1 : (-1));
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator ==(OutputAttachmentDescription value1, OutputAttachmentDescription value2)
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
		public static bool operator !=(OutputAttachmentDescription value1, OutputAttachmentDescription value2)
		{
			return !value1.Equals(value2);
		}
	}
}

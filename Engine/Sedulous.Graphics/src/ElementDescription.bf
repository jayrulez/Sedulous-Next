using System;
using System.IO;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Describes an individual component of a vertex.
	/// </summary>
	public struct ElementDescription : IEquatable<ElementDescription>
	{
		/// <summary>
		/// Use secuential offset.
		/// </summary>
		public const int32 AppendAligned = -1;

		/// <summary>
		/// Gets the type of the element.
		/// </summary>
		public ElementSemanticType Semantic;

		/// <summary>
		/// Gets the semantic index of this element.
		/// </summary>
		public uint32 SemanticIndex;

		/// <summary>
		/// Gets the format of the element.
		/// </summary>
		public ElementFormat Format;

		/// <summary>
		/// Gets the offset of the element.
		/// </summary>
		public int32 Offset;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.ElementDescription" /> struct.
		/// </summary>
		/// <param name="format">The element format, <see cref="T:Sedulous.Graphics.ElementFormat" />.</param>
		/// <param name="semanticType">The element semantic, <see cref="T:Sedulous.Graphics.ElementSemanticType" />.</param>
		/// <param name="semanticIndex">The semantic index for this element.</param>
		/// <param name="offset">The element offset.</param>
		public this(ElementFormat format, ElementSemanticType semanticType, uint32 semanticIndex = 0u, int32 offset = -1)
		{
			Semantic = semanticType;
			SemanticIndex = semanticIndex;
			Format = format;
			Offset = offset;
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <param name="other">Other used to compare.</param>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public bool Equals(ElementDescription other)
		{
			if (Semantic != other.Semantic || Format != other.Format)
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
			return (int32)(((uint32)((int32)Semantic * 397) ^ SemanticIndex) * 397) ^ (int32)Format;
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator ==(ElementDescription value1, ElementDescription value2)
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
		public static bool operator !=(ElementDescription value1, ElementDescription value2)
		{
			return !value1.Equals(value2);
		}
	}
}

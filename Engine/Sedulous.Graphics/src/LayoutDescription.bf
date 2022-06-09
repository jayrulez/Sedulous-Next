using System;
using System.IO;
using System.Collections;

namespace Sedulous.Graphics
{
	/// <summary>
	/// A generic description of vertex inputs to the device's input assembler stage.
	/// This Object describes the inputs from a single vertex buffer.
	/// </summary>
	/// <remarks>Shaders may use inputs from multiple vertex buffers.</remarks>
	public class LayoutDescription : IEquatable<LayoutDescription>
	{
		/// <summary>
		/// The collection of individual vertex elements comprising a single vertex.
		/// </summary>
		public List<ElementDescription> Elements;

		/// <summary>
		/// The frequency with which the vertex function fetches attributes data.
		/// </summary>
		public VertexStepFunction StepFunction;

		/// <summary>
		/// A value controlling how often data for instances is advanced for this layout. For per-vertex elements, this value
		/// should be 0.
		/// </summary>
		public int32 StepRate;

		/// <summary>
		/// The total size of an individual vertex in bytes.
		/// </summary>
		public uint32 Stride;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.LayoutDescription" /> class.
		/// </summary>
		/// <param name="stepFunction">The frequency with which the vertex function fetches attributes data.</param>
		/// <param name="stepRate">The number of instances to draw using the same per-instance data before advancing in
		/// the buffer by one element. This value must be 0 for an element that contains per-vertex data.
		/// </param>
		public this(VertexStepFunction stepFunction = VertexStepFunction.PerVertexData, uint32 stepRate = 0u)
		{
			StepFunction = stepFunction;
			StepRate = (int32)stepRate;
			Stride = 0u;
			Elements = new List<ElementDescription>();
		}

		public ~this(){
			delete Elements;
		}

		/// <summary>
		/// Adds a new ElementDescription to layout.
		/// </summary>
		/// <param name="element">Element description.</param>
		/// <returns>My own instance.</returns>
		public LayoutDescription Add(ElementDescription element)
		{
			var element;

			if (element.Offset == -1)
			{
				element.Offset = (int32)Stride;
			}
			Elements.Add(element);
			Stride += GetFormatSizeInBytes(element.Format);
			return this;
		}

		/// <summary>
		/// Get the size in uint8 of a specific vertex element format.
		/// </summary>
		/// <param name="format">The vertex element formant.</param>
		/// <returns>The size in bytes.</returns>
		public static uint32 GetFormatSizeInBytes(ElementFormat format)
		{
			switch (format)
			{
			case ElementFormat.UByte: fallthrough;
			case ElementFormat.Byte: fallthrough;
			case ElementFormat.UByteNormalized: fallthrough;
			case ElementFormat.ByteNormalized:
				return 1u;
			case ElementFormat.UByte2: fallthrough;
			case ElementFormat.Byte2: fallthrough;
			case ElementFormat.UByte2Normalized: fallthrough;
			case ElementFormat.Byte2Normalized: fallthrough;
			case ElementFormat.UShort: fallthrough;
			case ElementFormat.Short: fallthrough;
			case ElementFormat.UShortNormalized: fallthrough;
			case ElementFormat.ShortNormalized:
				return 2u;
			case ElementFormat.UByte4: fallthrough;
			case ElementFormat.Byte4: fallthrough;
			case ElementFormat.UByte4Normalized: fallthrough;
			case ElementFormat.Byte4Normalized: fallthrough;
			case ElementFormat.UShort2: fallthrough;
			case ElementFormat.Short2: fallthrough;
			case ElementFormat.UShort2Normalized: fallthrough;
			case ElementFormat.Short2Normalized: fallthrough;
			case ElementFormat.Half2: fallthrough;
			case ElementFormat.Float: fallthrough;
			case ElementFormat.UInt: fallthrough;
			case ElementFormat.Int:
				return 4u;
			case ElementFormat.UShort4: fallthrough;
			case ElementFormat.Short4: fallthrough;
			case ElementFormat.UShort4Normalized: fallthrough;
			case ElementFormat.Short4Normalized: fallthrough;
			case ElementFormat.Half4: fallthrough;
			case ElementFormat.Float2:
				return 8u;
			case ElementFormat.Float3:
				return 12u;
			case ElementFormat.Float4:
				return 16u;
			default:
				Runtime.FatalError("VertexElementFormat doesn't supported.");
			}
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <param name="other">Other used to compare.</param>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public bool Equals(LayoutDescription other)
		{
			if ((Object)other == null)
			{
				return false;
			}
			if ((Object)this == other)
			{
				return true;
			}
			if (Elements == null || other.Elements == null)
			{
				return Elements == other.Elements;
			}
			if (Elements.Count != other.Elements.Count)
			{
				return false;
			}
			for (int32 i = 0; i < Elements.Count; i++)
			{
				if ((Object)Elements[i] != (Object)other.Elements[i])
				{
					return false;
				}
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
			int num = 19;
			for (int32 i = 0; i < Elements.Count; i++)
			{
				num = (num * 401) ^ Elements[i].GetHashCode();
			}
			return num;
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator ==(LayoutDescription value1, LayoutDescription value2)
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
		public static bool operator !=(LayoutDescription value1, LayoutDescription value2)
		{
			return !value1.Equals(value2);
		}
	}
}

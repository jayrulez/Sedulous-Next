using System;
using Sedulous.Foundation.Utilities;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This class represent a shader resource binding;.
	/// </summary>
	public struct LayoutElementDescription : IEquatable<LayoutElementDescription>
	{
		/// <summary>
		/// Gets the resource slot.
		/// </summary>
		public readonly uint32 Slot;

		/// <summary>
		/// Gets the shader resource type.
		/// </summary>
		public readonly ResourceType Type;

		/// <summary>
		/// Gets the resource shader stage.
		/// </summary>
		public readonly ShaderStages Stages;

		/// <summary>
		/// Gets a value indicating whether this resource allow dynamic offset. Its used in some graphics backend to allow specifying dynamic offset.
		/// </summary>
		public readonly bool AllowDynamicOffset;

		/// <summary>
		/// If it is greater than 0, it overrides the size of this resource (in bytes). Only valid on Constant Buffers.
		/// </summary>
		public readonly uint32 Range;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.LayoutElementDescription" /> struct.
		/// </summary>
		/// <param name="slot">The resource slot.</param>
		/// <param name="type">The resource type.</param>
		/// <param name="stages">The stages where this resource will be available.</param>
		/// <param name="allowDynamicOffset">Allow specifying dynamic offset. Only valid on Constant Buffers.</param>
		/// <param name="size">If it is greater than 0, it overrides the size of this resource (in bytes). Only valid on Constant Buffers.</param>
		public this(uint32 slot, ResourceType type, ShaderStages stages, bool allowDynamicOffset = false, uint32 size = 0u)
		{
			Slot = slot;
			Type = type;
			Stages = stages;
			AllowDynamicOffset = allowDynamicOffset;
			Range = size;
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <param name="other">Other used to compare.</param>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public bool Equals(LayoutElementDescription other)
		{
			if (Slot == other.Slot && Type == other.Type)
			{
				return Stages == other.Stages;
			}
			return false;
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public int GetHashCode()
		{
			int hash = (.)Slot;
			hash = HashHelper.CombineHash(hash, (.)Type);
			hash = HashHelper.CombineHash(hash, (.)Stages);
			hash = HashHelper.CombineHash(hash, AllowDynamicOffset ? 1 : 0);
			hash = HashHelper.CombineHash(hash, (.)Range);

			return hash;
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator ==(LayoutElementDescription value1, LayoutElementDescription value2)
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
		public static bool operator !=(LayoutElementDescription value1, LayoutElementDescription value2)
		{
			return !value1.Equals(value2);
		}
	}
}

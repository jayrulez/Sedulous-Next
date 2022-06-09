using System;
using System.Collections.Generic;
using System.IO;
using System.Collections;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This class represent contains the descriptions of vertex input layout.
	/// </summary>
	public class InputLayouts : IEquatable<InputLayouts>
	{
		private int32[] elementsCache;

		private bool isDirty = true;

		/// <summary>
		/// The vertex inputs elements.
		/// </summary>
		public List<LayoutDescription> LayoutElements;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.InputLayouts" /> class.
		/// </summary>
		public this()
		{
			LayoutElements = new List<LayoutDescription>();
		}

		public ~this(){
			delete LayoutElements;
		}

		/// <summary>
		/// Try get the attribute slot by semantic and semantic index.
		/// </summary>
		/// <param name="semantic">Attribute semantic type.</param>
		/// <param name="semanticIndex">Attribute semantic index.</param>
		/// <param name="slot">Attribute slot.</param>
		/// <returns>True whether found the attribute and False in otherwise.</returns>
		public bool TryGetSlot(ElementSemanticType semantic, uint32 semanticIndex, out uint32 slot)
		{
			slot = 0u;
			List<ElementDescription> elements = LayoutElements[0].Elements;
			for (int32 i = 0; i < elements.Count; i++)
			{
				ElementDescription elementDescription = elements[i];
				if (elementDescription.Semantic == semantic && elementDescription.SemanticIndex == semanticIndex)
				{
					slot = (uint32)i;
					return true;
				}
			}
			return false;
		}

		/// <summary>
		/// Finds an layout element description. by its usage semantic.
		/// </summary>
		/// <param name="semantic">The element semantic.</param>
		/// <param name="semanticIndex">The semantic index.</param>
		/// <param name="elementDescription">The element description.</param>
		/// <param name="vertexBufferIndex">The vertex buffer index.</param>
		/// <returns>True if the input layout contains an element with the specified semantic and index. False otherwise.</returns>
		public bool FindLayoutElementByUsage(ElementSemanticType semantic, int32 semanticIndex, out ElementDescription elementDescription, out int32 vertexBufferIndex)
		{
			for (int32 i = 0; i < LayoutElements.Count; i++)
			{
				LayoutDescription layoutDescription = LayoutElements[i];
				for (int32 j = 0; j < layoutDescription.Elements.Count; j++)
				{
					ElementDescription elementDescription2 = layoutDescription.Elements[j];
					if (elementDescription2.Semantic == semantic && elementDescription2.SemanticIndex == (.)semanticIndex)
					{
						elementDescription = elementDescription2;
						vertexBufferIndex = i;
						return true;
					}
				}
			}
			elementDescription = default(ElementDescription);
			vertexBufferIndex = 0;
			return false;
		}

		/// <summary>
		/// Adds a new layout.
		/// </summary>
		/// <param name="layout">Layout description.</param>
		/// <returns>My own instance.</returns>
		public InputLayouts Add(LayoutDescription layout)
		{
			if (layout != null)
			{
				LayoutElements.Add(layout);
			}
			isDirty = true;
			return this;
		}

		/// <summary>
		/// If the current layout is assignable to the parameter input layout.
		/// </summary>
		/// <param name="inputLayouts">The input layouts.</param>
		/// <returns>If the specified layout is compatible.</returns>
		public bool IsAssignable(InputLayouts inputLayouts)
		{
			UpdateCache();
			inputLayouts.UpdateCache();
			for (int32 i = 0; i < inputLayouts.elementsCache.Count; i++)
			{
				if (inputLayouts.elementsCache[i] > elementsCache[i])
				{
					return false;
				}
			}
			return true;
		}

		/// <summary>
		/// Clean Object.
		/// </summary>
		public void Clean()
		{
			LayoutElements.Clear();
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <param name="other">Other used to compare.</param>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public bool Equals(InputLayouts other)
		{
			if ((Object)other == null)
			{
				return false;
			}
			if ((Object)this == other)
			{
				return true;
			}
			if (LayoutElements == null || other.LayoutElements == null)
			{
				return LayoutElements == other.LayoutElements;
			}
			if (LayoutElements.Count != other.LayoutElements.Count)
			{
				return false;
			}
			for (int32 i = 0; i < LayoutElements.Count; i++)
			{
				if (LayoutElements[i] != other.LayoutElements[i])
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
			int num = 421;
			for (int32 i = 0; i < LayoutElements.Count; i++)
			{
				num = (num * 419) ^ LayoutElements[i].GetHashCode();
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
		public static bool operator ==(InputLayouts value1, InputLayouts value2)
		{
			if ((Object)value1 == value2)
			{
				return true;
			}
			return value1?.Equals(value2) ?? false;
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator !=(InputLayouts value1, InputLayouts value2)
		{
			return !(value1 == value2);
		}

		private void UpdateCache()
		{
			if (!isDirty)
			{
				return;
			}
			elementsCache = new int32[8];
			for (int32 i = 0; i < elementsCache.Count; i++)
			{
				elementsCache[i] = -1;
			}
			for (int32 j = 0; j < LayoutElements.Count; j++)
			{
				LayoutDescription layoutDescription = LayoutElements[j];
				for (int32 k = 0; k < layoutDescription.Elements.Count; k++)
				{
					ElementDescription elementDescription = layoutDescription.Elements[k];
					int32 semantic = (int32)elementDescription.Semantic;
					elementsCache[semantic] = Math.Max(elementsCache[semantic], (int32)elementDescription.SemanticIndex);
				}
			}
			isDirty = false;
		}
	}
}

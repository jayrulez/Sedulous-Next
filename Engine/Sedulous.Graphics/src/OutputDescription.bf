using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Contains properties that describe the characteristics of a new pipeline state Object.
	/// </summary>
	public struct OutputDescription : IEquatable<OutputDescription>
	{
		/// <summary>
		/// A description of the depth attachment, or null if none exists.
		/// </summary>
		public readonly OutputAttachmentDescription? DepthAttachment;

		/// <summary>
		/// An array of attachment descriptions, one for each color attachment.
		/// </summary>
		public readonly Span<OutputAttachmentDescription> ColorAttachments;

		/// <summary>
		/// Gets the number of view counts.
		/// </summary>
		public readonly uint32 ArraySliceCount;

		/// <summary>
		/// The number of samples in each target attachment.
		/// </summary>
		public readonly TextureSampleCount SampleCount;

		/// <summary>
		/// Precomputed outputDescription hash. Used to speed up the comparison between output descriptions.
		/// </summary>
		public readonly int CachedHashCode;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.OutputDescription" /> struct.
		/// </summary>
		/// <param name="depth">A description of the depth attachment.</param>
		/// <param name="colors">An array of descriptions of each color attachment.</param>
		/// <param name="sampleCount">The number of samples in each target attachment.</param>
		/// <param name="arraySliceCount">The number of views rendered.</param>
		public this(OutputAttachmentDescription? depth, OutputAttachmentDescription[] colors, TextureSampleCount sampleCount, uint32 arraySliceCount)
		{
			DepthAttachment = depth;
			ColorAttachments = colors ?? Span<OutputAttachmentDescription>();
			SampleCount = sampleCount;
			ArraySliceCount = arraySliceCount;
			int hashCode = DepthAttachment.GetValueOrDefault().GetHashCode();
			for (int i = 0; i < ColorAttachments.Length; i++)
			{
				hashCode = (hashCode * 397) ^ ColorAttachments[i].GetHashCode();
			}
			CachedHashCode = (hashCode * 397) ^ (int)SampleCount;
			CachedHashCode = (hashCode * 397) ^ (int)ArraySliceCount;
		}

		/// <summary>
		/// Create a new instance of <see cref="T:Sedulous.Graphics.OutputDescription" /> from a <see cref="T:Sedulous.Graphics.FrameBuffer" />.
		/// </summary>
		/// <param name="frameBuffer">The framebuffer to extract the attachment description.</param>
		/// <returns>A new instance of OutputDescription.</returns>
		public static OutputDescription CreateFromFrameBuffer(FrameBuffer frameBuffer, out OutputAttachmentDescription[] colorAttachments)
		{
			TextureSampleCount sampleCount = TextureSampleCount.None;
			OutputAttachmentDescription? depth = null;
			uint32 arraySliceCount = 1;
			if (frameBuffer.DepthStencilTarget.HasValue)
			{
				FrameBufferAttachment value = frameBuffer.DepthStencilTarget.Value;
				TextureDescription description = value.AttachmentTexture.Description;
				depth = OutputAttachmentDescription(description.Format, value.ResolvedTexture != null);
				sampleCount = description.SampleCount;
			}
			colorAttachments = null;
			if (frameBuffer.ColorTargets != null)
			{
				colorAttachments = new OutputAttachmentDescription[frameBuffer.ColorTargets.Count];
				for (int32 i = 0; i < colorAttachments.Count; i++)
				{
					ref FrameBufferAttachment reference = ref frameBuffer.ColorTargets[i];
					TextureDescription description2 = reference.AttachmentTexture.Description;
					colorAttachments[i] = OutputAttachmentDescription(description2.Format, reference.ResolvedTexture != null);
					sampleCount = description2.SampleCount;
					arraySliceCount = reference.SliceCount;
				}
			}
			return OutputDescription(depth, colorAttachments, sampleCount, arraySliceCount);
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <param name="other">Other used to compare.</param>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public bool Equals(OutputDescription other)
		{
			return CachedHashCode == other.CachedHashCode;
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public int GetHashCode()
		{
			return CachedHashCode;
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator ==(OutputDescription value1, OutputDescription value2)
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
		public static bool operator !=(OutputDescription value1, OutputDescription value2)
		{
			return !value1.Equals(value2);
		}

		private bool ArrayEqualsEquatable<T>(T[] left, T[] right) where T : struct, IEquatable<T>
		{
			if (left == null || right == null)
			{
				return left == right;
			}
			if (left.Count != right.Count)
			{
				return false;
			}
			for (int32 i = 0; i < left.Count; i++)
			{
				if (!left[i].Equals(right[i]))
				{
					return false;
				}
			}
			return true;
		}
	}
}

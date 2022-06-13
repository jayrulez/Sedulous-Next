using System;
using System.Diagnostics;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

	public static{
		public const uint32 MaxOutputAttachments = 32;
	}

	/// <summary>
	/// Describes a set of output attachments and their formats.
	/// </summary>
	public struct OutputDescription : IEquatable<OutputDescription>, IHashable
	{
		/// <summary>
		/// A description of the depth attachment, or null if none exists.
		/// </summary>
		public OutputAttachmentDescription? DepthAttachment;
		/// <summary>
		/// An array of attachment descriptions, one for each color attachment. May be empty.
		/// </summary>
		public Span<OutputAttachmentDescription> ColorAttachments =>  Span<OutputAttachmentDescription>(&_colorAttachments, _usedAttachments);
		private OutputAttachmentDescription[MaxOutputAttachments] _colorAttachments = .();
		private uint32 _usedAttachments = 0;
		/// <summary>
		/// The number of samples in each target attachment.
		/// </summary>
		public TextureSampleCount SampleCount;

		/// <summary>
		/// Constructs a new <see cref="OutputDescription"/>.
		/// </summary>
		/// <param name="depthAttachment">A description of the depth attachment.</param>
		/// <param name="colorAttachments">An array of descriptions of each color attachment.</param>
		public this(OutputAttachmentDescription? depthAttachment, params OutputAttachmentDescription[] colorAttachments)
		{
			Runtime.Assert(colorAttachments.Count <= MaxOutputAttachments);

			DepthAttachment = depthAttachment;
			if (colorAttachments != null)
			{
				for (int i = 0; i < colorAttachments.Count; i++)
				{
					_colorAttachments[i] = colorAttachments[i];
					_usedAttachments++;
				}
			}
			SampleCount = TextureSampleCount.Count1;
			//ColorAttachments = Span<OutputAttachmentDescription>(&_colorAttachments, _usedAttachments);
		}

		/// <summary>
		/// Constructs a new <see cref="OutputDescription"/>.
		/// </summary>
		/// <param name="depthAttachment">A description of the depth attachment.</param>
		/// <param name="colorAttachments">An array of descriptions of each color attachment.</param>
		/// <param name="sampleCount">The number of samples in each target attachment.</param>
		public this(
			OutputAttachmentDescription? depthAttachment,
			OutputAttachmentDescription[] colorAttachments,
			TextureSampleCount sampleCount)
		{
			DepthAttachment = depthAttachment;
			if (colorAttachments == null)
			{
				for (int i = 0; i < colorAttachments.Count; i++)
				{
					_colorAttachments[i] = colorAttachments[i];
					_usedAttachments++;
				}
			}
			SampleCount = sampleCount;
			//ColorAttachments = Span<OutputAttachmentDescription>(&_colorAttachments, _usedAttachments);
		}

		internal static OutputDescription CreateFromFramebuffer(Framebuffer fb)
		{
			TextureSampleCount sampleCount = 0;
			OutputAttachmentDescription? depthAttachment = null;
			if (fb.DepthTarget != null)
			{
				depthAttachment = OutputAttachmentDescription(fb.DepthTarget.Value.Target.Format);
				sampleCount = fb.DepthTarget.Value.Target.SampleCount;
			}
			OutputAttachmentDescription[] colorAttachments = scope OutputAttachmentDescription[fb.ColorTargets.Length];
			for (int i = 0; i < colorAttachments.Count; i++)
			{
				colorAttachments[i] = OutputAttachmentDescription(fb.ColorTargets[i].Target.Format);
				sampleCount = fb.ColorTargets[i].Target.SampleCount;
			}

			return OutputDescription(depthAttachment, colorAttachments, sampleCount);
		}

		/// <summary>
		/// Element-wise equality.
		/// </summary>
		/// <param name="other">The instance to compare to.</param>
		/// <returns>True if all elements and all array elements are equal; false otherswise.</returns>
		public bool Equals(OutputDescription other)
		{
			if(ColorAttachments.Length != other.ColorAttachments.Length)
				return false;

			for(int i = 0; i < ColorAttachments.Length; i++){
				if(ColorAttachments[i] != other.ColorAttachments[i]){
					return false;
				}
			}

			return DepthAttachment.GetValueOrDefault().Equals(other.DepthAttachment.GetValueOrDefault())
				&& SampleCount == other.SampleCount;
		}

		/// <summary>
		/// Returns the hash code for this instance.
		/// </summary>
		/// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
		public int GetHashCode()
		{
			int hash = DepthAttachment.GetHashCode();
			for(int i = 0; i < ColorAttachments.Length; i++){
				hash = HashHelper.Combine(hash, ColorAttachments[i].GetHashCode());
			}
			return HashHelper.Combine(
				hash,
				(int)SampleCount);
		}
	}
}

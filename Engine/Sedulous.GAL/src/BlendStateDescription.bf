using System;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

	/// <summary>
	/// A <see cref="Pipeline"/> component describing how values are blended into each individual color target.
	/// </summary>
	public struct BlendStateDescription : IEquatable<BlendStateDescription>, IHashable
	{
		/// <summary>
		/// A constant blend color used in <see cref="BlendFactor.BlendFactor"/> and <see cref="BlendFactor.InverseBlendFactor"/>,
		/// or otherwise ignored.
		/// </summary>
		public RgbaFloat BlendFactor;
		/// <summary>
		/// An array of <see cref="BlendAttachmentDescription"/> describing how blending is performed for each color target
		/// used in the <see cref="Pipeline"/>.
		/// </summary>
		public readonly Span<BlendAttachmentDescription> AttachmentStates = .();
		private BlendAttachmentDescription[MaxOutputAttachments] _attachmentStates = .();
		private int _usedAttachments = 0;
		/// <summary>
		/// Enables alpha-to-coverage, which causes a fragment's alpha value to be used when determining multi-sample coverage.
		/// </summary>
		public bool AlphaToCoverageEnabled;

		/// <summary>
		/// Constructs a new <see cref="BlendStateDescription"/>,
		/// </summary>
		/// <param name="blendFactor">The constant blend color.</param>
		/// <param name="attachmentStates">The blend attachment states.</param>
		public this(RgbaFloat blendFactor, params BlendAttachmentDescription[] attachmentStates)
		{
			Runtime.Assert(attachmentStates.Count <= MaxOutputAttachments);

			BlendFactor = blendFactor;
			for (int i = 0; i < attachmentStates.Count; i++)
			{
				AttachmentStates[i] = attachmentStates[i];
				_usedAttachments++;
			}
			AlphaToCoverageEnabled = false;
			AttachmentStates = Span<BlendAttachmentDescription>(&_attachmentStates, _usedAttachments);
		}

		/// <summary>
		/// Constructs a new <see cref="BlendStateDescription"/>,
		/// </summary>
		/// <param name="blendFactor">The constant blend color.</param>
		/// <param name="alphaToCoverageEnabled">Enables alpha-to-coverage, which causes a fragment's alpha value to be
		/// used when determining multi-sample coverage.</param>
		/// <param name="attachmentStates">The blend attachment states.</param>
		public this(
			RgbaFloat blendFactor,
			bool alphaToCoverageEnabled,
			params BlendAttachmentDescription[] attachmentStates)
		{
			Runtime.Assert(attachmentStates.Count <= MaxOutputAttachments);
			BlendFactor = blendFactor;
			for (int i = 0; i < attachmentStates.Count; i++)
			{
				AttachmentStates[i] = attachmentStates[i];
				_usedAttachments++;
			}
			AlphaToCoverageEnabled = alphaToCoverageEnabled;
			AttachmentStates = Span<BlendAttachmentDescription>(&_attachmentStates, _usedAttachments);
		}

		public this()
		{
			BlendFactor = default;
			AlphaToCoverageEnabled = default;
			AttachmentStates = Span<BlendAttachmentDescription>(&_attachmentStates, 0);
		}

		public static this()
		{
			Empty = BlendStateDescription();

			SingleOverrideBlend = BlendStateDescription();
			SingleOverrideBlend._attachmentStates[0] = BlendAttachmentDescription.OverrideBlend;

			SingleAlphaBlend = BlendStateDescription();
			SingleAlphaBlend._attachmentStates[0] = BlendAttachmentDescription.AlphaBlend;

			SingleAdditiveBlend = BlendStateDescription();
			SingleAdditiveBlend._attachmentStates[0] = BlendAttachmentDescription.AdditiveBlend;

			SingleDisabled = BlendStateDescription();
			SingleDisabled._attachmentStates[0] = BlendAttachmentDescription.Disabled;
		}

		/// <summary>
		/// Describes a blend state in which a single color target is blended with <see cref="BlendAttachmentDescription.OverrideBlend"/>.
		/// </summary>
		public static readonly BlendStateDescription SingleOverrideBlend;

		/// <summary>
		/// Describes a blend state in which a single color target is blended with <see cref="BlendAttachmentDescription.AlphaBlend"/>.
		/// </summary>
		public static readonly BlendStateDescription SingleAlphaBlend;

		/// <summary>
		/// Describes a blend state in which a single color target is blended with <see cref="BlendAttachmentDescription.AdditiveBlend"/>.
		/// </summary>
		public static readonly BlendStateDescription SingleAdditiveBlend;

		/// <summary>
		/// Describes a blend state in which a single color target is blended with <see cref="BlendAttachmentDescription.Disabled"/>.
		/// </summary>
		public static readonly BlendStateDescription SingleDisabled;

		/// <summary>
		/// Describes an empty blend state in which no color targets are used.
		/// </summary>
		public static readonly BlendStateDescription Empty;

		/// <summary>
		/// Element-wise equality.
		/// </summary>
		/// <param name="other">The instance to compare to.</param>
		/// <returns>True if all elements and all array elements are equal; false otherswise.</returns>
		public bool Equals(BlendStateDescription other)
		{
			if (AttachmentStates.Length != other.AttachmentStates.Length)
				return false;

			for (int i = 0; i < AttachmentStates.Length; i++)
			{
				if (AttachmentStates[i] != other.AttachmentStates[i])
					return false;
			}

			return BlendFactor.Equals(other.BlendFactor)
				&& AlphaToCoverageEnabled == other.AlphaToCoverageEnabled;
		}

		/// <summary>
		/// Returns the hash code for this instance.
		/// </summary>
		/// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
		public int GetHashCode()
		{
			int hash =  HashHelper.Combine(
				BlendFactor.GetHashCode(),
				AlphaToCoverageEnabled.GetHashCode());
			for (int i = 0; i < AttachmentStates.Length; i++)
			{
				hash = HashHelper.Combine(hash, AttachmentStates[i].GetHashCode());
			}

			return hash;
		}

		internal BlendStateDescription ShallowClone()
		{
			BlendStateDescription result = this;
			//result.AttachmentStates = Util.ShallowClone(result.AttachmentStates, .. ?);
			return result;
		}
	}
}

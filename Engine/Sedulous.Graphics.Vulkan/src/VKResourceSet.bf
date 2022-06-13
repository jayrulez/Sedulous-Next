using System;
using Bulkan;
using Sedulous.Graphics;
using System.Collections;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	using static Sedulous.Graphics.Vulkan.VKHelpers;
	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;

	/// <summary>
	/// The Vulkan implementation of a ResourceSet Object.
	/// </summary>
	public class VKResourceSet : ResourceSet
	{
		/// <summary>
		/// The Vulkan descriptor allocation token.
		/// </summary>
		public readonly VKDescriptorAllocationToken DescriptorAllocationToken;

		/// <summary>
		/// The number of dynamic buffers.
		/// </summary>
		public readonly uint32 DynamicBufferCount;

		/// <summary>
		/// Storage textures (RWTexture) list.
		/// </summary>
		internal List<VKTexture> StorageTextures;

		/// <summary>
		/// Normal Textures (Texture) list.
		/// </summary>
		internal List<VKTexture> Textures;

		private readonly VKResourceCounts descriptorCounts;

		private VKGraphicsContext vkContext;

		private bool disposed;

		private String name;

		/// <inheritdoc />
		public override String Name
		{
			get
			{
				return name;
			}
			set
			{
				name = value;
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_DESCRIPTOR_SET, DescriptorAllocationToken.DescriptorSet.Handle, name);
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKResourceSet" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The resourceSet description.</param>
		public  this(VKGraphicsContext context, ref ResourceSetDescription description)
			: base(ref description)
		{
			vkContext = context;
			VKResourceLayout vKResourceLayout = description.Layout as VKResourceLayout;
			descriptorCounts = vKResourceLayout.ResourceCounts;
			DescriptorAllocationToken = vkContext.DescriptorPool.Allocate(vKResourceLayout.DescriptorSetLayout, vKResourceLayout.ResourceCounts);
			StorageTextures = new List<VKTexture>();
			Textures = new List<VKTexture>();
			uint32 num = (uint32)description.Resources.Count;
			VkWriteDescriptorSet* ptr = scope VkWriteDescriptorSet[(int32)num]*;
			VkDescriptorBufferInfo* ptr2 = scope VkDescriptorBufferInfo[(int32)num]*;
			VkDescriptorImageInfo* ptr3 = scope VkDescriptorImageInfo[(int32)num]*;
			VkWriteDescriptorSetAccelerationStructureKHR* ptr4 = scope VkWriteDescriptorSetAccelerationStructureKHR[(int32)num]*;
			DynamicBufferCount = 0u;
			VkWriteDescriptorSet* ptr5 = ptr;
			VkDescriptorImageInfo* ptr6 = ptr3;
			uint32 num2 = 0u;
			for (uint32 num3 = 0u; num3 < num; num3++)
			{
				bool flag = true;
				LayoutElementDescription element = vKResourceLayout.Description.Elements[num3];
				VkDescriptorType vkDescriptorType = element.Type.ToVulkan(element.AllowDynamicOffset);
				switch (vkDescriptorType)
				{
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER: fallthrough;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER: fallthrough;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC: fallthrough;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC:
				{
					VkDescriptorBufferInfo* ptr7 = ptr2 + num3;
					VKBuffer vKBuffer = description.Resources[num3] as VKBuffer;
					flag = vKBuffer != null;
					if (flag)
					{
						ptr7.buffer = vKBuffer.NativeBuffer;
						ptr7.range = ((element.Range == 0) ? uint64.MaxValue : ((uint64)element.Range));
						ptr5.pBufferInfo = ptr7;
						if (element.AllowDynamicOffset)
						{
							DynamicBufferCount++;
						}
					}
					break;
				}
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE:
				{
					VKTexture vKTexture = description.Resources[num3] as VKTexture;
					flag = vKTexture != null;
					if (flag)
					{
						ptr6.imageView = vKTexture.ImageView;
						ptr6.sampler = VkSampler.Null;
						ptr6.imageLayout = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
						ptr5.pImageInfo = ptr6;
						Textures.Add(vKTexture);
					}
					break;
				}
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE:
				{
					VKTexture vKTexture2 = description.Resources[num3] as VKTexture;
					flag = vKTexture2 != null;
					if (flag)
					{
						ptr6.imageView = vKTexture2.ImageView;
						ptr6.imageLayout = VkImageLayout.VK_IMAGE_LAYOUT_GENERAL;
						ptr5.pImageInfo = ptr6;
						StorageTextures.Add(vKTexture2);
					}
					break;
				}
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER:
				{
					VKSamplerState vKSamplerState = (description.Resources[num3] as VKSamplerState) ?? (context.DefaultSampler as VKSamplerState);
					flag = vKSamplerState != null;
					if (flag)
					{
						ptr6.imageView = VkImageView.Null;
						ptr6.sampler = vKSamplerState.NativeSampler;
						ptr5.pImageInfo = ptr6;
					}
					break;
				}
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR:
				{
					VkWriteDescriptorSetAccelerationStructureKHR vkWriteDescriptorSetAccelerationStructureKHR = ptr4[num3];
					VKTopLevelAS vKTopLevelAS = description.Resources[num3] as VKTopLevelAS;
					flag = vKTopLevelAS != null;
					if (flag)
					{
						vkWriteDescriptorSetAccelerationStructureKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_KHR;
						vkWriteDescriptorSetAccelerationStructureKHR.accelerationStructureCount = 1u;
						VkAccelerationStructureKHR topLevelAS = vKTopLevelAS.TopLevelAS;
						vkWriteDescriptorSetAccelerationStructureKHR.pAccelerationStructures = &topLevelAS;
						ptr5.pNext = &vkWriteDescriptorSetAccelerationStructureKHR;
					}
					break;
				}
				default: break;
				}
				if (flag)
				{
					uint32 binding = VKHelpers.GetBinding(element);
					ptr5.sType = VkStructureType.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
					ptr5.descriptorCount = 1u;
					ptr5.descriptorType = vkDescriptorType;
					ptr5.dstBinding = binding;
					ptr5.dstSet = DescriptorAllocationToken.DescriptorSet;
					ptr5++;
					ptr6++;
					num2++;
				}
			}
			VulkanNative.vkUpdateDescriptorSets(vkContext.VkDevice, num2, ptr, 0u, null);
		}

		/// <inheritdoc />
		public override void Dispose()
		{
			Dispose(/*disposing:*/ true);
			/*GC.SuppressFinalize(this);*/
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
		private void Dispose(bool disposing)
		{
			if (!disposed)
			{
				if (disposing)
				{
					vkContext.DescriptorPool.Free(DescriptorAllocationToken, descriptorCounts);
				}
				disposed = true;
			}
		}
	}
}

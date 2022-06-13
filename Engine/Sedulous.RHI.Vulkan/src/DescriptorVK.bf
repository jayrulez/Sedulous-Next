using Bulkan;
using System;
using static Bulkan.VulkanNative;
using static Sedulous.RHI.Vulkan.VulkanUtils;
namespace Sedulous.RHI.Vulkan
{
	enum DescriptorTypeVK
	{
		NONE = 0,
		BUFFER_VIEW,
		IMAGE_VIEW,
		SAMPLER,
		ACCELERATION_STRUCTURE
	}

	struct DescriptorBufferDesc
	{
		public VkBuffer[PHYSICAL_DEVICE_GROUP_MAX_SIZE] handles = .();
		public uint64 offset;
		public uint64 size;
	}

	struct DescriptorTextureDesc
	{
		public VkImage[PHYSICAL_DEVICE_GROUP_MAX_SIZE] handles;
		public TextureVK texture;
		public VkImageLayout imageLayout;
		public uint32 imageMipOffset;
		public uint32 imageMipNum;
		public uint32 imageArrayOffset;
		public uint32 imageArraySize;
		public VkImageAspectFlags imageAspectFlags;
	}

	public static
	{
		public static void FillTextureDesc<T>(in T textureViewDesc, ref DescriptorTextureDesc descriptorTextureDesc) where T : var
		{
			readonly TextureVK texture = (TextureVK)textureViewDesc.texture;

			descriptorTextureDesc.texture = texture;
			descriptorTextureDesc.imageAspectFlags = texture.GetImageAspectFlags();
			descriptorTextureDesc.imageMipOffset = textureViewDesc.mipOffset;
			descriptorTextureDesc.imageMipNum = textureViewDesc.mipNum;
			descriptorTextureDesc.imageArrayOffset = textureViewDesc.arrayOffset;
			descriptorTextureDesc.imageArraySize = textureViewDesc.arraySize;
			descriptorTextureDesc.imageLayout = VulkanUtils.GetImageLayoutForView(textureViewDesc.viewType);
		}

		public static void FillTextureDesc(in Texture3DViewDesc textureViewDesc, ref DescriptorTextureDesc descriptorTextureDesc)
		{
			readonly TextureVK texture = (TextureVK)textureViewDesc.texture;

			descriptorTextureDesc.texture = texture;
			descriptorTextureDesc.imageAspectFlags = texture.GetImageAspectFlags();
			descriptorTextureDesc.imageMipOffset = textureViewDesc.mipOffset;
			descriptorTextureDesc.imageMipNum = textureViewDesc.mipNum;
			descriptorTextureDesc.imageArrayOffset = 0;
			descriptorTextureDesc.imageArraySize = 1;
			descriptorTextureDesc.imageLayout = VulkanUtils.GetImageLayoutForView(textureViewDesc.viewType);
		}

		public static void FillImageSubresourceRange<T>(in T textureViewDesc, ref VkImageSubresourceRange subresourceRange) where T : var
		{
			readonly TextureVK texture = (TextureVK)textureViewDesc.texture;

			subresourceRange = .()
				{
					aspectMask = texture.GetImageAspectFlags(),
					baseMipLevel = textureViewDesc.mipOffset,
					levelCount = (textureViewDesc.mipNum == REMAINING_MIP_LEVELS) ? VulkanNative.VK_REMAINING_MIP_LEVELS : textureViewDesc.mipNum,
					baseArrayLayer = textureViewDesc.arrayOffset,
					layerCount = (textureViewDesc.arraySize == REMAINING_ARRAY_LAYERS) ? VulkanNative.VK_REMAINING_ARRAY_LAYERS : textureViewDesc.arraySize
				};
		}

		public static void FillImageSubresourceRange(in Texture3DViewDesc textureViewDesc, ref VkImageSubresourceRange subresourceRange)
		{
			readonly TextureVK texture = (TextureVK)textureViewDesc.texture;

			subresourceRange = .()
				{
					aspectMask = texture.GetImageAspectFlags(),
					baseMipLevel = textureViewDesc.mipOffset,
					levelCount = (textureViewDesc.mipNum == REMAINING_MIP_LEVELS) ? VulkanNative.VK_REMAINING_MIP_LEVELS : textureViewDesc.mipNum,
					baseArrayLayer = 0,
					layerCount = 1
				};
		}
	}

	class DescriptorVK : Descriptor
	{
		[Union]
		struct Resource
		{
			public VkBufferView[PHYSICAL_DEVICE_GROUP_MAX_SIZE] BufferViews;
			public VkImageView[PHYSICAL_DEVICE_GROUP_MAX_SIZE] ImageViews;
			public VkAccelerationStructureKHR[PHYSICAL_DEVICE_GROUP_MAX_SIZE] AccelerationStructures;
			public VkSampler Sampler;
		};
		private Resource m_Resource;

		private ref VkBufferView[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_BufferViews => ref m_Resource.BufferViews;
		private ref VkImageView[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_ImageViews => ref m_Resource.ImageViews;
		private ref VkAccelerationStructureKHR[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_AccelerationStructures => ref m_Resource.AccelerationStructures;
		private ref VkSampler m_Sampler => ref m_Resource.Sampler;

		[Union]
		struct Description
		{
			public DescriptorBufferDesc BufferDesc;
			public DescriptorTextureDesc TextureDesc;
		}
		private Description m_Desc;

		private ref DescriptorBufferDesc m_BufferDesc => ref m_Desc.BufferDesc;
		private ref DescriptorTextureDesc m_TextureDesc => ref m_Desc.TextureDesc;
		private DescriptorTypeVK m_Type = DescriptorTypeVK.NONE;
		private VkFormat m_Format = .VK_FORMAT_UNDEFINED;
		private VkExtent3D m_Extent = .();
		DeviceVK m_Device;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////

		/////////////////////////////Internal Methods//////////////////////////////
		public readonly ref DeviceVK GetDevice() => ref m_Device;

		public Result Create(in BufferViewDesc bufferViewDesc)
		{
			readonly BufferVK buffer = (BufferVK)bufferViewDesc.buffer;

			m_Type = DescriptorTypeVK.BUFFER_VIEW;
			m_Format = .GetVkFormat((Format)bufferViewDesc.format);
			m_BufferDesc.offset = bufferViewDesc.offset;
			m_BufferDesc.size = (bufferViewDesc.size == WHOLE_SIZE) ? VK_WHOLE_SIZE : bufferViewDesc.size;

			readonly uint32 physicalDeviceMask = GetPhysicalDeviceGroupMask(bufferViewDesc.physicalDeviceMask);

			for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
			{
				if ((1 << i) & physicalDeviceMask != 0)
					m_BufferDesc.handles[i] = buffer.GetHandle(i);
			}

			if (bufferViewDesc.format == Format.UNKNOWN)
				return Result.SUCCESS;

			VkBufferViewCreateInfo info = .()
				{
					sType = .VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO,
					pNext = null,
					flags = (VkBufferViewCreateFlags)0,
					buffer = .Null,
					format = m_Format,
					offset = bufferViewDesc.offset,
					range = m_BufferDesc.size
				};

			for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
			{
				if ((1 << i) & physicalDeviceMask != 0)
				{
					info.buffer = buffer.GetHandle(i);

					readonly VkResult result = vkCreateBufferView(m_Device, &info, m_Device.GetAllocationCallbacks(), &m_BufferViews[i]);

					RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
						"Can't create a buffer view: vkCreateBufferView returned {0}.", (int32)result);
				}
			}

			return Result.SUCCESS;
		}

		public Result Create(in Texture1DViewDesc textureViewDesc)
		{
			return CreateTextureView(textureViewDesc);
		}

		public Result Create(in Texture2DViewDesc textureViewDesc)
		{
			return CreateTextureView(textureViewDesc);
		}

		public Result Create(in Texture3DViewDesc textureViewDesc)
		{
			return CreateTextureView(textureViewDesc);
		}

		public Result Create(in SamplerDesc samplerDesc)
		{
			m_Type = DescriptorTypeVK.SAMPLER;

			VkSamplerCreateInfo samplerInfo = .()
				{
					sType = .VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
					pNext = null,
					flags = (VkSamplerCreateFlags)0,
					magFilter = VulkanUtils.GetFilter(samplerDesc.magnification),
					minFilter = VulkanUtils.GetFilter(samplerDesc.minification),
					mipmapMode = VulkanUtils.GetSamplerMipmapMode(samplerDesc.minification),
					addressModeU = VulkanUtils.GetSamplerAddressMode(samplerDesc.addressModes.u),
					addressModeV = VulkanUtils.GetSamplerAddressMode(samplerDesc.addressModes.v),
					addressModeW = VulkanUtils.GetSamplerAddressMode(samplerDesc.addressModes.w),
					mipLodBias = samplerDesc.mipBias,
					anisotropyEnable = VkBool32(samplerDesc.anisotropy > 1.0f),
					maxAnisotropy = (float)samplerDesc.anisotropy,
					compareEnable = VkBool32(samplerDesc.compareFunc != CompareFunc.NONE),
					compareOp = VulkanUtils.GetCompareOp(samplerDesc.compareFunc),
					minLod = samplerDesc.mipMin,
					maxLod = samplerDesc.mipMax,
					borderColor = .VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK,
					unnormalizedCoordinates = VkBool32(samplerDesc.unnormalizedCoordinates)
				};

			readonly VkResult result = vkCreateSampler(m_Device, &samplerInfo, m_Device.GetAllocationCallbacks(), &m_Sampler);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a sampler: vkCreateSampler returned {0}.", (int32)result);

			return Result.SUCCESS;
		}

		public Result Create(in VkAccelerationStructureKHR* accelerationStructures, uint32 physicalDeviceMask)
		{
			var physicalDeviceMask;
			m_Type = DescriptorTypeVK.ACCELERATION_STRUCTURE;

			physicalDeviceMask = GetPhysicalDeviceGroupMask(physicalDeviceMask);

			for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
			{
				if ((1 << i) & physicalDeviceMask != 0)
					m_AccelerationStructures[i] = accelerationStructures[i];
			}

			return Result.SUCCESS;
		}

		public VkBufferView GetBufferView(uint32 physicalDeviceIndex) => m_BufferViews[physicalDeviceIndex];

		public VkImageView GetImageView(uint32 physicalDeviceIndex) => m_ImageViews[physicalDeviceIndex];

		public readonly ref VkSampler GetSampler() => ref m_Sampler;

		public VkAccelerationStructureKHR GetAccelerationStructure(uint32 physicalDeviceIndex) => m_AccelerationStructures[physicalDeviceIndex];

		public VkBuffer GetBuffer(uint32 physicalDeviceIndex) => m_BufferDesc.handles[physicalDeviceIndex];

		public VkImage GetImage(uint32 physicalDeviceIndex) => m_TextureDesc.handles[physicalDeviceIndex];

		public void GetBufferInfo(uint32 physicalDeviceIndex, ref VkDescriptorBufferInfo info)
		{
			info.buffer = m_BufferDesc.handles[physicalDeviceIndex];
			info.offset = m_BufferDesc.offset;
			info.range = m_BufferDesc.size;
		}

		public readonly ref TextureVK GetTexture() => ref m_TextureDesc.texture;

		public DescriptorTypeVK GetDescriptorType() => m_Type;

		public VkExtent3D GetExtent() => m_Extent;

		public VkFormat GetFormat() => m_Format;

		public void GetImageSubresourceRange(ref VkImageSubresourceRange range)
		{
			range.aspectMask = m_TextureDesc.imageAspectFlags;
			range.baseMipLevel = m_TextureDesc.imageMipOffset;
			range.levelCount = m_TextureDesc.imageMipNum;
			range.baseArrayLayer = m_TextureDesc.imageArrayOffset;
			range.layerCount = m_TextureDesc.imageArraySize;
		}

		public VkImageLayout GetImageLayout() => m_TextureDesc.imageLayout;

		public Result CreateTextureView<T>(in T textureViewDesc) where T : var
		{
			readonly TextureVK texture = (TextureVK)textureViewDesc.texture;

			VkImageViewUsageCreateInfo imageViewUsageCreateInfo = .() { };
			imageViewUsageCreateInfo.sType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_USAGE_CREATE_INFO;
			imageViewUsageCreateInfo.usage = GetImageViewUsage(textureViewDesc.viewType);

			m_Type = DescriptorTypeVK.IMAGE_VIEW;
			m_Format = .GetVkImageViewFormat(textureViewDesc.format);
			m_Extent = texture.GetExtent();
			FillTextureDesc(textureViewDesc, ref m_TextureDesc);

			VkImageSubresourceRange subresource = .();
			FillImageSubresourceRange(textureViewDesc, ref subresource);

			VkImageViewCreateInfo imageViewCreateInfo = .() { };
			imageViewCreateInfo.sType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
			imageViewCreateInfo.pNext = &imageViewUsageCreateInfo;
			imageViewCreateInfo.viewType = GetImageViewType(textureViewDesc.viewType);
			imageViewCreateInfo.format = m_Format;
			imageViewCreateInfo.subresourceRange = subresource;

			readonly uint32 physicalDeviceMask = GetPhysicalDeviceGroupMask(textureViewDesc.physicalDeviceMask);

			for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
			{
				if ((1 << i) & physicalDeviceMask != 0)
				{
					m_TextureDesc.handles[i] = texture.GetHandle(i);
					imageViewCreateInfo.image = texture.GetHandle(i);

					readonly VkResult result = vkCreateImageView(m_Device, &imageViewCreateInfo, m_Device.GetAllocationCallbacks(), &m_ImageViews[i]);

					RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
						"Can't create a texture view: vkCreateImageView returned {0}.", (int32)result);
				}
			}

			return Result.SUCCESS;
		}

		public VkBufferView GetBufferDescriptorVK(uint32 physicalDeviceIndex)
		{
			return m_BufferViews[physicalDeviceIndex];
		}

		public VkImageView GetTextureDescriptorVK(uint32 physicalDeviceIndex, ref VkImageSubresourceRange subresourceRange)
		{
			GetImageSubresourceRange(ref subresourceRange);
			return m_ImageViews[physicalDeviceIndex];
		}
		///////////////////////////////////////////////////////////////////////////


		public this(DeviceVK device)
		{
			m_Device = device;

			m_BufferViews.Fill(.Null);
			m_TextureDesc = .();
		}

		public ~this()
		{
			switch (m_Type)
			{
			case DescriptorTypeVK.NONE: fallthrough;
			case DescriptorTypeVK.ACCELERATION_STRUCTURE:
				break;
			case DescriptorTypeVK.BUFFER_VIEW:
				for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
				{
					if (m_BufferViews[i] != .Null)
						vkDestroyBufferView(m_Device, m_BufferViews[i], m_Device.GetAllocationCallbacks());
				}
				break;
			case DescriptorTypeVK.IMAGE_VIEW:
				for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
				{
					if (m_ImageViews[i] != .Null)
						vkDestroyImageView(m_Device, m_ImageViews[i], m_Device.GetAllocationCallbacks());
				}
				break;
			case DescriptorTypeVK.SAMPLER:
				if (m_Sampler != .Null)
					vkDestroySampler(m_Device, m_Sampler, m_Device.GetAllocationCallbacks());
				break;
			}
		}

		public override void SetDebugName(StringView name)
		{
			uint64[PHYSICAL_DEVICE_GROUP_MAX_SIZE] handles = .();

			switch (m_Type)
			{
			case DescriptorTypeVK.BUFFER_VIEW:
				for (int i = 0; i < handles.Count; i++)
					handles[i] = (uint64)m_BufferViews[i].Handle;
				m_Device.SetDebugNameToDeviceGroupObject(.VK_OBJECT_TYPE_BUFFER_VIEW, &handles, name);
				break;

			case DescriptorTypeVK.IMAGE_VIEW:
				for (int i = 0; i < handles.Count; i++)
					handles[i] = (uint64)m_ImageViews[i].Handle;
				m_Device.SetDebugNameToDeviceGroupObject(.VK_OBJECT_TYPE_IMAGE_VIEW, &handles, name);
				break;

			case DescriptorTypeVK.SAMPLER:
				m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_SAMPLER, (uint64)m_Sampler.Handle, name);
				break;

			case DescriptorTypeVK.ACCELERATION_STRUCTURE:
				for (int i = 0; i < handles.Count; i++)
					handles[i] = (uint64)m_AccelerationStructures[i].Handle;
				m_Device.SetDebugNameToDeviceGroupObject(.VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR, &handles, name);
				break;

			default:
				CHECK!(m_Device.GetLogger(), false, "unexpected descriptor type in SetDebugName: {0}", (uint32)m_Type);
				break;
			}
		}
	}
}
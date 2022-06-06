using Bulkan;
using System;
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
		public readonly TextureVK texture;
		public VkImageLayout imageLayout;
		public uint32 imageMipOffset;
		public uint32 imageMipNum;
		public uint32 imageArrayOffset;
		public uint32 imageArraySize;
		public VkImageAspectFlags imageAspectFlags;
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
		private ref VkSampler Sampler => ref m_Resource.Sampler;

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
		///////////////////////////////////////////////////////////////////////////
	}
}
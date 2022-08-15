using System;
namespace Sedulous.RHI.Validation
{
	enum ResourceType
	{
		NONE,
		BUFFER,
		TEXTURE,
		SAMPLER,
		ACCELERATION_STRUCTURE
	}

	enum ResourceViewType
	{
		NONE,
		COLOR_ATTACHMENT,
		DEPTH_STENCIL_ATTACHMENT,
		SHADER_RESOURCE,
		SHADER_RESOURCE_STORAGE,
		CONSTANT_BUFFER_VIEW
	}

	class DescriptorValidator : Descriptor
	{
		private readonly DeviceValidator mDevice;
		private readonly Descriptor mDescriptor;

		private ResourceType m_ResourceType = ResourceType.NONE;
		private ResourceViewType m_ResourceViewType = ResourceViewType.NONE;

		private readonly String mDebugName = new .() ~ delete _;


		public this(DeviceValidator device, Descriptor descriptor, ResourceType resourceType)
		{
			mDevice = device;
			mDescriptor = descriptor;
			m_ResourceType = resourceType;
		}

		public this(DeviceValidator device, Descriptor descriptor,  BufferViewDesc bufferViewDesc)
		{
			mDevice = device;
			mDescriptor = descriptor;
			m_ResourceType = .BUFFER;

			switch (bufferViewDesc.viewType)
			{
			case BufferViewType.CONSTANT:
				m_ResourceViewType = ResourceViewType.CONSTANT_BUFFER_VIEW;
				break;
			case BufferViewType.SHADER_RESOURCE:
				m_ResourceViewType = ResourceViewType.SHADER_RESOURCE;
				break;
			case BufferViewType.SHADER_RESOURCE_STORAGE:
				m_ResourceViewType = ResourceViewType.SHADER_RESOURCE_STORAGE;
				break;
			default:
				CHECK!(mDevice.GetLogger(), false, "unexpected BufferView type in DescriptorVal: {}", (uint32)bufferViewDesc.viewType);
				break;
			}
		}

		public this(DeviceValidator device, Descriptor descriptor,  Texture1DViewDesc textureViewDesc)
		{
			mDevice = device;
			mDescriptor = descriptor;
			m_ResourceType = .TEXTURE;

			switch (textureViewDesc.viewType)
			{
			case Texture1DViewType.SHADER_RESOURCE_1D:
			case Texture1DViewType.SHADER_RESOURCE_1D_ARRAY:
				m_ResourceViewType = ResourceViewType.SHADER_RESOURCE;
				break;
			case Texture1DViewType.SHADER_RESOURCE_STORAGE_1D:
			case Texture1DViewType.SHADER_RESOURCE_STORAGE_1D_ARRAY:
				m_ResourceViewType = ResourceViewType.SHADER_RESOURCE_STORAGE;
				break;
			case Texture1DViewType.COLOR_ATTACHMENT:
				m_ResourceViewType = ResourceViewType.COLOR_ATTACHMENT;
				break;
			case Texture1DViewType.DEPTH_STENCIL_ATTACHMENT:
				m_ResourceViewType = ResourceViewType.DEPTH_STENCIL_ATTACHMENT;
				break;
			default:
				CHECK!(mDevice.GetLogger(), false, "unexpected TextureView type in DescriptorVal: {}", (uint32)textureViewDesc.viewType);
				break;
			}
		}

		public this(DeviceValidator device, Descriptor descriptor,  Texture2DViewDesc textureViewDesc)
		{
			mDevice = device;
			mDescriptor = descriptor;
			m_ResourceType = .TEXTURE;

			switch (textureViewDesc.viewType)
			{
			case Texture2DViewType.SHADER_RESOURCE_2D:
			case Texture2DViewType.SHADER_RESOURCE_2D_ARRAY:
			case Texture2DViewType.SHADER_RESOURCE_CUBE:
			case Texture2DViewType.SHADER_RESOURCE_CUBE_ARRAY:
				m_ResourceViewType = ResourceViewType.SHADER_RESOURCE;
				break;
			case Texture2DViewType.SHADER_RESOURCE_STORAGE_2D:
			case Texture2DViewType.SHADER_RESOURCE_STORAGE_2D_ARRAY:
				m_ResourceViewType = ResourceViewType.SHADER_RESOURCE_STORAGE;
				break;
			case Texture2DViewType.COLOR_ATTACHMENT:
				m_ResourceViewType = ResourceViewType.COLOR_ATTACHMENT;
				break;
			case Texture2DViewType.DEPTH_STENCIL_ATTACHMENT:
				m_ResourceViewType = ResourceViewType.DEPTH_STENCIL_ATTACHMENT;
				break;
			default:
				CHECK!(mDevice.GetLogger(), false, "unexpected TextureView type in DescriptorVal: {}", (uint32)textureViewDesc.viewType);
				break;
			}
		}

		public this(DeviceValidator device, Descriptor descriptor,  Texture3DViewDesc textureViewDesc)
		{
			mDevice = device;
			mDescriptor = descriptor;
			m_ResourceType = .TEXTURE;

			switch (textureViewDesc.viewType)
			{
			case Texture3DViewType.SHADER_RESOURCE_3D:
				m_ResourceViewType = ResourceViewType.SHADER_RESOURCE;
				break;
			case Texture3DViewType.SHADER_RESOURCE_STORAGE_3D:
				m_ResourceViewType = ResourceViewType.SHADER_RESOURCE_STORAGE;
				break;
			case Texture3DViewType.COLOR_ATTACHMENT:
				m_ResourceViewType = ResourceViewType.COLOR_ATTACHMENT;
				break;
			default:
				CHECK!(mDevice.GetLogger(), false, "unexpected TextureView type in DescriptorVal: {}", (uint32)textureViewDesc.viewType);
				break;
			}
		}

		public this(DeviceValidator device, Descriptor descriptor)
		{
			mDevice = device;
			mDescriptor = descriptor;
			m_ResourceType = .SAMPLER;
		}

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mDescriptor.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public bool IsBufferView() => m_ResourceType == ResourceType.BUFFER;

		public bool IsTextureView() => m_ResourceType == ResourceType.TEXTURE;
		public bool IsSampler() => m_ResourceType == ResourceType.SAMPLER;
		public bool IsAccelerationStructure() => m_ResourceType == ResourceType.ACCELERATION_STRUCTURE;

		public bool IsConstantBufferView() => m_ResourceType == ResourceType.BUFFER && m_ResourceViewType == ResourceViewType.CONSTANT_BUFFER_VIEW;

		public bool IsShaderResource()
		{
			readonly bool isResourceTypeValid = m_ResourceType != ResourceType.NONE && m_ResourceType != ResourceType.SAMPLER;
			return isResourceTypeValid && m_ResourceViewType == ResourceViewType.SHADER_RESOURCE;
		}

		public bool IsShaderResourceStorage()
		{
			readonly bool isResourceTypeValid = m_ResourceType != ResourceType.NONE && m_ResourceType != ResourceType.SAMPLER;
			return isResourceTypeValid && m_ResourceViewType == ResourceViewType.SHADER_RESOURCE_STORAGE;
		}

		public bool IsColorAttachment() => IsTextureView() && m_ResourceViewType == ResourceViewType.COLOR_ATTACHMENT;

		public bool IsDepthStencilAttachment() => IsTextureView() && m_ResourceViewType == ResourceViewType.DEPTH_STENCIL_ATTACHMENT;
	}
}
using System.Collections;
using Bulkan;
using System;
namespace Sedulous.RHI.Vulkan
{
	struct PushConstantRangeBindingDesc
	{
		VkShaderStageFlags flags;
		uint32 offset;
	}

	struct RuntimeBindingInfo : IDisposable
	{
		private DeviceAllocator m_Allocator;

		public this(DeviceAllocator allocator)
		{
			m_Allocator = allocator;

			hasVariableDescriptorNum = Allocate!<List<bool>>(m_Allocator);
			descriptorSetRangeDescs = Allocate!<List<DescriptorRangeDesc>>(m_Allocator);
			dynamicConstantBufferDescs = Allocate!<List<DynamicConstantBufferDesc>>(m_Allocator);
			descriptorSetDescs = Allocate!<List<DescriptorSetDesc>>(m_Allocator);
			pushConstantDescs = Allocate!<List<PushConstantDesc>>(m_Allocator);
			pushConstantBindings = Allocate!<List<PushConstantRangeBindingDesc>>(m_Allocator);
		}

		public List<bool> hasVariableDescriptorNum;
		public List<DescriptorRangeDesc> descriptorSetRangeDescs;
		public List<DynamicConstantBufferDesc> dynamicConstantBufferDescs;
		public List<DescriptorSetDesc> descriptorSetDescs;
		public List<PushConstantDesc> pushConstantDescs;
		public List<PushConstantRangeBindingDesc> pushConstantBindings;

		public void Dispose()
		{
			Deallocate!(m_Allocator, hasVariableDescriptorNum);
			Deallocate!(m_Allocator, descriptorSetRangeDescs);
			Deallocate!(m_Allocator, dynamicConstantBufferDescs);
			Deallocate!(m_Allocator, descriptorSetDescs);
			Deallocate!(m_Allocator, pushConstantDescs);
			Deallocate!(m_Allocator, pushConstantBindings);
		}
	}

	class PipelineLayoutVK : PipelineLayout
	{
		private VkPipelineLayout m_Handle = .Null;
		private VkPipelineBindPoint m_PipelineBindPoint = (.)uint.MaxValue;
		private RuntimeBindingInfo m_RuntimeBindingInfo;
		private List<VkDescriptorSetLayout> m_DescriptorSetLayouts;
		private List<DescriptorVK> m_StaticSamplers;
		private DeviceVK m_Device;

		//////////////////////////////Private Methods//////////////////////////////

		///////////////////////////////////////////////////////////////////////////

		public this()
		{
		}

		public ~this()
		{
			//m_RuntimeBindingInfo.Dispose();
		}
	}
}
using Bulkan;
using System.Threading;
using System.Collections;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics.Vulkan;
	/// <summary>
	/// This class represent a pool of descriptor sets.
	/// </summary>
	internal class VKDescriptorSetPool
	{
		public class PoolInfo
		{
			public readonly VkDescriptorPool DescriptorPool;

			public uint32 RemainingSets;

			public uint32 ConstantBufferCount;

			public uint32 TextureCount;

			public uint32 SamplerCount;

			public uint32 StorageBufferCount;

			public uint32 StorageImageCount;

			public uint32 AccelerationStructureCount;

			public this(VkDescriptorPool pool, uint32 totalSets, uint32 descriptorCount)
			{
				DescriptorPool = pool;
				RemainingSets = totalSets;
				ConstantBufferCount = descriptorCount;
				TextureCount = descriptorCount;
				SamplerCount = descriptorCount;
				StorageBufferCount = descriptorCount;
				StorageImageCount = descriptorCount;
				AccelerationStructureCount = descriptorCount;
			}

			public bool Allocate(VKResourceCounts resourceCounts)
			{
				if (RemainingSets != 0 && ConstantBufferCount >= resourceCounts.ConstantBufferCount && TextureCount >= resourceCounts.TextureCount && SamplerCount >= resourceCounts.SamplerCount && StorageBufferCount >= resourceCounts.StorageBufferCount && StorageImageCount >= resourceCounts.StorageImageCount && AccelerationStructureCount >= resourceCounts.AccelerationStructureCount)
				{
					RemainingSets--;
					ConstantBufferCount -= resourceCounts.ConstantBufferCount;
					TextureCount -= resourceCounts.TextureCount;
					SamplerCount -= resourceCounts.SamplerCount;
					StorageBufferCount -= resourceCounts.StorageBufferCount;
					StorageImageCount -= resourceCounts.StorageImageCount;
					AccelerationStructureCount -= resourceCounts.AccelerationStructureCount;
					return true;
				}
				return false;
			}

			public  void Free(VKGraphicsContext context, VKDescriptorAllocationToken token, VKResourceCounts resourceCounts)
			{
				VkDescriptorSet descriptorSet = token.DescriptorSet;
				VulkanNative.vkFreeDescriptorSets(context.VkDevice, DescriptorPool, 1u, &descriptorSet);
				RemainingSets++;
				ConstantBufferCount += resourceCounts.ConstantBufferCount;
				TextureCount += resourceCounts.TextureCount;
				SamplerCount += resourceCounts.SamplerCount;
				StorageBufferCount += resourceCounts.StorageBufferCount;
				StorageImageCount += resourceCounts.StorageImageCount;
				AccelerationStructureCount += resourceCounts.AccelerationStructureCount;
			}
		}

		private VKGraphicsContext context;

		private readonly Monitor lockObject = new .() ~ delete _;

		private readonly List<PoolInfo> pools;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKDescriptorSetPool" /> class.
		/// </summary>
		/// <param name="context">The Vulkan graphics context.</param>
		public this(VKGraphicsContext context)
		{
			this.context = context;
			pools = new List<PoolInfo>();
			pools.Add(CreateNewPool());
		}

		public  PoolInfo CreateNewPool()
		{
			uint32 totalSets = 1000u;
			uint32 descriptorCount = 100u;
			uint32 poolSizeCount = 6u;
			VkDescriptorPoolSize* sizes = scope VkDescriptorPoolSize[(int32)poolSizeCount]*;
			sizes.type = VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
			sizes.descriptorCount = descriptorCount;
			sizes[1].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE;
			sizes[1].descriptorCount = descriptorCount;
			sizes[2].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER;
			sizes[2].descriptorCount = descriptorCount;
			sizes[3].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
			sizes[3].descriptorCount = descriptorCount;
			sizes[4].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
			sizes[4].descriptorCount = descriptorCount;
			sizes[5].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR;
			sizes[5].descriptorCount = descriptorCount;
			VkDescriptorPoolCreateInfo vkDescriptorPoolCreateInfo = default(VkDescriptorPoolCreateInfo);
			vkDescriptorPoolCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;
			vkDescriptorPoolCreateInfo.flags = VkDescriptorPoolCreateFlags.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT;
			vkDescriptorPoolCreateInfo.maxSets = totalSets;
			vkDescriptorPoolCreateInfo.pPoolSizes = sizes;
			vkDescriptorPoolCreateInfo.poolSizeCount = poolSizeCount;
			VkDescriptorPool pool = default(VkDescriptorPool);
			VulkanNative.vkCreateDescriptorPool(context.VkDevice, &vkDescriptorPoolCreateInfo, null, &pool);
			return new PoolInfo(pool, totalSets, descriptorCount);
		}

		public VkDescriptorPool GetPool(VKResourceCounts resourceCounts)
		{
			using (lockObject.Enter())
			{
				for (PoolInfo pool in pools)
				{
					if (pool.Allocate(resourceCounts))
					{
						return pool.DescriptorPool;
					}
				}
				PoolInfo poolInfo = CreateNewPool();
				pools.Add(poolInfo);
				poolInfo.Allocate(resourceCounts);
				return poolInfo.DescriptorPool;
			}
		}

		public  VKDescriptorAllocationToken Allocate(VkDescriptorSetLayout layout, VKResourceCounts resourceCounts)
		{
			var layout;
			VkDescriptorPool pool = GetPool(resourceCounts);
			VkDescriptorSetAllocateInfo vkDescriptorSetAllocateInfo = default(VkDescriptorSetAllocateInfo);
			vkDescriptorSetAllocateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
			vkDescriptorSetAllocateInfo.descriptorSetCount = 1u;
			vkDescriptorSetAllocateInfo.pSetLayouts = &layout;
			vkDescriptorSetAllocateInfo.descriptorPool = pool;
			VkDescriptorSet set = default(VkDescriptorSet);
			VulkanNative.vkAllocateDescriptorSets(context.VkDevice, &vkDescriptorSetAllocateInfo, &set);
			return VKDescriptorAllocationToken(pool, set);
		}

		public void Free(VKDescriptorAllocationToken token, VKResourceCounts resourceCounts)
		{
			using (lockObject.Enter())
			{
				for (PoolInfo pool in pools)
				{
					if (pool.DescriptorPool == token.DescriptorPool)
					{
						pool.Free(context, token, resourceCounts);
					}
				}
			}
		}

		public  void DestroyAll()
		{
			for (PoolInfo pool in pools)
			{
				VulkanNative.vkDestroyDescriptorPool(context.VkDevice, pool.DescriptorPool, null);
				delete pool;
			}
			delete pools;
		}
	}
}

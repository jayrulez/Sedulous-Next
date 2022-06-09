using System;
using Bulkan;
using Sedulous.Graphics.Raytracing;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics.Vulkan;
	using static Sedulous.Graphics.Vulkan.VKHelpers;
	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;

	/// <summary>
	/// Vulkan Bottom Level Acceleration Structure implementation.
	/// </summary>
	public class VKBottomLevelAS : BottomLevelAS
	{
		/// <summary>
		/// The bottom level acceleration structure instance.
		/// </summary>
		public VkAccelerationStructureKHR BottomLevelAS;

		private uint64 bottomLevelASHandle;

		private VKGraphicsContext vkContext;

		/// <inheritdoc />
		public override void* NativePointer => (void*)(int)bottomLevelASHandle;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKBottomLevelAS" /> class.
		/// </summary>
		/// <param name="context">Graphics Context.</param>
		/// <param name="commandBuffer">Command buffer.</param>
		/// <param name="description">Bottom Level Description.</param>
		public  this(VKGraphicsContext context, VkCommandBuffer commandBuffer, ref BottomLevelASDescription description)
			: base(context, ref description)
		{
			vkContext = context;
			VkAccelerationStructureGeometryKHR* ptr = scope VkAccelerationStructureGeometryKHR[description.Geometries.Count]*;
			VkAccelerationStructureBuildRangeInfoKHR* ptr2 = scope VkAccelerationStructureBuildRangeInfoKHR[description.Geometries.Count]*;
			uint32 primitiveCount = 0u;
			for (int32 i = 0; i < description.Geometries.Count; i++)
			{
				AccelerationStructureGeometry accelerationStructureGeometry = description.Geometries[i];
				VkAccelerationStructureGeometryKHR vkAccelerationStructureGeometryKHR = default(VkAccelerationStructureGeometryKHR);
				VkAccelerationStructureBuildRangeInfoKHR vkAccelerationStructureBuildRangeInfoKHR = default(VkAccelerationStructureBuildRangeInfoKHR);
				AccelerationStructureTriangles accelerationStructureTriangles = accelerationStructureGeometry as AccelerationStructureTriangles;
				VkAccelerationStructureGeometryKHR vkAccelerationStructureGeometryKHR2;
				VkAccelerationStructureGeometryDataKHR geometry;
				VkAccelerationStructureBuildRangeInfoKHR vkAccelerationStructureBuildRangeInfoKHR2;
				if (accelerationStructureTriangles != null)
				{
					VkDeviceOrHostAddressConstKHR bufferAddress = (accelerationStructureTriangles.VertexBuffer as VKBuffer).BufferAddress;
					bufferAddress.deviceAddress += accelerationStructureTriangles.VertexOffset;
					VkDeviceOrHostAddressConstKHR indexData = default(VkDeviceOrHostAddressConstKHR);
					if (accelerationStructureTriangles.IndexBuffer != null)
					{
						indexData = (accelerationStructureTriangles.IndexBuffer as VKBuffer).BufferAddress;
						indexData.deviceAddress += accelerationStructureTriangles.IndexOffset;
					}
					vkAccelerationStructureGeometryKHR2 = VkAccelerationStructureGeometryKHR
					{
						sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
						flags = (VkGeometryFlagsKHR)accelerationStructureTriangles.Flags,
						geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_TRIANGLES_KHR
					};
					geometry = (vkAccelerationStructureGeometryKHR2.geometry = VkAccelerationStructureGeometryDataKHR
					{
						triangles = VkAccelerationStructureGeometryTrianglesDataKHR
						{
							sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
							vertexData = bufferAddress,
							vertexFormat = accelerationStructureTriangles.VertexFormat.ToVulkan(/*depthFormat: */false),
							vertexStride = accelerationStructureTriangles.VertexStride,
							maxVertex = accelerationStructureTriangles.VertexCount,
							indexData = indexData,
							indexType = ((indexData.deviceAddress != 0L) ? accelerationStructureTriangles.IndexFormat.ToVulkan() : VkIndexType.VK_INDEX_TYPE_NONE_KHR)
						}
					});
					vkAccelerationStructureGeometryKHR = vkAccelerationStructureGeometryKHR2;
					primitiveCount = ((indexData.deviceAddress != 0L) ? (accelerationStructureTriangles.IndexCount / 3u) : (accelerationStructureTriangles.VertexCount / 3u));
					vkAccelerationStructureBuildRangeInfoKHR2 = VkAccelerationStructureBuildRangeInfoKHR
					{
						primitiveCount = primitiveCount,
						primitiveOffset = 0u,
						firstVertex = 0u,
						transformOffset = 0u
					};
					vkAccelerationStructureBuildRangeInfoKHR = vkAccelerationStructureBuildRangeInfoKHR2;
				}
				else
				{
					AccelerationStructureAABBs accelerationStructureAABBs = accelerationStructureGeometry as AccelerationStructureAABBs;
					if (accelerationStructureAABBs != null)
					{
						vkAccelerationStructureGeometryKHR2 = VkAccelerationStructureGeometryKHR
						{
							sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
							pNext = null,
							flags = (VkGeometryFlagsKHR)accelerationStructureAABBs.Flags,
							geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_AABBS_KHR
						};
						geometry = VkAccelerationStructureGeometryDataKHR
						{
							aabbs = VkAccelerationStructureGeometryAabbsDataKHR
							{
								sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR,
								stride = accelerationStructureAABBs.Stride,
								data = (accelerationStructureAABBs.AABBs as VKBuffer).BufferAddress
							}
						};
						vkAccelerationStructureGeometryKHR2.geometry = geometry;
						vkAccelerationStructureGeometryKHR = vkAccelerationStructureGeometryKHR2;
						primitiveCount = (uint32)accelerationStructureAABBs.Count;
						vkAccelerationStructureBuildRangeInfoKHR2 = VkAccelerationStructureBuildRangeInfoKHR
						{
							primitiveCount = primitiveCount,
							primitiveOffset = accelerationStructureAABBs.Offset,
							firstVertex = 0u,
							transformOffset = 0u
						};
						vkAccelerationStructureBuildRangeInfoKHR = vkAccelerationStructureBuildRangeInfoKHR2;
					}
					else
					{
						context.ValidationLayer.Notify("VK", "Acceleration Structure geometry type not supported!");
					}
				}
				ptr[i] = vkAccelerationStructureGeometryKHR;
				ptr2[i] = vkAccelerationStructureBuildRangeInfoKHR;
			}
			VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR = VkAccelerationStructureBuildGeometryInfoKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
				type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR,
				flags = VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR,
				geometryCount = (uint32)description.Geometries.Count,
				pGeometries = ptr
			};
			VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR2 = vkAccelerationStructureBuildGeometryInfoKHR;
			VkAccelerationStructureBuildSizesInfoKHR vkAccelerationStructureBuildSizesInfoKHR = VkAccelerationStructureBuildSizesInfoKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR
			};
			VulkanNative.vkGetAccelerationStructureBuildSizesKHR(vkContext.VkDevice, VkAccelerationStructureBuildTypeKHR.VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR, &vkAccelerationStructureBuildGeometryInfoKHR2, &primitiveCount, &vkAccelerationStructureBuildSizesInfoKHR);
			VkBuffer buffer = VKRaytracingHelpers.CreateBuffer(vkContext, vkAccelerationStructureBuildSizesInfoKHR.accelerationStructureSize, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR).Buffer;
			VkAccelerationStructureCreateInfoKHR vkAccelerationStructureCreateInfoKHR = VkAccelerationStructureCreateInfoKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR,
				buffer = buffer,
				size = vkAccelerationStructureBuildSizesInfoKHR.accelerationStructureSize,
				type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR
			};
			VkAccelerationStructureKHR bottomLevelAS = default(VkAccelerationStructureKHR);
			VulkanNative.vkCreateAccelerationStructureKHR(vkContext.VkDevice, &vkAccelerationStructureCreateInfoKHR, null, &bottomLevelAS);
			BottomLevelAS = bottomLevelAS;
			bottomLevelASHandle = BottomLevelAS.GetAccelerationStructureAddress(vkContext.VkDevice);
			vkAccelerationStructureBuildGeometryInfoKHR2.dstAccelerationStructure = BottomLevelAS;
			VkBuffer buffer2 = VKRaytracingHelpers.CreateBuffer(vkContext, vkAccelerationStructureBuildSizesInfoKHR.buildScratchSize, VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT).Buffer;
			vkAccelerationStructureBuildGeometryInfoKHR = VkAccelerationStructureBuildGeometryInfoKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
				type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR,
				flags = VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR,
				mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR,
				dstAccelerationStructure = BottomLevelAS,
				geometryCount = 1,
				pGeometries = ptr,
				scratchData = VkDeviceOrHostAddressKHR
				{
					deviceAddress = buffer2.GetBufferAddress(vkContext.VkDevice)
				}
			};
			VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR3 = vkAccelerationStructureBuildGeometryInfoKHR;
			VulkanNative.vkCmdBuildAccelerationStructuresKHR(commandBuffer, vkAccelerationStructureBuildGeometryInfoKHR3.geometryCount, &vkAccelerationStructureBuildGeometryInfoKHR3, &ptr2);
			VkMemoryBarrier vkMemoryBarrier = VkMemoryBarrier
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_BARRIER,
				pNext = null,
				srcAccessMask = (VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR | VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR),
				dstAccessMask = (VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR | VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR)
			};
			VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR, VkPipelineStageFlags.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR, VkDependencyFlags.None, 1u, &vkMemoryBarrier, 0u, null, 0u, null);
		}

		/// <inheritdoc />
		public override void Dispose()
		{
			/*Dispose(disposing: true);
			GC.SuppressFinalize(this);*/
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
		private  void Dispose(bool disposing)
		{
			if (!disposed)
			{
				if (disposing)
				{
					VulkanNative.vkDestroyAccelerationStructureKHR(vkContext.VkDevice, BottomLevelAS, null);
				}
				disposed = true;
			}
		}
	}
}

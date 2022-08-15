using System;
namespace Sedulous.RHI.Validation
{
	public static
	{
		public const char8*[?] DESCRIPTOR_TYPE_NAME = .(
			"SAMPLER",
			"CONSTANT_BUFFER",
			"TEXTURE",
			"STORAGE_TEXTURE",
			"BUFFER",
			"STORAGE_BUFFER",
			"STRUCTURED_BUFFER",
			"STORAGE_STRUCTURED_BUFFER",
			"ACCELERATION_STRUCTURE"
			);

		[Comptime()]
		public static void Asserts()
		{
			Compiler.Assert(DESCRIPTOR_TYPE_NAME.Count == (uint32)DescriptorType.MAX_NUM, "descriptor type name array is out of date");
		}

		public static char8* GetDescriptorTypeName(DescriptorType descriptorType)
		{
			return DESCRIPTOR_TYPE_NAME[(uint32)descriptorType];
		}

		public static bool IsAccessMaskSupported(BufferUsageBits usageMask, AccessBits accessMask)
		{
			BufferUsageBits requiredUsageMask = BufferUsageBits.NONE;

			if (accessMask & AccessBits.VERTEX_BUFFER != 0)
				requiredUsageMask |= BufferUsageBits.VERTEX_BUFFER;

			if (accessMask & AccessBits.INDEX_BUFFER != 0)
				requiredUsageMask |= BufferUsageBits.INDEX_BUFFER;

			if (accessMask & AccessBits.CONSTANT_BUFFER != 0)
				requiredUsageMask |= BufferUsageBits.CONSTANT_BUFFER;

			if (accessMask & AccessBits.ARGUMENT_BUFFER != 0)
				requiredUsageMask |= BufferUsageBits.ARGUMENT_BUFFER;

			if (accessMask & AccessBits.SHADER_RESOURCE != 0)
				requiredUsageMask |= BufferUsageBits.SHADER_RESOURCE;

			if (accessMask & AccessBits.SHADER_RESOURCE_STORAGE != 0)
				requiredUsageMask |= BufferUsageBits.SHADER_RESOURCE_STORAGE;

			if (accessMask & AccessBits.COLOR_ATTACHMENT != 0)
				return false;

			if (accessMask & AccessBits.DEPTH_STENCIL_WRITE != 0)
				return false;

			if (accessMask & AccessBits.DEPTH_STENCIL_READ != 0)
				return false;

			if (accessMask & AccessBits.ACCELERATION_STRUCTURE_READ != 0)
				return false;

			if (accessMask & AccessBits.ACCELERATION_STRUCTURE_WRITE != 0)
				return false;

			return (uint32)(requiredUsageMask & usageMask) == (uint32)requiredUsageMask;
		}

		public static bool IsAccessMaskSupported(TextureUsageBits usageMask, AccessBits accessMask)
		{
			TextureUsageBits requiredUsageMask = TextureUsageBits.NONE;

			if (accessMask & AccessBits.VERTEX_BUFFER != 0)
				return false;

			if (accessMask & AccessBits.INDEX_BUFFER != 0)
				return false;

			if (accessMask & AccessBits.CONSTANT_BUFFER != 0)
				return false;

			if (accessMask & AccessBits.ARGUMENT_BUFFER != 0)
				return false;

			if (accessMask & AccessBits.SHADER_RESOURCE != 0)
				requiredUsageMask |= TextureUsageBits.SHADER_RESOURCE;

			if (accessMask & AccessBits.SHADER_RESOURCE_STORAGE != 0)
				requiredUsageMask |= TextureUsageBits.SHADER_RESOURCE_STORAGE;

			if (accessMask & AccessBits.COLOR_ATTACHMENT != 0)
				requiredUsageMask |= TextureUsageBits.COLOR_ATTACHMENT;

			if (accessMask & AccessBits.DEPTH_STENCIL_WRITE != 0)
				requiredUsageMask |= TextureUsageBits.DEPTH_STENCIL_ATTACHMENT;

			if (accessMask & AccessBits.DEPTH_STENCIL_READ != 0)
				requiredUsageMask |= TextureUsageBits.DEPTH_STENCIL_ATTACHMENT;

			if (accessMask & AccessBits.ACCELERATION_STRUCTURE_READ != 0)
				return false;

			if (accessMask & AccessBits.ACCELERATION_STRUCTURE_WRITE != 0)
				return false;

			return (uint32)(requiredUsageMask & usageMask) == (uint32)requiredUsageMask;
		}

		public const TextureUsageBits[(int)TextureLayout.MAX_NUM] TEXTURE_USAGE_FOR_TEXTURE_LAYOUT_TABLE = .(
			TextureUsageBits.NONE, // GENERAL
			TextureUsageBits.COLOR_ATTACHMENT, // COLOR_ATTACHMENT
			TextureUsageBits.DEPTH_STENCIL_ATTACHMENT, // DEPTH_STENCIL
			TextureUsageBits.DEPTH_STENCIL_ATTACHMENT, // DEPTH_STENCIL_READONLY
			TextureUsageBits.DEPTH_STENCIL_ATTACHMENT, // DEPTH_READONLY
			TextureUsageBits.DEPTH_STENCIL_ATTACHMENT, // STENCIL_READONLY
			TextureUsageBits.SHADER_RESOURCE, // SHADER_RESOURCE
			TextureUsageBits.NONE, // PRESENT
			TextureUsageBits.NONE // UNKNOWN
			);

		public static bool IsTextureLayoutSupported(TextureUsageBits usageMask, TextureLayout textureLayout)
		{
			readonly TextureUsageBits requiredMask = TEXTURE_USAGE_FOR_TEXTURE_LAYOUT_TABLE[(int)textureLayout];

			return (uint32)(requiredMask & usageMask) == (uint32)requiredMask;
		}

		public static void ConvertGeometryObjectsVal(GeometryObject* destObjects, GeometryObject* sourceObjects, uint32 objectNum)
		{
			for (uint32 i = 0; i < objectNum; i++)
			{
				readonly ref GeometryObject geometrySrc = ref sourceObjects[i];
				ref GeometryObject geometryDst = ref destObjects[i];

				geometryDst = geometrySrc;

				if (geometrySrc.type == GeometryType.TRIANGLES)
				{
					geometryDst.triangles.vertexBuffer = ((BufferValidator)geometrySrc.triangles.vertexBuffer).GetImpl();
					geometryDst.triangles.indexBuffer = ((BufferValidator)geometrySrc.triangles.indexBuffer).GetImpl();
					geometryDst.triangles.transformBuffer = ((BufferValidator)geometrySrc.triangles.transformBuffer).GetImpl();
				}
				else
				{
					geometryDst.boxes.buffer = ((BufferValidator)geometrySrc.boxes.buffer).GetImpl();
				}
			}
		}
	}

	static class ValidationHelper
	{
	}
}
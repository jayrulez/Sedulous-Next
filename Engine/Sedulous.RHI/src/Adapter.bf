using System;
namespace Sedulous.RHI
{
	abstract class Adapter
	{
		public struct Info
		{
			public uint32 UniformBufferAlignment;
			public uint32 UploadBufferTextureAlignment;
			public uint32 UploadBufferTextureRowSlignment;
			public uint32 MaxVertexInputBindings;
			public uint32 WaveLaneCount;
			public uint64 HostVisibleVramBudget;
			public bool SupportHostVisibleVram;
			public bool MultidrawIndirect;
			public bool SupportGeometryShader;
			public bool SupportTessellation;
			public bool IsUma;
			public bool IsVirtual;
			public bool IsCpu;
			public FormatSupport[(.)Format.FORMAT_COUNT] FormatSupports;
			public VendorPreset VendorPreset;
		}

		public abstract Instance Instance {get; }

		public abstract Result<void> GetInfo(out Info info);

		public abstract uint32 GetQueueCount();

		public abstract Result<void> CreateDevice(in Device.Description description, out Device device);

		public abstract void DestroyDevice(in Device device);
	}
}
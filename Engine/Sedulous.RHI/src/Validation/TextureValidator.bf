using System;
namespace Sedulous.RHI.Validation
{
	class TextureValidator : Texture
	{
		private readonly DeviceValidator mDevice;
		private readonly Texture mTexture;
		private MemoryValidator m_Memory = null;
		private readonly TextureDesc m_TextureDesc = .();
		private bool m_IsBoundToMemory = false;

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, Texture texture, TextureDesc textureDesc)
		{
			mDevice = device;
			mTexture = texture;

			m_TextureDesc = textureDesc;
		}

		public ~this()
		{
			if (m_Memory != null)
				m_Memory.UnbindTexture(this);
		}

		public void SetBoundToMemory()
		{
			m_IsBoundToMemory = true;
		}

		public void SetBoundToMemory(MemoryValidator memory)
		{
			m_Memory = memory;
			m_IsBoundToMemory = true;
		}

		public bool IsBoundToMemory()
		{
			return m_IsBoundToMemory;
		}

		public readonly ref TextureDesc GetDesc() => ref m_TextureDesc;

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mTexture.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc)
		{
			mTexture.GetMemoryInfo(memoryLocation, ref memoryDesc);
			mDevice.RegisterMemoryType(memoryDesc.type, memoryLocation);
		}
	}
}
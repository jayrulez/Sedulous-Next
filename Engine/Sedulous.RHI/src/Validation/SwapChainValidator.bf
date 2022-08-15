using System;
using System.Collections;
namespace Sedulous.RHI.Validation
{
	class SwapChainValidator : SwapChain
	{
		private readonly DeviceValidator mDevice;
		private SwapChain mSwapChain;
		private List<TextureValidator> m_Textures;
		private SwapChainDesc m_SwapChainDesc = .();

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, SwapChain swapChain, SwapChainDesc swapChainDesc)
		{
			mDevice = device;
			mSwapChain = swapChain;
			m_SwapChainDesc = swapChainDesc;

			m_Textures = Allocate!<List<TextureValidator>>(mDevice.GetDeviceAllocator());
		}

		public ~this()
		{
			for (int i = 0; i < m_Textures.Count; i++)
				Deallocate!(mDevice.GetDeviceAllocator(), m_Textures[i]);

			Deallocate!(mDevice.GetDeviceAllocator(), m_Textures);
		}

		public ref SwapChain GetImpl() => ref mSwapChain;

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mSwapChain.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override Texture* GetTextures(ref uint32 textureNum, ref Format format)
		{
			Texture* textures = mSwapChain.GetTextures(ref textureNum, ref format);

			TextureDesc textureDesc = .();
			textureDesc.type = TextureType.TEXTURE_2D;
			textureDesc.usageMask = TextureUsageBits.SHADER_RESOURCE | TextureUsageBits.COLOR_ATTACHMENT;
			textureDesc.format = format;
			textureDesc.size[0] = m_SwapChainDesc.width;
			textureDesc.size[1] = m_SwapChainDesc.height;
			textureDesc.size[2] = 1;
			textureDesc.mipNum = 1;
			textureDesc.arraySize = 1;
			textureDesc.sampleNum = 1;
			textureDesc.physicalDeviceMask = 0;

			m_Textures.Resize(textureNum);
			for (uint32 i = 0; i < textureNum; i++)
				m_Textures[i] = Allocate!<TextureValidator>(mDevice.GetDeviceAllocator(), mDevice, textures[i], textureDesc);

			return m_Textures.Ptr;
		}

		public override uint32 AcquireNextTexture(QueueSemaphore textureReadyForRender)
		{
			((QueueSemaphoreValidator)textureReadyForRender).Signal();

			return mSwapChain.AcquireNextTexture(textureReadyForRender);
		}

		public override Result Present(QueueSemaphore textureReadyForPresent)
		{
			((QueueSemaphoreValidator)textureReadyForPresent).Wait();

			return mSwapChain.Present(textureReadyForPresent);
		}

		public override Result SetHdrMetadata(HdrMetadata hdrMetadata)
		{
			return mSwapChain.SetHdrMetadata(hdrMetadata);
		}
	}
}
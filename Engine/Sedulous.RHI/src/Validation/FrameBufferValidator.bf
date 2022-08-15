using System;
namespace Sedulous.RHI.Validation
{
	class FrameBufferValidator : FrameBuffer
	{
		private readonly DeviceValidator mDevice;
		private FrameBuffer mFrameBuffer;

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, FrameBuffer frameBuffer)
		{
			mDevice = device;
			mFrameBuffer = frameBuffer;
		}

		public ref FrameBuffer GetImpl() => ref mFrameBuffer;

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mFrameBuffer.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;
	}
}
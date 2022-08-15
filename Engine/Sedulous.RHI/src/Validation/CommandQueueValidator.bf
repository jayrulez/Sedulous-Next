using System;
namespace Sedulous.RHI.Validation
{
	class CommandQueueValidator : CommandQueue
	{
		private readonly DeviceValidator mDevice;
		private readonly CommandQueue mCommandQueue;

		public this(DeviceValidator device, CommandQueue commandQueue)
		{
			mDevice = device;
			mCommandQueue = commandQueue;
		}

		public override void SetDebugName(StringView name)
		{
			mCommandQueue.SetDebugName(name);
		}

		public override void Submit(WorkSubmissionDesc workSubmissionDesc, DeviceSemaphore deviceSemaphore)
		{
		}

		public override void Wait(DeviceSemaphore deviceSemaphore)
		{
		}

		public override Result ChangeResourceStates(TransitionBarrierDesc transitionBarriers)
		{
			return default;
		}

		public override Result UploadData(TextureUploadDesc* textureUploadDescs, uint32 textureUploadDescNum, BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum)
		{
			return default;
		}

		public override Result WaitForIdle()
		{
			return default;
		}
	}
}
using System;
namespace Sedulous.RHI
{
	abstract class CommandQueue
	{
		public abstract void SetDebugName(StringView name);

        public abstract void Submit(WorkSubmissionDesc workSubmissionDesc, DeviceSemaphore deviceSemaphore);
        public abstract void Wait(DeviceSemaphore deviceSemaphore);

        public abstract Result ChangeResourceStates(TransitionBarrierDesc transitionBarriers);
        public abstract Result UploadData(TextureUploadDesc* textureUploadDescs, uint32 textureUploadDescNum,
            BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum);
        public abstract Result WaitForIdle();
	}
}
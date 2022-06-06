using System;
namespace Sedulous.RHI
{
	abstract class CommandQueue
	{
		public abstract void SetDebugName(in StringView name);

        public abstract void Submit(in WorkSubmissionDesc workSubmissionDesc, DeviceSemaphore deviceSemaphore);
        public abstract void Wait(ref DeviceSemaphore deviceSemaphore);

        public abstract Result ChangeResourceStates(in TransitionBarrierDesc transitionBarriers);
        public abstract Result UploadData(in TextureUploadDesc* textureUploadDescs, uint32 textureUploadDescNum,
            in BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum);
        public abstract Result WaitForIdle();
	}
}
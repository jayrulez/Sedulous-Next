using System;
namespace Sedulous.RHI.Validation
{
	class CommandAllocatorValidator : CommandAllocator
	{
		private readonly DeviceValidator mDevice;
		private readonly CommandAllocator mCommandAllocator;

		public this(DeviceValidator device, CommandAllocator commandAllocator)
		{
			mDevice = device;
			mCommandAllocator = commandAllocator;
		}

		public override void SetDebugName(StringView name)
		{
			mCommandAllocator.SetDebugName(name);
		}

		public override Result CreateCommandBuffer(out CommandBuffer commandBuffer)
		{
			commandBuffer = ?;
			CommandBuffer commandBufferImpl;
			readonly Result result = mCommandAllocator.CreateCommandBuffer(out commandBufferImpl);

			if (result == Result.SUCCESS)
			{
			    RETURN_ON_FAILURE!(mDevice.GetLogger(), commandBufferImpl != null, Result.FAILURE, "Implementation failure: 'commandBufferImpl' is NULL!");
			    commandBuffer = (CommandBuffer)Allocate!<CommandBufferValidator>(mDevice.GetDeviceAllocator(), mDevice, commandBufferImpl);
			}

			return result;
		}

		public override void Reset()
		{
			mCommandAllocator.Reset();
		}
	}
}
using System;
using System.Collections;
namespace Sedulous.RHI.Validation
{
	public static
	{
		public static bool ValidateTransitionBarrierDesc(DeviceValidator device, uint32 i, BufferTransitionBarrierDesc bufferTransitionBarrierDesc)
		{
			RETURN_ON_FAILURE!(device.GetLogger(), bufferTransitionBarrierDesc.buffer != null, false,
				"Can't change resource state: 'transitionBarriers.buffers[{}].buffer' is invalid.", i);

			BufferValidator bufferVal = (BufferValidator)bufferTransitionBarrierDesc.buffer;

			RETURN_ON_FAILURE!(device.GetLogger(), bufferVal.IsBoundToMemory(), false,
				"Can't change resource state: 'transitionBarriers.buffers[{}].buffer' is not bound to memory.", i);

			readonly BufferUsageBits usageMask = bufferVal.GetUsageMask();

			RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(usageMask, bufferTransitionBarrierDesc.prevAccess), false,
				"Can't change resource state: 'transitionBarriers.buffers[{}].prevAccess' is not supported by usageMask of the buffer.", i);

			RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(usageMask, bufferTransitionBarrierDesc.nextAccess), false,
				"Can't change resource state: 'transitionBarriers.buffers[{}].nextAccess' is not supported by usageMask of the buffer.", i);

			return true;
		}

		public static bool ValidateTransitionBarrierDesc(DeviceValidator device, uint32 i, TextureTransitionBarrierDesc textureTransitionBarrierDesc)
		{
			RETURN_ON_FAILURE!(device.GetLogger(), textureTransitionBarrierDesc.texture != null, false,
				"Can't change resource state: 'transitionBarriers.textures[{}].texture' is invalid.", i);

			TextureValidator textureVal = (TextureValidator)textureTransitionBarrierDesc.texture;

			RETURN_ON_FAILURE!(device.GetLogger(), textureVal.IsBoundToMemory(), false,
				"Can't change resource state: 'transitionBarriers.textures[{}].texture' is not bound to memory.", i);

			readonly TextureUsageBits usageMask = textureVal.GetDesc().usageMask;

			RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(usageMask, textureTransitionBarrierDesc.prevAccess), false,
				"Can't change resource state: 'transitionBarriers.textures[{}].prevAccess' is not supported by usageMask of the texture.", i);

			RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(usageMask, textureTransitionBarrierDesc.nextAccess), false,
				"Can't change resource state: 'transitionBarriers.textures[{}].nextAccess' is not supported by usageMask of the texture.", i);

			RETURN_ON_FAILURE!(device.GetLogger(), IsTextureLayoutSupported(usageMask, textureTransitionBarrierDesc.prevLayout), false,
				"Can't change resource state: 'transitionBarriers.textures[{}].prevLayout' is not supported by usageMask of the texture.", i);

			RETURN_ON_FAILURE!(device.GetLogger(), IsTextureLayoutSupported(usageMask, textureTransitionBarrierDesc.nextLayout), false,
				"Can't change resource state: 'transitionBarriers.textures[{}].nextLayout' is not supported by usageMask of the texture.", i);

			return true;
		}

		public static bool ValidateTextureUploadDesc(DeviceValidator device, uint32 i, TextureUploadDesc textureUploadDesc)
		{
			readonly uint32 subresourceNum = textureUploadDesc.arraySize * textureUploadDesc.mipNum;

			RETURN_ON_FAILURE!(device.GetLogger(), textureUploadDesc.texture != null, false,
				"Can't upload data: 'textureUploadDescs[{}].texture' is invalid.", i);

			if (subresourceNum == 0 && textureUploadDesc.subresources != null)
			{
				REPORT_WARNING(device.GetLogger(), "No data to upload: the number of subresources in 'textureUploadDescs[{}]' is 0.", i);
				return true;
			}

			if (textureUploadDesc.subresources == null)
				return true;

			TextureValidator textureVal = (TextureValidator)textureUploadDesc.texture;

			RETURN_ON_FAILURE!(device.GetLogger(), textureUploadDesc.mipNum <= textureVal.GetDesc().mipNum, false,
				"Can't upload data: 'textureUploadDescs[{}].mipNum' is invalid.", i);

			RETURN_ON_FAILURE!(device.GetLogger(), textureUploadDesc.arraySize <= textureVal.GetDesc().arraySize, false,
				"Can't upload data: 'textureUploadDescs[{}].arraySize' is invalid.", i);

			RETURN_ON_FAILURE!(device.GetLogger(), textureUploadDesc.nextLayout < TextureLayout.MAX_NUM, false,
				"Can't upload data: 'textureUploadDescs[{}].nextLayout' is invalid.", i);

			RETURN_ON_FAILURE!(device.GetLogger(), textureVal.IsBoundToMemory(), false,
				"Can't upload data: 'textureUploadDescs[{}].texture' is not bound to memory.", i);

			for (uint32 j = 0; j < subresourceNum; j++)
			{
				readonly ref TextureSubresourceUploadDesc subresource = ref textureUploadDesc.subresources[j];

				if (subresource.sliceNum == 0)
				{
					REPORT_WARNING(device.GetLogger(), "No data to upload: the number of subresources in 'textureUploadDescs[{}].subresources[{}].sliceNum' is 0.", i, j);
					continue;
				}

				RETURN_ON_FAILURE!(device.GetLogger(), subresource.slices != null, false,
					"Can't upload data: 'textureUploadDescs[{}].subresources[{}].slices' is invalid.", i, j);

				RETURN_ON_FAILURE!(device.GetLogger(), subresource.rowPitch != 0, false,
					"Can't upload data: 'textureUploadDescs[{}].subresources[{}].rowPitch' is 0.", i, j);

				RETURN_ON_FAILURE!(device.GetLogger(), subresource.slicePitch != 0, false,
					"Can't upload data: 'textureUploadDescs[{}].subresources[{}].slicePitch' is 0.", i, j);
			}

			return true;
		}

		public static bool ValidateBufferUploadDesc(DeviceValidator device, uint32 i, BufferUploadDesc bufferUploadDesc)
		{
			RETURN_ON_FAILURE!(device.GetLogger(), bufferUploadDesc.buffer != null, false,
				"Can't upload data: 'bufferUploadDescs[{}].buffer' is invalid.", i);

			if (bufferUploadDesc.dataSize == 0)
			{
				REPORT_WARNING(device.GetLogger(), "No data to upload: 'bufferUploadDescs[{}].dataSize' is 0.", i);
				return true;
			}

			RETURN_ON_FAILURE!(device.GetLogger(), bufferUploadDesc.data != null, false,
				"Can't upload data: 'bufferUploadDescs[{}].data' is invalid.", i);

			BufferValidator bufferVal = (BufferValidator)bufferUploadDesc.buffer;

			readonly uint64 rangeEnd = bufferUploadDesc.bufferOffset + bufferUploadDesc.dataSize;

			RETURN_ON_FAILURE!(device.GetLogger(), rangeEnd <= bufferVal.GetDesc().size, false,
				"Can't upload data: 'bufferUploadDescs[{}].bufferOffset + bufferUploadDescs[{}].dataSize' is out of bounds.", i, i);

			RETURN_ON_FAILURE!(device.GetLogger(), bufferVal.IsBoundToMemory(), false,
				"Can't upload data: 'bufferUploadDescs[{}].buffer' is not bound to memory.", i);

			return true;
		}

		public static Command* ReadCommand<Command>(uint8* begin, uint8* end)
		{
			var begin;
			if (begin + sizeof(Command) <= end)
			{
				readonly Command* command = (Command*)begin;
				begin += sizeof(Command);
				return command;
			}
			return null;
		}
	}

	typealias ProcessValidationCommandMethod = function void(CommandQueueValidator this, uint8* begin, uint8* end);

	class CommandQueueValidator : CommandQueue
	{
		private readonly DeviceValidator mDevice;
		private readonly CommandQueue mCommandQueue;

		private readonly String mDebugName = new .() ~ delete _;

		private void ProcessValidationCommands(CommandBufferValidator* commandBuffers, uint32 commandBufferNum)
		{
			mDevice.GetLock().Enter();



			readonly ProcessValidationCommandMethod[] table = scope .(
				=> this.ProcessValidationCommandBeginQuery, // ValidationCommandType::BEGIN_QUERY
				=> this.ProcessValidationCommandEndQuery, // ValidationCommandType::END_QUERY
				=> this.ProcessValidationCommandResetQuery // ValidationCommandType::RESET_QUERY
				);

			for (int i = 0; i < commandBufferNum; i++)
			{
				readonly List<uint8> buffer = commandBuffers[i].GetValidationCommands();
				readonly uint8* begin = buffer.Ptr;
				readonly uint8* end = buffer.Ptr + buffer.Count;

				while (begin != end)
				{
					readonly ValidationCommandType type = *(ValidationCommandType*)begin;

					if (type == ValidationCommandType.NONE || type >= ValidationCommandType.MAX_NUM)
					{
						REPORT_ERROR(mDevice.GetLogger(), "Invalid validation command: {}", (uint32)type);
						break;
					}

					readonly ProcessValidationCommandMethod method = table[(int)type - 1];
					method(this, begin, end);
				}
			}

			mDevice.GetLock().Exit();
		}

		private  void ProcessValidationCommandBeginQuery(uint8* begin, uint8* end)
		{
			readonly ValidationCommandUseQuery* command = ReadCommand<ValidationCommandUseQuery>(begin, end);
			CHECK!(mDevice.GetLogger(), command != null, "ProcessValidationCommandBeginQuery() failed: can't parse command.");
			CHECK!(mDevice.GetLogger(), command.queryPool != null, "ProcessValidationCommandBeginQuery() failed: query pool is invalid.");

			QueryPoolValidator queryPool = (QueryPoolValidator)command.queryPool;
			readonly bool used = queryPool.SetQueryState(command.queryPoolOffset, true);

			if (used)
			{
				REPORT_ERROR(mDevice.GetLogger(), "Can't begin query: it must be reset before use. (QueryPool='{}', offset={})",
					queryPool.GetDebugName(), command.queryPoolOffset);
			}
		}

		private void ProcessValidationCommandEndQuery(uint8* begin, uint8* end)
		{
			readonly ValidationCommandUseQuery* command = ReadCommand<ValidationCommandUseQuery>(begin, end);
			CHECK!(mDevice.GetLogger(), command != null, "ProcessValidationCommandEndQuery() failed: can't parse command.");
			CHECK!(mDevice.GetLogger(), command.queryPool != null, "ProcessValidationCommandEndQuery() failed: query pool is invalid.");

			QueryPoolValidator queryPool = (QueryPoolValidator)command.queryPool;
			readonly bool used = queryPool.SetQueryState(command.queryPoolOffset, true);

			if (queryPool.GetQueryType() == QueryType.TIMESTAMP)
			{
				if (used)
				{
					REPORT_ERROR(mDevice.GetLogger(), "Can't end query: it must be reset before use. (QueryPool='{}', offset={})",
						queryPool.GetDebugName(), command.queryPoolOffset);
				}
			}
			else
			{
				if (!used)
				{
					REPORT_ERROR(mDevice.GetLogger(), "Can't end query: it's not in active state. (QueryPool='{}', offset={})",
						queryPool.GetDebugName(), command.queryPoolOffset);
				}
			}
		}

		private void ProcessValidationCommandResetQuery(uint8* begin, uint8* end)
		{
			readonly ValidationCommandResetQuery* command = ReadCommand<ValidationCommandResetQuery>(begin, end);
			CHECK!(mDevice.GetLogger(), command != null, "ProcessValidationCommandResetQuery() failed: can't parse command.");
			CHECK!(mDevice.GetLogger(), command.queryPool != null, "ProcessValidationCommandResetQuery() failed: query pool is invalid.");

			QueryPoolValidator queryPool = (QueryPoolValidator)command.queryPool;
			queryPool.ResetQueries(command.queryPoolOffset, command.queryNum);
		}

		public this(DeviceValidator device, CommandQueue commandQueue)
		{
			mDevice = device;
			mCommandQueue = commandQueue;
		}

		public override void SetDebugName(StringView name)
		{
			mDebugName.Set(name);
			mCommandQueue.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override void Submit(WorkSubmissionDesc workSubmissionDesc, DeviceSemaphore deviceSemaphore)
		{
			ProcessValidationCommands((CommandBufferValidator*)workSubmissionDesc.commandBuffers, workSubmissionDesc.commandBufferNum);

			var workSubmissionDescImpl = workSubmissionDesc;
			workSubmissionDescImpl.commandBuffers = scope List<CommandBuffer>() { Count = workSubmissionDesc.commandBufferNum }.Ptr; //STACK_ALLOC!<CommandBuffer*>(workSubmissionDesc.commandBufferNum);
			for (uint32 i = 0; i < workSubmissionDesc.commandBufferNum; i++)
				((CommandBuffer*)workSubmissionDescImpl.commandBuffers)[i] = workSubmissionDesc.commandBuffers[i];

			workSubmissionDescImpl.wait = scope List<QueueSemaphore>() { Count = workSubmissionDesc.waitNum }.Ptr; //STACK_ALLOC(QueueSemaphore*, workSubmissionDesc.waitNum);
			for (uint32 i = 0; i < workSubmissionDesc.waitNum; i++)
				((QueueSemaphore*)workSubmissionDescImpl.wait)[i] = workSubmissionDesc.wait[i];

			workSubmissionDescImpl.signal = scope List<QueueSemaphore>() { Count = workSubmissionDesc.signalNum }.Ptr; //STACK_ALLOC(QueueSemaphore*, workSubmissionDesc.signalNum);
			for (uint32 i = 0; i < workSubmissionDesc.signalNum; i++)
				((QueueSemaphore*)workSubmissionDescImpl.signal)[i] = workSubmissionDesc.signal[i];

			for (uint32 i = 0; i < workSubmissionDesc.waitNum; i++)
			{
				QueueSemaphoreValidator semaphore = (QueueSemaphoreValidator)workSubmissionDesc.wait[i];
				semaphore.Wait();
			}

			mCommandQueue.Submit(workSubmissionDescImpl, deviceSemaphore);

			for (uint32 i = 0; i < workSubmissionDesc.signalNum; i++)
			{
				QueueSemaphoreValidator semaphore = (QueueSemaphoreValidator)workSubmissionDesc.signal[i];
				semaphore.Signal();
			}

			if (deviceSemaphore != null)
				((DeviceSemaphoreValidator)deviceSemaphore).Signal();
		}

		public override void Wait(DeviceSemaphore deviceSemaphore)
		{
			((DeviceSemaphoreValidator)deviceSemaphore).Wait();

			mCommandQueue.Wait(deviceSemaphore);
		}

		public override Result ChangeResourceStates(TransitionBarrierDesc transitionBarriers)
		{
			BufferTransitionBarrierDesc* bufferTransitionBarriers = STACK_ALLOC!<BufferTransitionBarrierDesc>(transitionBarriers.bufferNum);
			TextureTransitionBarrierDesc* textureTransitionBarriers = STACK_ALLOC!<TextureTransitionBarrierDesc>(transitionBarriers.textureNum);

			for (uint32 i = 0; i < transitionBarriers.bufferNum; i++)
			{
				if (!ValidateTransitionBarrierDesc(mDevice, i, transitionBarriers.buffers[i]))
					return Result.INVALID_ARGUMENT;

				BufferValidator bufferVal = (BufferValidator)transitionBarriers.buffers[i].buffer;

				bufferTransitionBarriers[i] = transitionBarriers.buffers[i];
				bufferTransitionBarriers[i].buffer = bufferVal;
			}

			for (uint32 i = 0; i < transitionBarriers.textureNum; i++)
			{
				if (!ValidateTransitionBarrierDesc(mDevice, i, transitionBarriers.textures[i]))
					return Result.INVALID_ARGUMENT;

				TextureValidator textureVal = (TextureValidator)transitionBarriers.textures[i].texture;

				textureTransitionBarriers[i] = transitionBarriers.textures[i];
				textureTransitionBarriers[i].texture = textureVal;
			}

			TransitionBarrierDesc transitionBarriersImpl = transitionBarriers;
			transitionBarriersImpl.buffers = bufferTransitionBarriers;
			transitionBarriersImpl.textures = textureTransitionBarriers;

			return mCommandQueue.ChangeResourceStates(transitionBarriersImpl);
		}

		public override Result UploadData(TextureUploadDesc* textureUploadDescs, uint32 textureUploadDescNum, BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum)
		{
			RETURN_ON_FAILURE!(mDevice.GetLogger(), textureUploadDescNum == 0 || textureUploadDescs != null, Result.INVALID_ARGUMENT,
				"Can't upload data: 'textureUploadDescs' is invalid.");

			RETURN_ON_FAILURE!(mDevice.GetLogger(), bufferUploadDescNum == 0 || bufferUploadDescs != null, Result.INVALID_ARGUMENT,
				"Can't upload data: 'bufferUploadDescs' is invalid.");

			TextureUploadDesc* textureUploadDescsImpl = STACK_ALLOC!<TextureUploadDesc>(textureUploadDescNum);

			for (uint32 i = 0; i < textureUploadDescNum; i++)
			{
				if (!ValidateTextureUploadDesc(mDevice, i, textureUploadDescs[i]))
					return Result.INVALID_ARGUMENT;

				TextureValidator textureVal = (TextureValidator)textureUploadDescs[i].texture;

				textureUploadDescsImpl[i] = textureUploadDescs[i];
				textureUploadDescsImpl[i].texture = textureVal;
			}

			BufferUploadDesc* bufferUploadDescsImpl = STACK_ALLOC!<BufferUploadDesc>(bufferUploadDescNum);

			for (uint32 i = 0; i < bufferUploadDescNum; i++)
			{
				if (!ValidateBufferUploadDesc(mDevice, i, bufferUploadDescs[i]))
					return Result.INVALID_ARGUMENT;

				BufferValidator bufferVal = (BufferValidator)bufferUploadDescs[i].buffer;

				bufferUploadDescsImpl[i] = bufferUploadDescs[i];
				bufferUploadDescsImpl[i].buffer = bufferVal;
			}

			return mCommandQueue.UploadData(textureUploadDescsImpl, textureUploadDescNum, bufferUploadDescsImpl, bufferUploadDescNum);
		}

		public override Result WaitForIdle()
		{
			return mCommandQueue.WaitForIdle();
		}
	}
}
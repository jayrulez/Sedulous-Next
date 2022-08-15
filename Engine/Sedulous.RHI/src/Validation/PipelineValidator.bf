using System;
namespace Sedulous.RHI.Validation
{
	class PipelineValidator : Pipeline
	{
		private readonly DeviceValidator mDevice;
		private Pipeline mPipeline;
		private readonly PipelineLayout m_PipelineLayout = null;

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, Pipeline pipeline)
		{
			mDevice = device;
			mPipeline = pipeline;
			m_PipelineLayout = null;
		}

		public this(DeviceValidator device, Pipeline pipeline,  GraphicsPipelineDesc graphicsPipelineDesc)
		{
			mDevice = device;
			mPipeline = pipeline;
			m_PipelineLayout = graphicsPipelineDesc.pipelineLayout;
		}

		public this(DeviceValidator device, Pipeline pipeline,  ComputePipelineDesc computePipelineDesc)
		{
			mDevice = device;
			mPipeline = pipeline;
			m_PipelineLayout = computePipelineDesc.pipelineLayout;
		}

		public this(DeviceValidator device, Pipeline pipeline,  RayTracingPipelineDesc rayTracingPipelineDesc)
		{
			mDevice = device;
			mPipeline = pipeline;
			m_PipelineLayout = rayTracingPipelineDesc.pipelineLayout;
		}

		public ref Pipeline GetImpl() => ref mPipeline;

		public PipelineLayout GetPipelineLayout()
		{
			return m_PipelineLayout;
		}

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mPipeline.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override Result WriteShaderGroupIdentifiers(uint32 baseShaderGroupIndex, uint32 shaderGroupNum, void* buffer)
		{
			return mPipeline.WriteShaderGroupIdentifiers(baseShaderGroupIndex, shaderGroupNum, buffer);
		}
	}
}
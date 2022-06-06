using System;
namespace Sedulous.RHI
{
	abstract class Pipeline
	{
		public abstract void SetDebugName(in StringView name);
		
		public abstract Result WriteShaderGroupIdentifiers(uint32 baseShaderGroupIndex, uint32 shaderGroupNum, void* buffer);
	}
}
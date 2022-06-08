using System;
namespace Sedulous.RHI
{
	abstract class QueryPool
	{
		public abstract void SetDebugName(StringView name);

		public abstract uint32 GetQuerySize();
	}
}
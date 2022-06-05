namespace Sedulous.RHI
{
	abstract class QueryPool
	{
		public struct Description
		{
		}
		
		public abstract Device Device {get;}
		
		public abstract uint32 Count {get;}
	}
}
namespace Sedulous.RHI
{
	abstract class Fence
	{
		public abstract Device Device {get;}
		public abstract FenceStatus GetStatus();
	}
}
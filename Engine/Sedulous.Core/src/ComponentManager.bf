namespace Sedulous.Core
{
	abstract class ComponentManager : WorldModule
	{
		public this(World world) : base(world) { }
	}

	class ComponentManager<T> : ComponentManager where T : Component
	{
		public this(World world) : base(world) { }
	}
}
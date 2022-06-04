using System;
using System.Collections;
namespace Sedulous.Core
{
	class WorldModule
	{
		typealias UpdateFunction = delegate void();

		private readonly World mWorld;

		public World World => mWorld;

		public this(World world)
		{
			mWorld = world;
		}

		public virtual Result<void> Initialize() => .Ok;
		public virtual void Activate() => void();
		public virtual Result<void> Shutdown() => .Ok;

		public void AddUpdateFunction()
		{
		}

		public void RemoveUpdateFunction()
		{
		}
	}
}
using System.Collections;
using System.Threading;
using Sedulous.Foundation.Utilities;
namespace Sedulous.Core;

enum WorldUpdatePhase
{
	PreUpdate,
	Update,
	PostUpdate,
	FixedUpdate
}

class World
{
	private readonly Clock mWorldClock = new .() ~ delete _;
	private readonly Monitor mModulesMonitor = new .() ~ delete _;
	private readonly List<WorldModule> mModules = new .() ~ delete _;
	private readonly List<WorldModule> mModulesToActivate = new .() ~ delete _;

	public WorldModule GetOrCreateModule<T>() where T : WorldModule
	{
		using (mModulesMonitor.Enter())
		{
			for (var module in mModules)
			{
				if ((module as T) != null)
				{
					return module;
				}
			}

			WorldModule module = new T();
			module.Initialize();

			mModules.Add(module);

			mModulesToActivate.Add(module);

			return module;
		}
	}

	public void RemoveModule<T>() where T : WorldModule
	{
		using (mModulesMonitor.Enter())
		{
			WorldModule moduleToRemove = null;

			for (var module in mModules)
			{
				if ((module as T) != null)
				{
					moduleToRemove = module;
					break;
				}
			}

			if (moduleToRemove == null)
				return;

			moduleToRemove.Shutdown();

			mModules.Remove(moduleToRemove);

			delete moduleToRemove;
		}
	}

	public void RemoveModule(WorldModule moduleToRemove)
	{
		using (mModulesMonitor.Enter())
		{
			bool moduleFound = false;
			for (var module in mModules)
			{
				if (module == moduleToRemove)
				{
					moduleFound = true;
					break;
				}
			}

			if (!moduleFound)
				return;

			moduleToRemove.Shutdown();

			mModules.Remove(moduleToRemove);

			delete moduleToRemove;
		}
	}

	public void Update()
	{
		mWorldClock.Update();

		// Initialize components
		// Activate World Modules
		// Register update functions

		// Run pre-update functions
		// Run update functions
		// Run post-update functions

		// Remove dead entities, and world modules
	}
}
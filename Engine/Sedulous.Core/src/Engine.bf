using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using System.Threading;
using Sedulous.Foundation.Utilities;
using System;
using Sedulous.Core.Jobs;
using Sedulous.Core.Assets;
using System.IO;
using Sedulous.Core.World;
namespace Sedulous.Core;

class EngineConfig
{
	public readonly List<Plugin> Plugins = new List<Plugin>() ~ delete _;

	public String ResourceDirectory { get; private set; } = new .() ~ delete _;

	public void SetResourceDirectory(StringView resourceDirectory)
	{
		ResourceDirectory.Set(resourceDirectory);
	}
}

class Engine
{
	private readonly Clock mEngineClock = new .() ~ delete _;
	private readonly Monitor mWorldsMonitor = new .() ~ delete _;
	private readonly List<World> mWorlds = new .() ~ delete _;
	private readonly List<Plugin> mPlugins = new List<Plugin>() ~ delete _;
	private readonly JobSystem mJobSystem = null;
	private readonly AssetSystem mResourceSystem = null;
	private readonly String mResourcesDirectory = new .() ~ delete _;

	public JobSystem JobSytem => mJobSystem;
	public AssetSystem ResourceSytem => mResourceSystem;

	public ILogger Logger { get; private set; }

	public this(ILogger logger)
	{
		Logger = logger;
		mJobSystem = new .(this, 16);
		mResourceSystem = new .(this);
	}

	public ~this()
	{
		delete mResourceSystem;
		delete mJobSystem;
	}

	private void Configure(EngineConfig config)
	{
		mPlugins.AddRange(config.Plugins);
		mResourcesDirectory.Set(config.ResourceDirectory);
	}

	private void Startup()
	{
		mJobSystem.Startup();
		mResourceSystem.Startup();

		for (var plugin in mPlugins)
		{
			plugin.OnStartup(this);
		}
	}

	private void Shutdown()
	{
		for (int i = mPlugins.Count - 1; i >= 0; i--)
		{
			mPlugins[i].OnShutdown();
		}

		mResourceSystem.Shutdown();
		mJobSystem.Shutdown();
	}

	private void Tick()
	{
		mJobSystem?.Update();
		mResourceSystem?.Update();

		for (World world in mWorlds)
		{
			//mJobSystem.RunJob(new => world.Update, "World Update");
			world.Update();
		}
	}

	public World CreateWorld()
	{
		using (mWorldsMonitor.Enter())
		{
			World world = new World();

			mWorlds.Add(world);

			return world;
		}
	}

	public void DestroyWorld(World world)
	{
		mWorlds.Remove(world);
		delete world;
	}
}
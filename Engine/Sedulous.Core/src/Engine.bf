using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using System.Threading;
using Sedulous.Foundation.Utilities;
using System;
using Sedulous.Core.Jobs;
using Sedulous.Core.Resources;
namespace Sedulous.Core;

class Engine
{
	private readonly Clock mEngineClock = new .() ~ delete _;
	private readonly Monitor mWorldsMonitor = new .() ~ delete _;
	private readonly List<World> mWorlds = new .() ~ delete _;
	private readonly List<Plugin> mPlugins = new List<Plugin>() ~ delete _;
	private readonly JobSystem mJobSystem = null;
	private readonly ResourceSystem mResourceSystem = null;

	public JobSystem JobSytem => mJobSystem;
	public ResourceSystem ResourceSytem => mResourceSystem;

	public ILogger Logger { get; private set; }

	public this(ILogger logger, Span<Plugin> plugins)
	{
		Logger = logger;
		mPlugins.AddRange(plugins);
		mJobSystem = new .(this, 16);
		mResourceSystem = new .(this);
	}

	public ~this()
	{
		delete mResourceSystem;
		delete mJobSystem;
	}

	public void Startup()
	{
		mJobSystem.Startup();
		mResourceSystem.Startup();

		for (var plugin in mPlugins)
		{
			plugin.OnStartup();
		}
	}

	public void Initialize()
	{
		for (var plugin in mPlugins)
		{
			plugin.OnInitialize();
		}
	}

	public void Shutdown()
	{
		for (int i = mPlugins.Count - 1; i >= 0; i--)
		{
			mPlugins[i].OnShutdown();
		}

		mResourceSystem.Shutdown();
		mJobSystem.Shutdown();
	}

	public void Tick()
	{
		mJobSystem.Update();
		mResourceSystem.Update();

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
		delete world;
	}
}
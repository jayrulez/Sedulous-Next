using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using System.Threading;
using Sedulous.Foundation.Utilities;
using System;
namespace Sedulous.Core;

class Engine
{
	private readonly Clock mEngineClock = new .() ~ delete _;
	private readonly Monitor mWorldsMonitor = new .() ~ delete _;
	private readonly List<World> mWorlds = new .() ~ delete _;
	private readonly List<Plugin> mPlugins = new List<Plugin>() ~ delete _;
	private readonly JobSystem mJobSystem = null;

	public JobSystem JobSytem => mJobSystem;

	public ILogger Logger { get; private set; }

	public this(ILogger logger, Span<Plugin> plugins)
	{
		Logger = logger;
		mPlugins.AddRange(plugins);
		mJobSystem = new .(this, 2);
	}

	public ~this()
	{
		delete mJobSystem;
	}

	public void Startup()
	{
		mJobSystem.[Friend]Startup();

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

		mJobSystem.Wait();
		mJobSystem.[Friend]Shutdown();
	}

	public void Tick()
	{
		mJobSystem.[Friend]Update();
		for (World world in mWorlds)
		{
			mJobSystem.RunJob(new => world.Update, "World Update");
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
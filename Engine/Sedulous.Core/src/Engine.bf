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
	private List<World> mWorlds = new .() ~ delete _;
	private List<Plugin> mPlugins = new List<Plugin>() ~ delete _;

	public ILogger Logger { get; private set; }

	public this(ILogger logger, Span<Plugin> plugins)
	{
		Logger = logger;
		mPlugins.AddRange(plugins);
	}

	public void Startup()
	{
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
	}

	public void Tick() { }
}
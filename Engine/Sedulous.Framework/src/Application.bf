using Sedulous.Core;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using System.Collections;
namespace Sedulous.Framework;

abstract class Application
{
	private bool mIsRunning = false;
	protected readonly Engine mEngine = null ~ delete _;
	protected readonly List<Plugin> mPlugins = new .() ~ delete _;

	public readonly ILogger Logger {get; private set;}

	public this(ILogger logger)
	{
		mEngine = new Engine(Logger = logger);
	}

	protected virtual Result<void> OnStartup(EngineConfig config) => .Ok;

	protected virtual Result<void> OnInitialize() => .Ok;

	protected virtual void OnFinalize() => void();

	protected virtual void OnShutdown() => void();

	protected virtual void OnFrameBegin() => void();

	protected virtual void OnFrameEnd() => void();

	private Result<void> Startup()
	{
			EngineConfig config = scope .();

		if (OnStartup(config) case .Err)
			return .Err;

		mEngine.[Friend]Configure(config);
		mEngine.[Friend]Startup();

		return .Ok;
	}

	private Result<void> Initialize()
	{
		if (OnInitialize() case .Err)
			return .Err;

		return .Ok;
	}

	private void Shutdown()
	{
		mEngine.[Friend]Shutdown();
		OnShutdown();
	}

	private void RunFrame()
	{
		OnFrameBegin();
		mEngine.[Friend]Tick();
		OnFrameEnd();
	}

	public void Run()
	{
		if (mIsRunning)
		{
			return;
		}

		if (Startup() case .Err)
		{
			OnShutdown();
			return;
		}

		if (Initialize() case .Err)
		{
			OnFinalize();
			Shutdown();
			return;
		}
		mIsRunning = true;

		while (mIsRunning)
		{
			RunFrame();
		}

		OnFinalize();
		Shutdown();
	}

	public void Stop()
	{
		mIsRunning = false;
	}
}
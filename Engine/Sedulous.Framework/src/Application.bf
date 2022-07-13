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

	public ILogger Logger => mEngine.Logger;

	public this(ILogger logger)
	{
		mEngine = new Engine(logger);
	}

	protected virtual Result<void> OnStartup() => .Ok;

	protected virtual Result<void> OnInitialize() => .Ok;

	protected virtual void OnFinalize() => void();

	protected virtual void OnShutdown() => void();

	protected virtual void OnFrameBegin() => void();

	protected virtual void OnFrameEnd() => void();

	private Result<void> Startup()
	{
		if (OnStartup() case .Err)
			return .Err;

		mEngine.Startup(mPlugins);

		return .Ok;
	}

	private Result<void> Initialize()
	{
		if (OnInitialize() case .Err)
			return .Err;

		mEngine.Initialize();

		return .Ok;
	}

	private void Shutdown()
	{
		mEngine.Shutdown();
		OnShutdown();
	}

	private void RunFrame()
	{
		OnFrameBegin();
		mEngine.Tick();
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
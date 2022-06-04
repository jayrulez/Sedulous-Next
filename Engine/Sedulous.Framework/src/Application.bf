using Sedulous.Core;
using Sedulous.Foundation.Logging.Abstractions;
using System;
namespace Sedulous.Framework
{
	abstract class Application
	{
		private bool mIsRunning = false;
		protected readonly Engine mEngine = null ~ delete _;

		public ILogger Logger => mEngine.Logger;

		public this(ILogger logger)
		{
			mEngine = new Engine(logger);
		}

		protected virtual Result<void> OnStartup() => .Ok;

		protected virtual Result<void> OnInitialize() => .Ok;

		protected virtual void OnShutdown()
		{
		}

		protected virtual void OnFrameBegin()
		{
		}

		protected virtual void OnFrameEnd()
		{
		}

		private Result<void> Startup()
		{
			if(OnStartup() case .Err)
				return .Err;

			mEngine.Startup();

			return .Ok;
		}

		private Result<void> Initialize()
		{
			if(OnInitialize() case .Err)
				return .Err;

			mEngine.Initialize();

			return .Ok;
		}

		private void Shutdown()
		{
			OnShutdown();
			mEngine.Shutdown();
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

			if(Startup() case .Err)
				return;

			if(Initialize() case .Err)
				return;

			mIsRunning = true;

			while (mIsRunning)
			{
				RunFrame();
			}

			Shutdown();
		}

		public void Stop()
		{
			mIsRunning = false;
		}
	}
}
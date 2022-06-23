using Sedulous.SDL;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Foundation.Logging.Debug;
using Sedulous.Core;
using System.Collections;
using System.Threading;
namespace CoreTest.Engine
{
	class PrintJob : Job
	{
		private String mText = new .() ~ delete _;
		public this(StringView text, StringView name, JobFlags flags = .None) : base(name, flags)
		{
			mText.Set(text);
		}

		public override void Execute()
		{
			var Random = scope Random();
			int32 sleepFor = Random.Next(2000);
			Console.WriteLine("{} {}", mText, sleepFor);
			Thread.Sleep(sleepFor);
		}
	}

	class CoreTestApplication : SDLApplication
	{
		private readonly ILogger mLogger = null ~ delete _;

		private List<Job> mJobs = new .() ~ DeleteContainerAndItems!(_);

		private World mWorld = null;

		public this(String windowTitle, uint windowWidth, uint windowHeight)
			: base(mLogger = new DebugLogger(), windowTitle, windowWidth, windowHeight)
		{
		}

		protected override Result<void> OnInitialize()
		{
			if (base.OnInitialize() case .Err)
				return .Err;

			for (int i = 0; i < 20; i++)
			{
				JobFlags flags = .None;
				if (i % 2 == 0)
					flags = .RunOnMainThread;

				mEngine.JobSytem.RunJob(mJobs.Add(.. new PrintJob("Hello", scope $"PrintJob{i+1}", flags)));
			}

			mWorld = mEngine.CreateWorld();

			return .Ok;
		}

		protected override void OnFinalize()
		{
			mEngine.DestroyWorld(mWorld);

			base.OnFinalize();
		}

	}
}
using System.Collections;
using System;
using System.Threading;
using Sedulous.Foundation.Logging.Abstractions;
using static System.Platform;
namespace Sedulous.Core
{
	using internal Sedulous.Core;

	enum JobPriority
	{
		Normal,
		Critical
	}

	enum JobFlags
	{
		None,
		RunOnMainThread,
		DeleteOnCompleted
	}

	enum JobState
	{
		Pending,
		Running,
		Completed,
		Canceled
	}

	abstract class Job
	{
		private readonly String mName = new .() ~ delete _;
		private readonly JobFlags mFlags = .None;
		private JobState mState = .Pending;

		private List<Job> mDependencies = new .() ~ delete _;
		private List<Job> mDependents = new .() ~ delete _;

		public String Name => mName;
		public JobFlags Flags => mFlags;
		public JobState State => mState;

		public this(StringView name, JobFlags flags = .None)
		{
			mName.Set(name);
			mFlags = flags;
		}

		public void AddDependency(Job dependency)
		{
			if (dependency == this)
				Runtime.FatalError("Job cannot depend on itself.");

			if (dependency.mDependencies.Contains(this))
				Runtime.FatalError("The dependency already depends on the current job.");

			mDependencies.Add(dependency);
			dependency.mDependents.Add(this);
		}

		public virtual bool IsReady()
		{
			for (Job dependency in mDependencies)
			{
				if (!dependency.IsReady())
					return false;
			}

			return mState == .Pending;
		}

		public abstract void Execute();

		public virtual void Cancel()
		{
			if (mState != .Completed)
				mState = .Canceled;
		}

		private void Run()
		{
			if (!IsReady())
				return;

			mState = .Running;
			Execute();
			if (mState != .Canceled)
				mState = .Completed;
		}
	}

	class SimpleJob : Job
	{
		private readonly delegate void() mDelegate ~ delete _;

		public this(delegate void() jobDelegate,  StringView name, JobFlags flags)
			: base(name, flags)
		{
			mDelegate = jobDelegate;
		}

		public ~this()
		{
		}

		public override void Execute()
		{
			mDelegate?.Invoke();
		}
	}

	sealed class JobGroup : Job
	{
		private List<Job> mJobs = new .() ~ delete _;

		public this(StringView name, JobFlags flags = .None) : base(name, flags)
		{
		}

		public ~this()
		{
		}

		public override void Cancel()
		{
			for (Job job in mJobs)
			{
				job.Cancel();
			}
			base.Cancel();
		}

		public override void Execute()
		{
			for (Job job in mJobs)
			{
				job.Execute();
			}
		}

		public void AddJob(Job job)
		{
			mJobs.Add(job);
		}
	}

	enum WorkerState
	{
		Idle,
		Busy
	}

	internal class Worker
	{
		private readonly String mName = new .() ~ delete _;
		private readonly JobSystem mJobSystem = null;
		private readonly Thread mThread = null;
		private readonly bool mOwnsThread = false;
		private bool mIsRunning = false;

		private WorkerState mState = .Idle;

		private Monitor mJobQueueMonitor = new .() ~ delete _;
		private Queue<Job> mJobQueue = new .() ~ delete _;

		public String Name => mName;
		public WorkerState State => mState;

		internal delegate void(Job job, Worker worker) OnJobCompleted;
		internal delegate void(Job job, Worker worker) OnJobCanceled;

		public this(JobSystem jobSystem, Thread thread, String name = null)
		{
			mJobSystem = jobSystem;
			mThread = thread;

			if (name != null)
			{
				mName.Set(name);
			} else
			{
				mName.Set(mThread.GetName(.. scope .()));
			}
		}

		public this(JobSystem jobSystem, String name = null)
		{
			mJobSystem = jobSystem;
			mOwnsThread = true;

			if (name != null)
			{
				mName.Set(name);
			} else
			{
				mName.Set("Worker");
			}

			mThread = new Thread(new => this.RunQueuedJobs);
			mThread.SetName(mName);
		}

		public ~this()
		{
			if (mOwnsThread)
			{
				Stop();
				delete mThread;
			}
		}

		public void QueueJobs(Span<Job> jobs)
		{
			using (mJobQueueMonitor.Enter())
			{
				for (Job job in jobs)
					mJobQueue.Add(job);
			}
		}

		public void QueueJob(Job job)
		{
			using (mJobQueueMonitor.Enter())
			{
				mJobQueue.Add(job);
			}
		}

		private void Start()
		{
			mIsRunning = true;
			if (mOwnsThread)
				mThread.Start(false);
		}

		private void Stop()
		{
			using (mJobQueueMonitor.Enter())
			{
				while (mJobQueue.Count > 0)
				{
					Job job = mJobQueue.PopFront();
					job?.Cancel();
				}
			}

			if (mIsRunning)
			{
				mIsRunning = false;
				if (mOwnsThread)
					mThread.Join();
			}
		}

		private void RunQueuedJobs()
		{
			while (mIsRunning)
			{
				while (mJobQueue.Count > 0)
				{
					mState = .Busy;
					Job job = null;

					using (mJobQueueMonitor.Enter())
					{
						job = mJobQueue.PopFront();
						if (!job.IsReady())
						{
							mJobQueue.Add(job);
							continue;
						}
					}

					if (job != null)
					{
						mJobSystem.Logger.LogInformation("Worker: {} - Running job: {}.", mName, job.Name);
						job?.[Friend]Run();

						if (job.State == .Canceled)
							OnJobCanceled?.Invoke(job, this);

						if (job.State == .Completed)
							OnJobCompleted?.Invoke(job, this);

						if (job.Flags.HasFlag(.DeleteOnCompleted))
							delete job;
					}
				}

				mState = .Idle;
			}
		}

		private void RunJob(Job job)
		{
		}
	}

	class JobSystem
	{
		private readonly Engine mEngine = null;
		private readonly Worker mMainThreaWorker = null;
		private readonly List<Worker> mWorkers = new .() ~ delete _;

		public int WorkerCount => (mWorkers?.Count ?? 0) + 1;

		private readonly List<Job> mJobsToRun = new .() ~ delete _;

		public ILogger Logger => mEngine.Logger;

		public this(Engine engine, int workerCount = 0)
		{
			mEngine = engine;

			var workerCount;
			if (workerCount < 1)
				workerCount = 1;

			BfpSystemResult result = .Ok;
			int coreCount = Platform.BfpSystem_GetNumLogicalCPUs(&result);
			if (result == .Ok)
			{
				workerCount = Math.Min(workerCount, coreCount - 1);
			}

			mMainThreaWorker = new Worker(this, Thread.sMainThread, "Main");

			for (int i = 0; i < workerCount; i++)
			{
				mWorkers.Add(new Worker(this, scope $"Worker {i}"));
			}
		}

		public ~this()
		{
			for (Worker worker in mWorkers)
			{
				delete worker;
			}
			mWorkers.Clear();

			delete mMainThreaWorker;
		}

		private void Startup()
		{
			mMainThreaWorker.[Friend]Start();
			for (Worker worker in mWorkers)
			{
				worker.[Friend]Start();
			}
		}

		private void Shutdown()
		{
			for (Worker worker in mWorkers)
			{
				worker.[Friend]Stop();
			}
			mMainThreaWorker.[Friend]Stop();
		}

		private void Update()
		{
			for (int i = 0; i < mJobsToRun.Count; i++)
			{
				// If job should be run on main thread
				if (mJobsToRun[i].Flags.HasFlag(.RunOnMainThread))
				{
					mMainThreaWorker.QueueJob(mJobsToRun[i]);
					mJobsToRun.RemoveAt(i--);
					continue;
				}

				// find a worker and queue pending jobs
				for (Worker worker in mWorkers)
				{
					if (worker.State == .Idle)
					{
						Logger.LogInformation("Queued job {} on {}.", mJobsToRun[i].Name, worker.Name);

						worker.QueueJob(mJobsToRun[i]);

						mJobsToRun.RemoveAt(i--);
						break;
					}
				}
			}
			// remove finished jobs
		}

		public void RunJob(Job job)
		{
			mJobsToRun.Add(job);
		}

		public void RunJob(delegate void() jobDelegate, StringView name)
		{
			Job job = new SimpleJob(jobDelegate, name, .DeleteOnCompleted);
			RunJob(job);
		}

		public void Wait()
		{
			bool working = true;
			while (working)
			{
				working = false;
				for (Worker worker in mWorkers)
				{
					if (worker.State != .Idle)
					{
						working = true;
					}
				}
			}
		}
	}
}
using System.Collections;
using Sedulous.Foundation.Logging.Abstractions;
using System.Threading;
using System;
using static System.Platform;
namespace Sedulous.Core.Jobs;

using internal Sedulous.Core.Jobs;

class JobSystem
{
	private readonly Engine mEngine = null;
	private readonly List<Worker> mWorkers = new .() ~ delete _;

	private readonly Monitor mJobsToRunMonitor = new .() ~ delete _;
	private readonly Queue<Job> mJobsToRun = new .() ~ delete _;

	private readonly Monitor mCompletedJobsMonitor = new .() ~ delete _;
	private readonly List<Job> mCompletedJobs = new .() ~ delete _;

	private readonly Monitor mCancelledJobsMonitor = new .() ~ delete _;
	private readonly List<Job> mCancelledJobs = new .() ~ delete _;
	
	private bool mIsRunning = false;

	public int WorkerCount => mWorkers?.Count ?? 0;

	public ILogger Logger => mEngine.Logger;

	public this(Engine engine, int workerCount = 0)
	{
		var workerCount;

		mEngine = engine;

		workerCount = Math.Max(1, workerCount);

		BfpSystemResult result = .Ok;
		int coreCount = Platform.BfpSystem_GetNumLogicalCPUs(&result);
		if (result == .Ok)
		{
			workerCount = Math.Min(workerCount, coreCount - 1);
		}

		for (int i = 0; i < workerCount; i++)
		{
			Worker worker = new Worker(this, scope $"Worker {i}", new => OnJobCompleted, new => OnJobCancelled);

			mWorkers.Add(worker);
		}
	}

	public ~this()
	{
		for (Worker worker in mWorkers)
		{
			delete worker;
		}
	}

	private void OnJobCompleted(Job job, Worker worker)
	{
		using (mCompletedJobsMonitor.Enter())
		{
			job.AddRef();
			mCompletedJobs.Add(job);
		}
	}

	private void OnJobCancelled(Job job, Worker worker)
	{
		using (mCancelledJobsMonitor.Enter())
		{
			job.AddRef();
			mCancelledJobs.Add(job);
		}
	}

	/*public void Wait()
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
	}*/

	public void Startup()
	{
		if (mIsRunning)
		{
			Logger.LogError("Startup called on JobSystem that is already running.");
			return;
		}

		for (Worker worker in mWorkers)
		{
			worker.Start();
		}

		mIsRunning = true;
	}

	public void Shutdown()
	{
		if (!mIsRunning)
		{
			Logger.LogError("Shutdown called on JobSystem that is not running.");
			return;
		}

		for (Worker worker in mWorkers)
		{
			worker.Stop();
		}

		while (mJobsToRun.Count > 0)
		{
			Job job = mJobsToRun.PopFront();
			defer job.ReleaseRef();
			job.Cancel();
			OnJobCancelled(job, null);
		}

		using (mCompletedJobsMonitor.Enter())
		{
			for (Job job in mCompletedJobs)
			{
				if (job.Flags.HasFlag(.AutoRelease))
				{
					job.ReleaseRef();
				}
				job.ReleaseRef();
			}
			mCompletedJobs.Clear();
		}

		using (mCancelledJobsMonitor.Enter())
		{
			for (Job job in mCancelledJobs)
			{
				if (job.Flags.HasFlag(.AutoRelease))
				{
					job.ReleaseRef();
				}
				job.ReleaseRef();
			}
			mCancelledJobs.Clear();
		}
	}

	private bool GetAvailableWorker(out Worker worker)
	{
		for (int i = 0; i < mWorkers.Count; i++)
		{
			if (mWorkers[i].State == .Idle || mWorkers[i].State == .Paused)
			{
				worker = mWorkers[i];
				return true;
			}
		}

		worker = null;
		return false;
	}

	public void Update()
	{
		if (!mIsRunning)
		{
			Logger.LogError("Update called on JobSystem that is not running.");
			return;
		}

		/*while (mJobsToRun.Count > 0)
		{
			for (Worker worker in mWorkers)
			{
				Job job = mJobsToRun.PopFront();
				if (job.State == .Completed)
				{
					OnJobCompleted(job, null);
					break;
				}
				if (job.State == .Cancelled)
				{
					OnJobCancelled(job, null);
					break;
				}
				worker.QueueJob(job);
			}
		}*/

		// todo: if there are no jobs for x frames then pause works to save CPU

		while (GetAvailableWorker(var worker) && mJobsToRun.Count > 0)
		{
			using (mJobsToRunMonitor.Enter())
			{
				Job job = mJobsToRun.PopFront();
				defer job.ReleaseRef();

				switch (job.State) {
				case .Canceled:
					OnJobCancelled(job, null);
					break;
				case .Completed:
					OnJobCompleted(job, null);
					break;
				default:
					worker.QueueJob(job);
					break;
				}
			}
		}

		// Todo: If there are no idle workers and job can be run on main thread
		// then run it

		// todo: change HasDependents to HasPendingOrRunningDependents() which will only return true if the dependents are pending
		// so that the job can be deleted if there are no pending or running dependents
		// Currently, any jobs with dependents do not get cleaned up until Shutdown

		using (mCompletedJobsMonitor.Enter())
		{
			for (int i = 0; i < mCompletedJobs.Count; i++)
			{
				Job job = mCompletedJobs[i];
				if (job.Flags.HasFlag(.AutoRelease) /* && !job.HasDependents*/)
				{
					// job.RemoveFromDependencyDependents();
					job.ReleaseRef();
					//mCompletedJobs.RemoveAt(i--);
				}
				job.ReleaseRef();
				mCompletedJobs.RemoveAt(i--);
			}
		}

		using (mCancelledJobsMonitor.Enter())
		{
			for (int i = 0; i < mCancelledJobs.Count; i++)
			{
				Job job = mCancelledJobs[i];
				if (job.Flags.HasFlag(.AutoRelease) /* && !job.HasDependents*/)
				{
					// job.RemoveFromDependencyDependents();
					job.ReleaseRef();
					//mCancelledJobs.RemoveAt(i--);
				}
				job.ReleaseRef();
				mCancelledJobs.RemoveAt(i--);
			}
		}
	}

	public void AddJob(Job job)
	{
		using (mJobsToRunMonitor.Enter())
		{
			job.AddRef();
			mJobsToRun.Add(job);
		}
	}

	public void AddJobs(Span<Job> jobs)
	{
		using (mJobsToRunMonitor.Enter())
		{
			for (Job job in jobs)
			{
				job.AddRef();
				mJobsToRun.Add(job);
			}
		}
	}

	public void AddJob(delegate void() jobDelegate, StringView/*?*/ jobName = null)
	{
		Job job = new DelegateJob(jobDelegate, jobName, .AutoRelease);
		AddJob(job);
	}
}
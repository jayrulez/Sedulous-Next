using System.Threading;
using System;
using System.Collections;
namespace Sedulous.Core.Jobs;


enum WorkerState
{
	Idle,
	Busy,
	Paused,
	Dead
}

internal class Worker
{
	private readonly JobSystem mJobSystem = null;
	private readonly String mName = new .() ~ delete _;
	private readonly Thread mThread = null;
	private bool mIsRunning = false;
	private WorkerState mState = .Paused;

	private Monitor mJobsMonitor = new .() ~ delete _;
	private Queue<Job> mJobs = new .() ~ delete _;

	public String Name => mName;
	public WorkerState State => mState;

	public delegate void(Job job, Worker worker) OnJobCompleted = null;
	public delegate void(Job job, Worker worker) OnJobCancelled = null;

	public this(JobSystem jobSystem,
		StringView name,
		delegate void(Job job, Worker worker) onJobCompleted = null,
		delegate void(Job job, Worker worker) onJobCancelled = null)
	{
		mJobSystem = jobSystem;
		mName.Set(name);

		mThread = new Thread(new => this.ProcessJobs);
		mThread.SetName(mName);

		OnJobCompleted = onJobCompleted;
		OnJobCancelled = onJobCancelled;
	}

	public ~this()
	{
		if (OnJobCompleted != null)
			delete OnJobCompleted;

		if (OnJobCancelled != null)
			delete OnJobCancelled;

		delete mThread;
	}

	public void Start()
	{
		if (mIsRunning)
		{
			mJobSystem.Logger.LogError("Start called on a worker '{}' that is already running.", mName);
			return;
		}

		mIsRunning = true;
		mThread.Start(false);
	}

	public void Stop()
	{
		if (!mIsRunning)
		{
			mJobSystem.Logger.LogError("Stop called on a worker '{}' that is not running.", mName);
			return;
		}

		// Ensure the last task is completed
		while (mState != .Idle) { }

		mIsRunning = false;
		mThread.Join();

		using (mJobsMonitor.Enter())
		{
			while (mJobs.Count > 0)
			{
				Job job = mJobs.PopFront();
				defer job.ReleaseRef();
				job.Cancel();
				if (OnJobCancelled != null)
					OnJobCancelled(job, this);
			}
		}
	}

	public void QueueJobs(Span<Job> jobs)
	{
		if (mState == .Paused)
			Resume();

		using (mJobsMonitor.Enter())
		{
			for (Job job in jobs)
			{
				mJobs.Add(job);
				job.AddRef();
			}
		}
	}

	public void QueueJob(Job job)
	{
		if (mState == .Paused)
			Resume();

		using (mJobsMonitor.Enter())
		{
			mJobs.Add(job);
			job.AddRef();
		}
	}

	public void Pause()
	{
		if (mState == .Idle)
		{
			mThread.Suspend();
			mState = .Paused;
		} else
		{
			mJobSystem.Logger.LogWarning("Pause called on worker that is not idle. The worker will not be paused.");
		}
	}

	public void Resume()
	{
		if (mState == .Paused)
		{
			mState = .Idle;
			mThread.Resume();
		} else
		{
			mJobSystem.Logger.LogWarning("Resume called on worker that is not paused.");
		}
	}

	private void ProcessJobs()
	{
		while (true)
		{
			if (!mIsRunning)
			{
				mState = .Dead;
				break;
			}

			while (mJobs.Count > 0)
			{
				if (!mIsRunning)
				{
					break;
				}

				mState = .Busy;

				Job job = null;
				using (mJobsMonitor.Enter())
					job = mJobs.PopFront();
				defer job.ReleaseRef();

				if (!job.IsReady())
				{
					// if the job is not ready to run,
					// re-queue with the job system to free up this worker ASAP
					//QueueJob(job); // don't want to always queue on this worker, possibly lead to deadlock, we're already inside the monitor and QueueJob will request to enter the Monitor
					//mJobs.Add(job); // not desirable to always requeue on same worker

					mJobSystem.AddJob(job);
					continue;
				}

				mJobSystem.Logger.LogInformation("Worker: {} - Running job: {}.", mName, job.Name);
				job.[Friend]Run();

				if (job.State == .Completed)
					OnJobCompleted(job, this);
				else if (job.State == .Canceled)
					OnJobCancelled(job, this);
			}

			mState = .Idle;
		}
	}
}
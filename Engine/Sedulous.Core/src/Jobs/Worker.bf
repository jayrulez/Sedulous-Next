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

class Worker
{
	private readonly JobSystem mJobSystem = null;
	private readonly String mName = new .() ~ delete _;

	private readonly Thread mThread = null;
	private bool mIsRunning = false;
	private WorkerState mState = .Paused;


	private Monitor mJobQueueMonitor = new .() ~ delete _;
	private Queue<Job> mJobQueue = new .() ~ delete _;

	public String Name => mName;
	public WorkerState State => mState;

	public this(JobSystem jobSystem, StringView? name = null)
	{
		mJobSystem = jobSystem;
		mName.Set(name ?? "Worker");

		mThread = new Thread(new => this.ProcessJobs);
		mThread.SetName(mName);
	}

	public ~this()
	{
	}

	public void Start()
	{
		if (mIsRunning)
			return;

		mIsRunning = true;
		mThread.Start(false);
	}

	public void Stop()
	{
		if (mIsRunning)
		{
			mIsRunning = false;
			mThread.Join();
			delete mThread;
		}

		using (mJobQueueMonitor.Enter())
		{
			while (mJobQueue.Count > 0)
			{
				Job job = mJobQueue.PopFront();
				job?.Cancel();
			}
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

	private void ProcessJobs()
	{
		while (true)
		{
			while (mJobQueue.Count > 0)
			{
				mState = .Busy;
				Job job = null;

				using (mJobQueueMonitor.Enter())
				{
					job = mJobQueue.PopFront();
				}

				if (job == null || job.State != .Pending)
				{
					continue;
				}

				if (!job.IsReady())
				{
					// A dependency is not yet completed
					// Re-queue the job on the JobSystem to free up this worker ASAP?
					QueueJob(job);
					continue;
				}

				mJobSystem.Logger.LogInformation("Worker: {} - Running job: {}.", mName, job.Name);
				job?.[Friend]Run();
			}

			mState = .Idle;

			if (!mIsRunning)
			{
				mState = .Dead;
				break;
			}
		}
	}
}
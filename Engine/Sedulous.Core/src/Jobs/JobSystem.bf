using System.Collections;
using Sedulous.Foundation.Logging.Abstractions;
using System.Threading;
using System;
using static System.Platform;
namespace Sedulous.Core.Jobs;

class JobSystem
{
	private readonly Engine mEngine = null;
	private readonly List<Worker> mWorkers = new .() ~ delete _;

	public int WorkerCount => mWorkers?.Count ?? 0;

	private readonly Monitor mPendingJobsMonitor = new .() ~ delete _;
	private readonly Queue<Job> mPendingJobs = new .() ~ delete _;

	private readonly Monitor mCompletedJobsMonitor = new .() ~ delete _;
	private readonly List<Job> mCompletedJobs = new .() ~ delete _;

	private readonly Monitor mCancelledJobsMonitor = new .() ~ delete _;
	private readonly List<Job> mCancelledJobs = new .() ~ delete _;

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
			Worker worker = new Worker(this, scope $"Worker {i}");

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

	public void Startup()
	{
		for (Worker worker in mWorkers)
		{
			worker.Start();
		}
	}

	public void Shutdown()
	{
		Wait();

		for (var worker in mWorkers)
		{
			worker.Stop();
		}

		ClearPendingJobs();
		ClearCompletedJobs();
		ClearCancelledJobs();
	}

	private void OnJobCompleted(Job job)
	{
		using (mCompletedJobsMonitor.Enter())
		{
			mCompletedJobs.Add(job);
		}
	}

	private void OnJobCancelled(Job job)
	{
		using (mCancelledJobsMonitor.Enter())
		{
			mCancelledJobs.Add(job);
		}
	}

	public void RunJob(Job job)
	{
		using (mPendingJobsMonitor.Enter())
		{
			// Remove handles in case the job is being re-queued
			// clean this up later, add a way to check of the handler exist
			job.OnCompleted.Unsubscribe(scope => OnJobCancelled).IgnoreError();
			job.OnCancelled.Unsubscribe(scope => OnJobCancelled).IgnoreError();

			job.OnCompleted.Subscribe(new => OnJobCancelled);
			job.OnCancelled.Subscribe(new => OnJobCancelled);

			mPendingJobs.Add(job);
		}
	}

	public void RunJob(delegate void() job, StringView name)
	{
		RunJob(new DelegateJob(job, name, .AutoDelete));
	}

	private bool GetNextIdleWorker(out Worker nextWorker)
	{
		for (Worker worker in mWorkers)
		{
			if (worker.State == .Idle)
			{
				nextWorker = worker;
				return true;
			}
		}

		nextWorker = null;

		return false;
	}

	private void ClearPendingJobs()
	{
		using (mPendingJobsMonitor.Enter())
		{
			for (Job job in mPendingJobs)
			{
				job.Cancel();
				if (job.Flags.HasFlag(.AutoDelete))
					delete job;
			}

			mPendingJobs.Clear();
		}
	}


	private void ClearCompletedJobs()
	{
		using (mCompletedJobsMonitor.Enter())
		{
			for (Job job in mCompletedJobs)
			{
				if (job.Flags.HasFlag(.AutoDelete))
					delete job;
			}

			mCompletedJobs.Clear();
		}
	}

	private void ClearCancelledJobs()
	{
		using (mCancelledJobsMonitor.Enter())
		{
			for (Job job in mCancelledJobs)
			{
				if (job.Flags.HasFlag(.AutoDelete))
					delete job;
			}

			mCancelledJobs.Clear();
		}
	}

	public void Update()
	{
		while (GetNextIdleWorker(var worker) && mPendingJobs.Count > 0)
		{
			using (mPendingJobsMonitor.Enter())
			{
				Job job = mPendingJobs.PopFront();
				Logger.LogInformation("Worker: {} - Job: {}", worker.Name, job.Name);
				worker.QueueJob(job);
			}
		}

		ClearCompletedJobs();

		ClearCancelledJobs();
	}
}
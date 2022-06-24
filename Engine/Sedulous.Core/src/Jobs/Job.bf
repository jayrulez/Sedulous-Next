using System;
using System.Collections;
using Sedulous.Foundation.Utilities;
namespace Sedulous.Core.Jobs;

enum JobPriority
{
	Normal,
	Critical
}

enum JobFlags
{
	None,
	AutoDelete
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

	public EventAccessor<delegate void(Job job)> OnCompleted = new .() ~ delete _;
	public EventAccessor<delegate void(Job job)> OnCancelled = new .() ~ delete _;

	public this(StringView name, JobFlags flags = .None)
	{
		mName.Set(name);
		mFlags = flags;
	}

	public bool IsReady()
	{
		for (Job dependency in mDependencies)
		{
			if (dependency.mState != .Completed)
				return false;
		}

		return mState == .Pending;
	}

	protected abstract void Execute();

	private void Run()
	{
		if (!IsReady())
			return;

		mState = .Running;

		Execute();

		if (mState == .Canceled)
			return;

		mState = .Completed;
		OnCompleted.[Friend]mEvent(this);
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

	public virtual void Cancel()
	{
		if (mState != .Completed && mState != .Canceled)
		{
			mState = .Canceled;
			OnCancelled.[Friend]mEvent(this);

			for (Job dependent in mDependents)
			{
				dependent.Cancel();
			}
		}
	}
}
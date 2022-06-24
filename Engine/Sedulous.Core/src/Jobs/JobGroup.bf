using System.Collections;
using System;
namespace Sedulous.Core.Jobs;

class JobGroup : Job
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

	protected override void Execute()
	{
		for (Job job in mJobs)
		{
			job.[Friend]Execute();
		}
	}

	public void AddJob(Job job)
	{
		mJobs.Add(job);
	}
}
using System;
using System.Collections;

namespace Sedulous.Foundation.Utilities;

class EventAccessor<T> where T : System.Delegate
{
	private Event<T> mEvent;

	public ~this()
	{
		mEvent.Dispose();
	}

	public void Subscribe(T handler)
	{
		mEvent.Add(handler);
	}

	public Result<void> Unsubscribe(T handler)
	{
		return mEvent.Remove(handler, true);
	}

	public bool HasHandler(T handler)
	{
		return false;
	}
}
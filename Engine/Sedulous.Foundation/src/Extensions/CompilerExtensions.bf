namespace System;

extension Compiler
{
	[Comptime]
	public static void Assert(bool cond, String message)
	{
		if (!cond)
			Runtime.FatalError(message);
	}
}
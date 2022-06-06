namespace System;

extension Compiler
{
	[Comptime(ConstEval=true)]
	public static void Assert(bool cond, String message)
	{
		if (!cond)
			Runtime.FatalError(message);
	}
}
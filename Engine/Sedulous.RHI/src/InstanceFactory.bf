using System;
namespace Sedulous.RHI
{
	static class InstanceFactory
	{
		typealias CreatorFunction = delegate void();

		public static Result<void> AddCreatorFunction(in CreatorFunction creatorFunction)
		{
			return .Ok;
		}
		public static Result<void> RemoveCreatorFunction()
		{
			return .Ok;
		}

		public static Instance Create(in Instance.Description desc)
		{
			return null;
		}

		public static void FreeInstance(in Instance instance)
		{
		}
	}
}
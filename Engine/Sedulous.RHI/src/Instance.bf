using System;
using System.Collections;
namespace Sedulous.RHI
{
	abstract class Instance
	{
		public abstract Backend Backend {get;}
		public abstract bool SetNameEnabled {get;}

		public struct Description
		{
			public Backend Backend;
			public bool EnableDebugLayers;
			public bool EnableGpuValidation;
			public bool EnableSetName;
		}

		public struct Features
		{
			public bool SpecializationConstant;
		}

		public abstract Features QueryFeatures();

		public abstract Result<void> EnumerateAdapters(out List<Adapter> adapters);
	}
}
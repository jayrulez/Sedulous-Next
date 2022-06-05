using System;
using System.Collections;
namespace Sedulous.RHI
{
	abstract class ShaderLibrary
	{
		public struct Description
		{
		}

		public abstract Device Device {get;}
		public abstract String Name {get;}
		public List<ShaderResource> EntryReflections {get;}
	}
}
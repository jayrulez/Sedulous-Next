using System;
namespace Sedulous.Foundation.Mathematics
{
	
	[CRepr]
	struct UInt3 : IEquatable<UInt3>
	{
		public uint32 X;
		public uint32 Y;
		public uint32 Z;

		public bool Equals(UInt3 val2)
		{
			return X == val2.X && Y == val2.Y && Z == val2.Z;
		}
	}
}
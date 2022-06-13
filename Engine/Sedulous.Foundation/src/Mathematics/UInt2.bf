using System;
namespace Sedulous.Foundation.Mathematics
{
	
	[CRepr]
	struct UInt2 : IEquatable<UInt2>
	{
		public uint32 X;
		public uint32 Y;

		public bool Equals(UInt2 val2)
		{
			return X == val2.X && Y == val2.Y;
		}
	}
}
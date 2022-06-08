using System;
namespace Sedulous.Foundation.Mathematics
{
	class MathHelper
	{
		/// <summary>
		/// Return the next power of two value of the specified argument.
		/// </summary>
		/// <param name="v">The value.</param>
		/// <returns>The next power of two.</returns>
		[Inline]
		public static int NextPowerOfTwo(int v)
		{
			var v;

			v--;
			v |= v >> 1;
			v |= v >> 2;
			v |= v >> 4;
			v |= v >> 8;
			v |= v >> 16;
			v++;
			return v;
		}

		/// <summary>
		/// Return the next power of two value of the specified argument.
		/// </summary>
		/// <param name="v">The value.</param>
		/// <returns>The next power of two.</returns>
		[Inline]
		public static uint64 NextPowerOfTwo(uint64 v)
		{
			var v;

			v--;
			v |= v >> 1;
			v |= v >> 2;
			v |= v >> 4;
			v |= v >> 8;
			v |= v >> 16;
			v++;
			return v;
		}

		/// <summary>
		/// Divide value by alignment to get the minimum multiple higher than the value.
		/// </summary>
		/// <param name="value">The value to divide.</param>
		/// <param name="alignment">The alignment.</param>
		/// <returns>The multiply value.</returns>
		[Inline]
		public static uint32 DivideByMultiple(uint32 value, uint32 alignment)
		{
			return (value + alignment - 1) / alignment;
		}
	}
}
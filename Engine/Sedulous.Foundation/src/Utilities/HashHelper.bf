namespace Sedulous.Foundation.Utilities
{
	static class HashHelper
	{
		public static int CombineHash(int first, int second)
		{
			return (first * 397) ^ second;
		}
	}
}
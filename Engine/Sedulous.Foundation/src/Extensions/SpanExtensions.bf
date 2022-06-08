namespace System;

extension Span<T> where T : String
{
	public bool Contains(in StringView other, StringComparison comparisonType = StringComparison.Ordinal)
	{
		for (String item in this)
		{
			if (item.Equals(other))
			{
				return true;
			}
		}
		return false;
	}
}
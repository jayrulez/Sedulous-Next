using Sedulous.Foundation.Utilities;
namespace System;

extension Array
{
	public static void Resize<T>(ref T[] array, int size)
	{
		T[] tmp = scope T[array.Count];
		array.CopyTo(tmp);

		delete array;
		array = new T[size];

		if (size > tmp.Count)
		{
			tmp.CopyTo(array, 0, 0, tmp.Count);
		} else
		{
			tmp.CopyTo(array, 0, 0, size);
		}
	}
}

extension SizedArray<T, TSize> where TSize : const int
{
	public void Fill(T value) mut
	{
		for (int i = 0; i < this.Count; i++)
		{
			mVal[i] = value;
		}
	}
}

public extension Array1<T> where T : IHashable
{
	public int GetHashCode()
	{
		int hash = 0;
		for (int i = 0; i < mLength; i++)
		{
			hash = HashHelper.CombineHash(hash, this[i].GetHashCode());
		}
		return hash;
	}
}

public extension Array1<T>
{
	public void Fill(T value)
	{
		for (int i = 0; i < this.Count; i++)
		{
			this[i] = value;
		}
	}

	public bool SequenceEqual(T[] other)
	{
		if (this.Count != other.Count)
			return false;

		for (int i = 0; i < this.Count; i++)
		{
			if (this[i] != other[i])
				return false;
		}

		return true;
	}
}

public extension Array1<T> where T : String
{
	public bool Contains(in StringView other, bool ignoreCase = false)
	{
		for (int i = 0; i < Count; i++)
		{
			if (other.Equals(this[i], ignoreCase))
			{
				return true;
			}
		}

		return false;
	}
}
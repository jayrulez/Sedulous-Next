using System;
namespace Sedulous.Foundation.Mathematics;


[CRepr]
struct TRect<T>
	where T : operator T + T
{
	public T X;
	public T Y;
	public T Width;
	public T Height;

	public T Left => X;
	public T Top => Y;
	public T Right => X + Width;
	public T Bottom => Y + Height;

	public this(T x, T y, T width, T height){
		X = x;
		Y = y;
		Width = width;
		Height = height;
	}
}

typealias IntRect = TRect<int>;

typealias FloatRect = TRect<float>;

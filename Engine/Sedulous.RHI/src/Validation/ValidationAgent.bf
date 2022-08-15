namespace Sedulous.RHI.Validation
{
	class My { }

	class ValidationAgent<T>
	{
		private T mInstance;

		public T Instance => mInstance;

		public this(T instance)
		{
			mInstance = instance;
		}
	}

	class MyValidation : ValidationAgent<My>
	{
		public this(My my)
			: base(my)
		{

		}
	}
}
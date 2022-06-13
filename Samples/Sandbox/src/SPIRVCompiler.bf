using SPIRV_Cross;
using System;
namespace Sandbox
{
	using static SPIRV_Cross.SPIRV;

	public static
	{
		public static void error_callback(void* userdata, char8* error)
		{
			(void)userdata;
			/*if (g_fail_on_error)
			{
				Console.WriteLine("Error: {0}\n", scope String(error));
				Runtime.FatalError();
			}
			*/
			Console.WriteLine("Expected error hit: {0}\n", scope String(error));
		}

		public static mixin SPVC_CHECKED_CALL<T>(spvc_result result, T retVal)
		{
			if (result != .SPVC_SUCCESS)
			{
				Console.WriteLine($"Failed: {result}");
				return retVal;
			}
		}
	}

	static class SPIRVCompiler
	{
		private static spvc_context context = .Null;
		private static spvc_compiler compiler_glsl = .Null;
		private static spvc_parsed_ir ir = .Null;

		public static this()
		{
			Initialize();
		}

		private static void Initialize()
		{
			SPVC_CHECKED_CALL!(spvc_context_create(&context), void());
			function void(void* userdata, char8* error) errorCb = => error_callback;
			spvc_error_callback cb = .((int)(void*)errorCb);
			spvc_context_set_error_callback(context, cb, null);

			SPVC_CHECKED_CALL!(spvc_context_create_compiler(context, .Glsl, ir, .Copy, &compiler_glsl), void());
		}


		public static void Compile(){
			char8* result = null;
			SPVC_CHECKED_CALL!(spvc_compiler_compile(compiler_glsl, (.)&result), void());
		}

		public static ~this()
		{
			spvc_context_destroy(context);
		}
	}
}
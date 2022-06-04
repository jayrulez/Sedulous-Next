using Sedulous.Foundation.Logging.Console;
namespace Sandbox
{
	class Program
	{
		public static void Main()
		{
			var app = scope SandboxApplication("Sandbox", 1280, 720);
			app.Run();
		}
	}
}
using Sedulous.Foundation.Logging.Console;
using System;
namespace Sandbox;

class Program
{
	public static void Main()
	{
		var app = scope SandboxApplication("Sandbox", 1280, 720);
		app.Run();
	}
}
using System;
namespace GraphicsTest
{
	class Program
	{
		public static void Main()
		{
			var app = scope GraphicsTestApplication("Sandbox", 1280, 720);
			app.Run();

			Console.Read();
		}
	}
}
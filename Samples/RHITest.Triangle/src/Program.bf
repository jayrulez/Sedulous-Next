using System;
using System.Threading;
namespace RHITest.Triangle
{
	class Program
	{
		public static void Main(){

			Thread.Sleep(30000);

			var app = scope RHITestApplication("Sandbox", 1280, 720);
			app.Run();
		}
	}
}
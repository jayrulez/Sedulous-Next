using System.Threading;
using System;
namespace CoreTest.Engine;

class Program
{
	public static void Main()
	{
			var app = scope CoreTestApplication("CoreTest", 1280, 720);
			app.Run();
	}
}
using System;
using System.Globalization;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Represents a 32-bit color.
	/// </summary>
	[CRepr, Packed(4)]
	public struct Color : IEquatable<Color>
	{
		/// <summary>
		/// Transparent color.
		/// </summary>
		private static readonly Color transparent;

		/// <summary>
		/// Alice blue color.
		/// </summary>
		private static readonly Color aliceBlue;

		/// <summary>
		/// Antique white color.
		/// </summary>
		private static readonly Color antiqueWhite;

		/// <summary>
		/// Aqua color.
		/// </summary>
		private static readonly Color aqua;

		/// <summary>
		/// Aquamarine color.
		/// </summary>
		private static readonly Color aquamarine;

		/// <summary>
		/// Azure color.
		/// </summary>
		private static readonly Color azure;

		/// <summary>
		/// Beige color.
		/// </summary>
		private static readonly Color beige;

		/// <summary>
		/// Bisque color.
		/// </summary>
		private static readonly Color bisque;

		/// <summary>
		/// Black color.
		/// </summary>
		private static readonly Color black;

		/// <summary>
		/// Blanched almond color.
		/// </summary>
		private static readonly Color blanchedAlmond;

		/// <summary>
		/// Blue color.
		/// </summary>
		private static readonly Color blue;

		/// <summary>
		/// Blue violet color.
		/// </summary>
		private static readonly Color blueViolet;

		/// <summary>
		/// Brown color.
		/// </summary>
		private static readonly Color brown;

		/// <summary>
		/// Burly wood color.
		/// </summary>
		private static readonly Color burlyWood;

		/// <summary>
		/// Cadet blue color.
		/// </summary>
		private static readonly Color cadetBlue;

		/// <summary>
		/// Chartreuse color.
		/// </summary>
		private static readonly Color chartreuse;

		/// <summary>
		/// Chocolate color.
		/// </summary>
		private static readonly Color chocolate;

		/// <summary>
		/// Coral color.
		/// </summary>
		private static readonly Color coral;

		/// <summary>
		/// Cornflower blue color.
		/// </summary>
		private static readonly Color cornflowerBlue;

		/// <summary>
		/// Cornsilk color.
		/// </summary>
		private static readonly Color cornsilk;

		/// <summary>
		/// Crimson color.
		/// </summary>
		private static readonly Color crimson;

		/// <summary>
		/// Cyan color.
		/// </summary>
		private static readonly Color cyan;

		/// <summary>
		/// Dark blue color.
		/// </summary>
		private static readonly Color darkBlue;

		/// <summary>
		/// Dark cyan color.
		/// </summary>
		private static readonly Color darkCyan;

		/// <summary>
		/// Dark goldenrod color.
		/// </summary>
		private static readonly Color darkGoldenrod;

		/// <summary>
		/// Dark gray color.
		/// </summary>
		private static readonly Color darkGray;

		/// <summary>
		/// Dark green color.
		/// </summary>
		private static readonly Color darkGreen;

		/// <summary>
		/// Dark khaki color.
		/// </summary>
		private static readonly Color darkKhaki;

		/// <summary>
		/// Dark magenta color.
		/// </summary>
		private static readonly Color darkMagenta;

		/// <summary>
		/// Dark olive green color.
		/// </summary>
		private static readonly Color darkOliveGreen;

		/// <summary>
		/// Dark orange color.
		/// </summary>
		private static readonly Color darkOrange;

		/// <summary>
		/// Dark orchid color.
		/// </summary>
		private static readonly Color darkOrchid;

		/// <summary>
		/// Dark red color.
		/// </summary>
		private static readonly Color darkRed;

		/// <summary>
		/// Dark salmon color.
		/// </summary>
		private static readonly Color darkSalmon;

		/// <summary>
		/// Dark sea green color.
		/// </summary>
		private static readonly Color darkSeaGreen;

		/// <summary>
		/// Dark slate blue color.
		/// </summary>
		private static readonly Color darkSlateBlue;

		/// <summary>
		/// Dark slate gray color.
		/// </summary>
		private static readonly Color darkSlateGray;

		/// <summary>
		/// Dark turquoise color.
		/// </summary>
		private static readonly Color darkTurquoise;

		/// <summary>
		/// Dark violet color.
		/// </summary>
		private static readonly Color darkViolet;

		/// <summary>
		/// Deep pink color.
		/// </summary>
		private static readonly Color deepPink;

		/// <summary>
		/// Deep sky blue color.
		/// </summary>
		private static readonly Color deepSkyBlue;

		/// <summary>
		/// Dim gray color.
		/// </summary>
		private static readonly Color dimGray;

		/// <summary>
		/// Dodger blue color.
		/// </summary>
		private static readonly Color dodgerBlue;

		/// <summary>
		/// Firebrick color.
		/// </summary>
		private static readonly Color firebrick;

		/// <summary>
		/// Floral white color.
		/// </summary>
		private static readonly Color floralWhite;

		/// <summary>
		/// Forest green color.
		/// </summary>
		private static readonly Color forestGreen;

		/// <summary>
		/// Fuchsia color.
		/// </summary>
		private static readonly Color fuchsia;

		/// <summary>
		/// Gainsboro color.
		/// </summary>
		private static readonly Color gainsboro;

		/// <summary>
		/// Ghost white color.
		/// </summary>
		private static readonly Color ghostWhite;

		/// <summary>
		/// Gold color.
		/// </summary>
		private static readonly Color gold;

		/// <summary>
		/// Goldenrod color.
		/// </summary>
		private static readonly Color goldenrod;

		/// <summary>
		/// Gray color.
		/// </summary>
		private static readonly Color gray;

		/// <summary>
		/// Green color.
		/// </summary>
		private static readonly Color green;

		/// <summary>
		/// Green yellow color.
		/// </summary>
		private static readonly Color greenYellow;

		/// <summary>
		/// Honeydew color.
		/// </summary>
		private static readonly Color honeydew;

		/// <summary>
		/// Hot pink color.
		/// </summary>
		private static readonly Color hotPink;

		/// <summary>
		/// Indian red color.
		/// </summary>
		private static readonly Color indianRed;

		/// <summary>
		/// Indigo color.
		/// </summary>
		private static readonly Color indigo;

		/// <summary>
		/// Ivory color.
		/// </summary>
		private static readonly Color ivory;

		/// <summary>
		/// Khaki color.
		/// </summary>
		private static readonly Color khaki;

		/// <summary>
		/// Lavender color.
		/// </summary>
		private static readonly Color lavender;

		/// <summary>
		/// Lavender blush color.
		/// </summary>
		private static readonly Color lavenderBlush;

		/// <summary>
		/// Lawn green color.
		/// </summary>
		private static readonly Color lawnGreen;

		/// <summary>
		/// Lemon chiffon color.
		/// </summary>
		private static readonly Color lemonChiffon;

		/// <summary>
		/// Light blue color.
		/// </summary>
		private static readonly Color lightBlue;

		/// <summary>
		/// Light color color.
		/// </summary>
		private static readonly Color lightCoral;

		/// <summary>
		/// Light cyan color.
		/// </summary>
		private static readonly Color lightCyan;

		/// <summary>
		/// Light goldenrod yellow color.
		/// </summary>
		private static readonly Color lightGoldenrodYellow;

		/// <summary>
		/// Light green color.
		/// </summary>
		private static readonly Color lightGreen;

		/// <summary>
		/// Light gray color.
		/// </summary>
		private static readonly Color lightGray;

		/// <summary>
		/// Light pink color.
		/// </summary>
		private static readonly Color lightPink;

		/// <summary>
		/// Light salmon color.
		/// </summary>
		private static readonly Color lightSalmon;

		/// <summary>
		/// Light sea green color.
		/// </summary>
		private static readonly Color lightSeaGreen;

		/// <summary>
		/// Light sky blue color.
		/// </summary>
		private static readonly Color lightSkyBlue;

		/// <summary>
		/// Light slate gray color.
		/// </summary>
		private static readonly Color lightSlateGray;

		/// <summary>
		/// Light steel blue color.
		/// </summary>
		private static readonly Color lightSteelBlue;

		/// <summary>
		/// Light yellow color.
		/// </summary>
		private static readonly Color lightYellow;

		/// <summary>
		/// Lime color.
		/// </summary>
		private static readonly Color lime;

		/// <summary>
		/// Lime green color.
		/// </summary>
		private static readonly Color limeGreen;

		/// <summary>
		/// Linen color.
		/// </summary>
		private static readonly Color linen;

		/// <summary>
		/// Magenta color.
		/// </summary>
		private static readonly Color magenta;

		/// <summary>
		/// Maroon color.
		/// </summary>
		private static readonly Color maroon;

		/// <summary>
		/// Medium aquamarine color.
		/// </summary>
		private static readonly Color mediumAquamarine;

		/// <summary>
		/// Medium blue color.
		/// </summary>
		private static readonly Color mediumBlue;

		/// <summary>
		/// Medium orchid color.
		/// </summary>
		private static readonly Color mediumOrchid;

		/// <summary>
		/// Medium purple color.
		/// </summary>
		private static readonly Color mediumPurple;

		/// <summary>
		/// Medium sea green color.
		/// </summary>
		private static readonly Color mediumSeaGreen;

		/// <summary>
		/// Medium slate blue color.
		/// </summary>
		private static readonly Color mediumSlateBlue;

		/// <summary>
		/// Medium spring green color.
		/// </summary>
		private static readonly Color mediumSpringGreen;

		/// <summary>
		/// Medium turquoise color.
		/// </summary>
		private static readonly Color mediumTurquoise;

		/// <summary>
		/// Medium violet red color.
		/// </summary>
		private static readonly Color mediumVioletRed;

		/// <summary>
		/// Midnight blue color.
		/// </summary>
		private static readonly Color midnightBlue;

		/// <summary>
		/// Mint cream color.
		/// </summary>
		private static readonly Color mintCream;

		/// <summary>
		/// Misty rose color.
		/// </summary>
		private static readonly Color mistyRose;

		/// <summary>
		/// Mocassin color.
		/// </summary>
		private static readonly Color moccasin;

		/// <summary>
		/// Navajo white color.
		/// </summary>
		private static readonly Color navajoWhite;

		/// <summary>
		/// Pale navy color.
		/// </summary>
		private static readonly Color navy;

		/// <summary>
		/// Pale old lace color.
		/// </summary>
		private static readonly Color oldLace;

		/// <summary>
		/// Pale olive color.
		/// </summary>
		private static readonly Color olive;

		/// <summary>
		/// Pale olive drab color.
		/// </summary>
		private static readonly Color oliveDrab;

		/// <summary>
		/// Pale orange color.
		/// </summary>
		private static readonly Color orange;

		/// <summary>
		/// Pale orange red color.
		/// </summary>
		private static readonly Color orangeRed;

		/// <summary>
		/// Pale orchid color.
		/// </summary>
		private static readonly Color orchid;

		/// <summary>
		/// Pale goldenrod color.
		/// </summary>
		private static readonly Color paleGoldenrod;

		/// <summary>
		/// Pale green color.
		/// </summary>
		private static readonly Color paleGreen;

		/// <summary>
		/// Pale turquoise color.
		/// </summary>
		private static readonly Color paleTurquoise;

		/// <summary>
		/// Pale violet red color.
		/// </summary>
		private static readonly Color paleVioletRed;

		/// <summary>
		/// Papaya whip color.
		/// </summary>
		private static readonly Color papayaWhip;

		/// <summary>
		/// Peach puff color.
		/// </summary>
		private static readonly Color peachPuff;

		/// <summary>
		/// Peru color.
		/// </summary>
		private static readonly Color peru;

		/// <summary>
		/// Pink color.
		/// </summary>
		private static readonly Color pink;

		/// <summary>
		/// Plum color.
		/// </summary>
		private static readonly Color plum;

		/// <summary>
		/// Powder blue color.
		/// </summary>
		private static readonly Color powderBlue;

		/// <summary>
		/// Purple color.
		/// </summary>
		private static readonly Color purple;

		/// <summary>
		/// Red color.
		/// </summary>
		private static readonly Color red;

		/// <summary>
		/// Rosy brown color.
		/// </summary>
		private static readonly Color rosyBrown;

		/// <summary>
		/// Royal blue color.
		/// </summary>
		private static readonly Color royalBlue;

		/// <summary>
		/// Saddle brown color.
		/// </summary>
		private static readonly Color saddleBrown;

		/// <summary>
		/// Salmon color.
		/// </summary>
		private static readonly Color salmon;

		/// <summary>
		/// Sandy brown color.
		/// </summary>
		private static readonly Color sandyBrown;

		/// <summary>
		/// Sea green color.
		/// </summary>
		private static readonly Color seaGreen;

		/// <summary>
		/// Sea shell color.
		/// </summary>
		private static readonly Color seaShell;

		/// <summary>
		/// Sienna color.
		/// </summary>
		private static readonly Color sienna;

		/// <summary>
		/// Silver color.
		/// </summary>
		private static readonly Color silver;

		/// <summary>
		/// Sky blue color.
		/// </summary>
		private static readonly Color skyBlue;

		/// <summary>
		/// Slate blue color.
		/// </summary>
		private static readonly Color slateBlue;

		/// <summary>
		/// Slate gray color.
		/// </summary>
		private static readonly Color slateGray;

		/// <summary>
		/// Snow color.
		/// </summary>
		private static readonly Color snow;

		/// <summary>
		/// Spring green color.
		/// </summary>
		private static readonly Color springGreen;

		/// <summary>
		/// Steel blue color.
		/// </summary>
		private static readonly Color steelBlue;

		/// <summary>
		/// Tan color.
		/// </summary>
		private static readonly Color tan;

		/// <summary>
		/// Teal color.
		/// </summary>
		private static readonly Color teal;

		/// <summary>
		/// Thistle color.
		/// </summary>
		private static readonly Color thistle;

		/// <summary>
		/// Tomato color.
		/// </summary>
		private static readonly Color tomato;

		/// <summary>
		/// Turquoise color.
		/// </summary>
		private static readonly Color turquoise;

		/// <summary>
		/// Violet color.
		/// </summary>
		private static readonly Color violet;

		/// <summary>
		/// Wheat color.
		/// </summary>
		private static readonly Color wheat;

		/// <summary>
		/// White color.
		/// </summary>
		private static readonly Color white;

		/// <summary>
		/// White smoke color.
		/// </summary>
		private static readonly Color whiteSmoke;

		/// <summary>
		/// Yellow color.
		/// </summary>
		private static readonly Color yellow;

		/// <summary>
		/// Yellow green color.
		/// </summary>
		private static readonly Color yellowGreen;

		/// <summary>
		/// Red component.
		/// </summary>
		public uint8 R;

		/// <summary>
		/// Green component.
		/// </summary>
		public uint8 G;

		/// <summary>
		/// Blue component.
		/// </summary>
		public uint8 B;

		/// <summary>
		/// Alpha component.
		/// </summary>
		public uint8 A;

		/// <summary>
		/// Gets the transparent.
		/// </summary>
		public static Color Transparent => transparent;

		/// <summary>
		/// Gets the alice blue.
		/// </summary>
		public static Color AliceBlue => aliceBlue;

		/// <summary>
		/// Gets the antique white.
		/// </summary>
		public static Color AntiqueWhite => antiqueWhite;

		/// <summary>
		/// Gets the aqua.
		/// </summary>
		public static Color Aqua => aqua;

		/// <summary>
		/// Gets the aquamarine.
		/// </summary>
		public static Color Aquamarine => aquamarine;

		/// <summary>
		/// Gets the azure.
		/// </summary>
		public static Color Azure => azure;

		/// <summary>
		/// Gets the beige.
		/// </summary>
		public static Color Beige => beige;

		/// <summary>
		/// Gets the bisque.
		/// </summary>
		public static Color Bisque => bisque;

		/// <summary>
		/// Gets the black.
		/// </summary>
		public static Color Black => black;

		/// <summary>
		/// Gets the blanched almond.
		/// </summary>
		public static Color BlanchedAlmond => blanchedAlmond;

		/// <summary>
		/// Gets the blue.
		/// </summary>
		public static Color Blue => blue;

		/// <summary>
		/// Gets the blue violet.
		/// </summary>
		public static Color BlueViolet => blueViolet;

		/// <summary>
		/// Gets the brown.
		/// </summary>
		public static Color Brown => brown;

		/// <summary>
		/// Gets the burly wood.
		/// </summary>
		public static Color BurlyWood => burlyWood;

		/// <summary>
		/// Gets the cadet blue.
		/// </summary>
		public static Color CadetBlue => cadetBlue;

		/// <summary>
		/// Gets the chartreuse.
		/// </summary>
		public static Color Chartreuse => chartreuse;

		/// <summary>
		/// Gets the chocolate.
		/// </summary>
		public static Color Chocolate => chocolate;

		/// <summary>
		/// Gets the coral.
		/// </summary>
		public static Color Coral => coral;

		/// <summary>
		/// Gets the cornflower blue.
		/// </summary>
		public static Color CornflowerBlue => cornflowerBlue;

		/// <summary>
		/// Gets the cornsilk.
		/// </summary>
		public static Color Cornsilk => cornsilk;

		/// <summary>
		/// Gets the crimson.
		/// </summary>
		public static Color Crimson => crimson;

		/// <summary>
		/// Gets the cyan.
		/// </summary>
		public static Color Cyan => cyan;

		/// <summary>
		/// Gets the dark blue.
		/// </summary>
		public static Color DarkBlue => darkBlue;

		/// <summary>
		/// Gets the dark cyan.
		/// </summary>
		public static Color DarkCyan => darkCyan;

		/// <summary>
		/// Gets the dark goldenrod.
		/// </summary>
		public static Color DarkGoldenrod => darkGoldenrod;

		/// <summary>
		/// Gets the dark gray.
		/// </summary>
		public static Color DarkGray => darkGray;

		/// <summary>
		/// Gets the dark green.
		/// </summary>
		public static Color DarkGreen => darkGreen;

		/// <summary>
		/// Gets the dark khaki.
		/// </summary>
		public static Color DarkKhaki => darkKhaki;

		/// <summary>
		/// Gets the dark magenta.
		/// </summary>
		public static Color DarkMagenta => darkMagenta;

		/// <summary>
		/// Gets the dark olive green.
		/// </summary>
		public static Color DarkOliveGreen => darkOliveGreen;

		/// <summary>
		/// Gets the dark orange.
		/// </summary>
		public static Color DarkOrange => darkOrange;

		/// <summary>
		/// Gets the dark orchid.
		/// </summary>
		public static Color DarkOrchid => darkOrchid;

		/// <summary>
		/// Gets the dark red.
		/// </summary>
		public static Color DarkRed => darkRed;

		/// <summary>
		/// Gets the dark salmon.
		/// </summary>
		public static Color DarkSalmon => darkSalmon;

		/// <summary>
		/// Gets the dark sea green.
		/// </summary>
		public static Color DarkSeaGreen => darkSeaGreen;

		/// <summary>
		/// Gets the dark slate blue.
		/// </summary>
		public static Color DarkSlateBlue => darkSlateBlue;

		/// <summary>
		/// Gets the dark slate gray.
		/// </summary>
		public static Color DarkSlateGray => darkSlateGray;

		/// <summary>
		/// Gets the dark turquoise.
		/// </summary>
		public static Color DarkTurquoise => darkTurquoise;

		/// <summary>
		/// Gets the dark violet.
		/// </summary>
		public static Color DarkViolet => darkViolet;

		/// <summary>
		/// Gets the deep pink.
		/// </summary>
		public static Color DeepPink => deepPink;

		/// <summary>
		/// Gets the deep sky blue.
		/// </summary>
		public static Color DeepSkyBlue => deepSkyBlue;

		/// <summary>
		/// Gets the dim gray.
		/// </summary>
		public static Color DimGray => dimGray;

		/// <summary>
		/// Gets the dodger blue.
		/// </summary>
		public static Color DodgerBlue => dodgerBlue;

		/// <summary>
		/// Gets the firebrick.
		/// </summary>
		public static Color Firebrick => firebrick;

		/// <summary>
		/// Gets the floral white.
		/// </summary>
		public static Color FloralWhite => floralWhite;

		/// <summary>
		/// Gets the forest green.
		/// </summary>
		public static Color ForestGreen => forestGreen;

		/// <summary>
		/// Gets the fuchsia.
		/// </summary>
		public static Color Fuchsia => fuchsia;

		/// <summary>
		/// Gets the gainsboro.
		/// </summary>
		public static Color Gainsboro => gainsboro;

		/// <summary>
		/// Gets the ghost white.
		/// </summary>
		public static Color GhostWhite => ghostWhite;

		/// <summary>
		/// Gets the gold.
		/// </summary>
		public static Color Gold => gold;

		/// <summary>
		/// Gets the goldenrod.
		/// </summary>
		public static Color Goldenrod => goldenrod;

		/// <summary>
		/// Gets the gray.
		/// </summary>
		public static Color Gray => gray;

		/// <summary>
		/// Gets the green.
		/// </summary>
		public static Color Green => green;

		/// <summary>
		/// Gets the green yellow.
		/// </summary>
		public static Color GreenYellow => greenYellow;

		/// <summary>
		/// Gets the honeydew.
		/// </summary>
		public static Color Honeydew => honeydew;

		/// <summary>
		/// Gets the hot pink.
		/// </summary>
		public static Color HotPink => hotPink;

		/// <summary>
		/// Gets the indian red.
		/// </summary>
		public static Color IndianRed => indianRed;

		/// <summary>
		/// Gets the indigo.
		/// </summary>
		public static Color Indigo => indigo;

		/// <summary>
		/// Gets the ivory.
		/// </summary>
		public static Color Ivory => ivory;

		/// <summary>
		/// Gets the khaki.
		/// </summary>
		public static Color Khaki => khaki;

		/// <summary>
		/// Gets the lavender.
		/// </summary>
		public static Color Lavender => lavender;

		/// <summary>
		/// Gets the lavender blush.
		/// </summary>
		public static Color LavenderBlush => lavenderBlush;

		/// <summary>
		/// Gets the lawn green.
		/// </summary>
		public static Color LawnGreen => lawnGreen;

		/// <summary>
		/// Gets the lemon chiffon.
		/// </summary>
		public static Color LemonChiffon => lemonChiffon;

		/// <summary>
		/// Gets the light blue.
		/// </summary>
		public static Color LightBlue => lightBlue;

		/// <summary>
		/// Gets the light coral.
		/// </summary>
		public static Color LightCoral => lightCoral;

		/// <summary>
		/// Gets the light cyan.
		/// </summary>
		public static Color LightCyan => lightCyan;

		/// <summary>
		/// Gets the light goldenrod yellow.
		/// </summary>
		public static Color LightGoldenrodYellow => lightGoldenrodYellow;

		/// <summary>
		/// Gets the light green.
		/// </summary>
		public static Color LightGreen => lightGreen;

		/// <summary>
		/// Gets the light gray.
		/// </summary>
		public static Color LightGray => lightGray;

		/// <summary>
		/// Gets the light pink.
		/// </summary>
		public static Color LightPink => lightPink;

		/// <summary>
		/// Gets the light salmon.
		/// </summary>
		public static Color LightSalmon => lightSalmon;

		/// <summary>
		/// Gets the light sea green.
		/// </summary>
		public static Color LightSeaGreen => lightSeaGreen;

		/// <summary>
		/// Gets the light sky blue.
		/// </summary>
		public static Color LightSkyBlue => lightSkyBlue;

		/// <summary>
		/// Gets the light slate gray.
		/// </summary>
		public static Color LightSlateGray => lightSlateGray;

		/// <summary>
		/// Gets the light steel blue.
		/// </summary>
		public static Color LightSteelBlue => lightSteelBlue;

		/// <summary>
		/// Gets the light yellow.
		/// </summary>
		public static Color LightYellow => lightYellow;

		/// <summary>
		/// Gets the lime.
		/// </summary>
		public static Color Lime => lime;

		/// <summary>
		/// Gets the lime green.
		/// </summary>
		public static Color LimeGreen => limeGreen;

		/// <summary>
		/// Gets the linen.
		/// </summary>
		public static Color Linen => linen;

		/// <summary>
		/// Gets the magenta.
		/// </summary>
		public static Color Magenta => magenta;

		/// <summary>
		/// Gets the maroon.
		/// </summary>
		public static Color Maroon => maroon;

		/// <summary>
		/// Gets the medium aquamarine.
		/// </summary>
		public static Color MediumAquamarine => mediumAquamarine;

		/// <summary>
		/// Gets the medium blue.
		/// </summary>
		public static Color MediumBlue => mediumBlue;

		/// <summary>
		/// Gets the medium orchid.
		/// </summary>
		public static Color MediumOrchid => mediumOrchid;

		/// <summary>
		/// Gets the medium purple.
		/// </summary>
		public static Color MediumPurple => mediumPurple;

		/// <summary>
		/// Gets the medium sea green.
		/// </summary>
		public static Color MediumSeaGreen => mediumSeaGreen;

		/// <summary>
		/// Gets the medium slate blue.
		/// </summary>
		public static Color MediumSlateBlue => mediumSlateBlue;

		/// <summary>
		/// Gets the medium spring green.
		/// </summary>
		public static Color MediumSpringGreen => mediumSpringGreen;

		/// <summary>
		/// Gets the medium turquoise.
		/// </summary>
		public static Color MediumTurquoise => mediumTurquoise;

		/// <summary>
		/// Gets the medium violet red.
		/// </summary>
		public static Color MediumVioletRed => mediumVioletRed;

		/// <summary>
		/// Gets the midnight blue.
		/// </summary>
		public static Color MidnightBlue => midnightBlue;

		/// <summary>
		/// Gets the mint cream.
		/// </summary>
		public static Color MintCream => mintCream;

		/// <summary>
		/// Gets the misty rose.
		/// </summary>
		public static Color MistyRose => mistyRose;

		/// <summary>
		/// Gets the moccasin.
		/// </summary>
		public static Color Moccasin => moccasin;

		/// <summary>
		/// Gets the navajo white.
		/// </summary>
		public static Color NavajoWhite => navajoWhite;

		/// <summary>
		/// Gets the navy.
		/// </summary>
		public static Color Navy => navy;

		/// <summary>
		/// Gets the old lace.
		/// </summary>
		public static Color OldLace => oldLace;

		/// <summary>
		/// Gets the olive.
		/// </summary>
		public static Color Olive => olive;

		/// <summary>
		/// Gets the olive drab.
		/// </summary>
		public static Color OliveDrab => oliveDrab;

		/// <summary>
		/// Gets the orange.
		/// </summary>
		public static Color Orange => orange;

		/// <summary>
		/// Gets the orange red.
		/// </summary>
		public static Color OrangeRed => orangeRed;

		/// <summary>
		/// Gets the orchid.
		/// </summary>
		public static Color Orchid => orchid;

		/// <summary>
		/// Gets the pale goldenrod.
		/// </summary>
		public static Color PaleGoldenrod => paleGoldenrod;

		/// <summary>
		/// Gets the pale green.
		/// </summary>
		public static Color PaleGreen => paleGreen;

		/// <summary>
		/// Gets the pale turquoise.
		/// </summary>
		public static Color PaleTurquoise => paleTurquoise;

		/// <summary>
		/// Gets the pale violet red.
		/// </summary>
		public static Color PaleVioletRed => paleVioletRed;

		/// <summary>
		/// Gets the papaya whip.
		/// </summary>
		public static Color PapayaWhip => papayaWhip;

		/// <summary>
		/// Gets the peach puff.
		/// </summary>
		public static Color PeachPuff => peachPuff;

		/// <summary>
		/// Gets the peru.
		/// </summary>
		public static Color Peru => peru;

		/// <summary>
		/// Gets the pink.
		/// </summary>
		public static Color Pink => pink;

		/// <summary>
		/// Gets the plum.
		/// </summary>
		public static Color Plum => plum;

		/// <summary>
		/// Gets the powder blue.
		/// </summary>
		public static Color PowderBlue => powderBlue;

		/// <summary>
		/// Gets the purple.
		/// </summary>
		public static Color Purple => purple;

		/// <summary>
		/// Gets the red.
		/// </summary>
		public static Color Red => red;

		/// <summary>
		/// Gets the rosy brown.
		/// </summary>
		public static Color RosyBrown => rosyBrown;

		/// <summary>
		/// Gets the royal blue.
		/// </summary>
		public static Color RoyalBlue => royalBlue;

		/// <summary>
		/// Gets the saddle brown.
		/// </summary>
		public static Color SaddleBrown => saddleBrown;

		/// <summary>
		/// Gets the salmon.
		/// </summary>
		public static Color Salmon => salmon;

		/// <summary>
		/// Gets the sandy brown.
		/// </summary>
		public static Color SandyBrown => sandyBrown;

		/// <summary>
		/// Gets the sea green.
		/// </summary>
		public static Color SeaGreen => seaGreen;

		/// <summary>
		/// Gets the sea shell.
		/// </summary>
		public static Color SeaShell => seaShell;

		/// <summary>
		/// Gets the sienna.
		/// </summary>
		public static Color Sienna => sienna;

		/// <summary>
		/// Gets the silver.
		/// </summary>
		public static Color Silver => silver;

		/// <summary>
		/// Gets the sky blue.
		/// </summary>
		public static Color SkyBlue => skyBlue;

		/// <summary>
		/// Gets the slate blue.
		/// </summary>
		public static Color SlateBlue => slateBlue;

		/// <summary>
		/// Gets the slate gray.
		/// </summary>
		public static Color SlateGray => slateGray;

		/// <summary>
		/// Gets the snow.
		/// </summary>
		public static Color Snow => snow;

		/// <summary>
		/// Gets the spring green.
		/// </summary>
		public static Color SpringGreen => springGreen;

		/// <summary>
		/// Gets the steel blue.
		/// </summary>
		public static Color SteelBlue => steelBlue;

		/// <summary>
		/// Gets the tan.
		/// </summary>
		public static Color Tan => tan;

		/// <summary>
		/// Gets the teal.
		/// </summary>
		public static Color Teal => teal;

		/// <summary>
		/// Gets the thistle.
		/// </summary>
		public static Color Thistle => thistle;

		/// <summary>
		/// Gets the tomato.
		/// </summary>
		public static Color Tomato => tomato;

		/// <summary>
		/// Gets the turquoise.
		/// </summary>
		public static Color Turquoise => turquoise;

		/// <summary>
		/// Gets the violet.
		/// </summary>
		public static Color Violet => violet;

		/// <summary>
		/// Gets the wheat.
		/// </summary>
		public static Color Wheat => wheat;

		/// <summary>
		/// Gets the white.
		/// </summary>
		public static Color White => white;

		/// <summary>
		/// Gets the white smoke.
		/// </summary>
		public static Color WhiteSmoke => whiteSmoke;

		/// <summary>
		/// Gets the yellow.
		/// </summary>
		public static Color Yellow => yellow;

		/// <summary>
		/// Gets the yellow green.
		/// </summary>
		public static Color YellowGreen => yellowGreen;

		/// <summary>
		/// Gets the inherent color, discarding its luminance.
		/// </summary>
		public Color InherentColor
		{
			get
			{
				float num = (int32)R;
				if (num < (float)(int32)G)
				{
					num = (int32)G;
				}
				if (num < (float)(int32)B)
				{
					num = (int32)B;
				}
				Color result = default(Color);
				if (num > 0f)
				{
					num = 255f / num;
					result.R = (uint8)((float)(int32)R * num);
					result.G = (uint8)((float)(int32)G * num);
					result.B = (uint8)((float)(int32)B * num);
					result.A = 1;
					return result;
				}
				result = White;
				return result;
			}
		}

		/// <summary>
		/// Gets or sets the <see cref="T:System.Byte" /> at the specified index.
		/// </summary>
		/// <param name="index">Element index.</param>
		/// <returns>The result.</returns>
		public uint8 this[int32 index]
		{
			get
			{
				switch (index)
				{
				case 0:
					return R;
				case 1:
					return G;
				case 2:
					return B;
				case 3:
					return A;
				default:
					Runtime.FatalError("Invalid Vector3 index!");
				}
			}
			set mut
			{
				switch (index)
				{
				case 0:
					R = value;
					break;
				case 1:
					G = value;
					break;
				case 2:
					B = value;
					break;
				case 3:
					A = value;
					break;
				default:
					Runtime.FatalError("Invalid Vector3 index!");
				}
			}
		}

		/// <summary>
		/// Initializes static members of the <see cref="T:Sedulous.Graphics.Color" /> struct.
		/// </summary>
		static this()
		{
			transparent = Color(0u);
			aliceBlue = Color(4294965488u);
			antiqueWhite = Color(4292340730u);
			aqua =  Color(4294967040u);
			aquamarine =  Color(4292149119u);
			azure =  Color(4294967280u);
			beige =  Color(4292670965u);
			bisque =  Color(4291093759u);
			black =  Color(4278190080u);
			blanchedAlmond =  Color(4291685375u);
			blue =  Color(4294901760u);
			blueViolet =  Color(4293012362u);
			brown =  Color(4280953509u);
			burlyWood =  Color(4287084766u);
			cadetBlue =  Color(4288716383u);
			chartreuse =  Color(4278255487u);
			chocolate =  Color(4280183250u);
			coral =  Color(4283465727u);
			cornflowerBlue =  Color(4293760356u);
			cornsilk =  Color(4292671743u);
			crimson =  Color(4282127580u);
			cyan =  Color(4294967040u);
			darkBlue =  Color(4287299584u);
			darkCyan =  Color(4287335168u);
			darkGoldenrod =  Color(4278945464u);
			darkGray =  Color(4289309097u);
			darkGreen =  Color(4278215680u);
			darkKhaki =  Color(4285249469u);
			darkMagenta =  Color(4287299723u);
			darkOliveGreen =  Color(4281297749u);
			darkOrange =  Color(4278226175u);
			darkOrchid =  Color(4291572377u);
			darkRed =  Color(4278190219u);
			darkSalmon =  Color(4286224105u);
			darkSeaGreen =  Color(4287347855u);
			darkSlateBlue =  Color(4287315272u);
			darkSlateGray =  Color(4283387695u);
			darkTurquoise =  Color(4291939840u);
			darkViolet =  Color(4292018324u);
			deepPink =  Color(4287829247u);
			deepSkyBlue =  Color(4294950656u);
			dimGray =  Color(4285098345u);
			dodgerBlue =  Color(4294938654u);
			firebrick =  Color(4280427186u);
			floralWhite =  Color(4293982975u);
			forestGreen =  Color(4280453922u);
			fuchsia =  Color(4294902015u);
			gainsboro =  Color(4292664540u);
			ghostWhite =  Color(4294965496u);
			gold =  Color(4278245375u);
			goldenrod =  Color(4280329690u);
			gray =  Color(4286611584u);
			green =  Color(4278222848u);
			greenYellow =  Color(4281335725u);
			honeydew =  Color(4293984240u);
			hotPink =  Color(4290013695u);
			indianRed =  Color(4284243149u);
			indigo =  Color(4286709835u);
			ivory =  Color(4293984255u);
			khaki =  Color(4287424240u);
			lavender =  Color(4294633190u);
			lavenderBlush =  Color(4294308095u);
			lawnGreen =  Color(4278254716u);
			lemonChiffon =  Color(4291689215u);
			lightBlue =  Color(4293318829u);
			lightCoral =  Color(4286611696u);
			lightCyan =  Color(4294967264u);
			lightGoldenrodYellow =  Color(4292016890u);
			lightGreen =  Color(4287688336u);
			lightGray =  Color(4292072403u);
			lightPink =  Color(4290885375u);
			lightSalmon =  Color(4286226687u);
			lightSeaGreen =  Color(4289376800u);
			lightSkyBlue =  Color(4294626951u);
			lightSlateGray =  Color(4288252023u);
			lightSteelBlue =  Color(4292789424u);
			lightYellow =  Color(4292935679u);
			lime =  Color(4278255360u);
			limeGreen =  Color(4281519410u);
			linen =  Color(4293325050u);
			magenta =  Color(4294902015u);
			maroon =  Color(4278190208u);
			mediumAquamarine =  Color(4289383782u);
			mediumBlue =  Color(4291624960u);
			mediumOrchid =  Color(4292040122u);
			mediumPurple =  Color(4292571283u);
			mediumSeaGreen =  Color(4285641532u);
			mediumSlateBlue =  Color(4293814395u);
			mediumSpringGreen =  Color(4288346624u);
			mediumTurquoise =  Color(4291613000u);
			mediumVioletRed =  Color(4286911943u);
			midnightBlue =  Color(4285536537u);
			mintCream =  Color(4294639605u);
			mistyRose =  Color(4292994303u);
			moccasin =  Color(4290110719u);
			navajoWhite =  Color(4289584895u);
			navy =  Color(4286578688u);
			oldLace =  Color(4293326333u);
			olive =  Color(4278222976u);
			oliveDrab =  Color(4280520299u);
			orange =  Color(4278232575u);
			orangeRed =  Color(4278207999u);
			orchid =  Color(4292243674u);
			paleGoldenrod =  Color(4289390830u);
			paleGreen =  Color(4288215960u);
			paleTurquoise =  Color(4293848751u);
			paleVioletRed =  Color(4287852763u);
			papayaWhip =  Color(4292210687u);
			peachPuff =  Color(4290370303u);
			peru =  Color(4282353101u);
			pink =  Color(4291543295u);
			plum =  Color(4292714717u);
			powderBlue =  Color(4293320880u);
			purple =  Color(4286578816u);
			red =  Color(4278190335u);
			rosyBrown =  Color(4287598524u);
			royalBlue =  Color(4292962625u);
			saddleBrown =  Color(4279453067u);
			salmon =  Color(4285694202u);
			sandyBrown =  Color(4284523764u);
			seaGreen =  Color(4283927342u);
			seaShell =  Color(4293850623u);
			sienna =  Color(4281160352u);
			silver =  Color(4290822336u);
			skyBlue =  Color(4293643911u);
			slateBlue =  Color(4291648106u);
			slateGray =  Color(4287660144u);
			snow =  Color(4294638335u);
			springGreen =  Color(4286578432u);
			steelBlue =  Color(4290019910u);
			tan =  Color(4287411410u);
			teal =  Color(4286611456u);
			thistle =  Color(4292394968u);
			tomato =  Color(4282868735u);
			turquoise =  Color(4291878976u);
			violet =  Color(4293821166u);
			wheat =  Color(4289978101u);
			white =  Color(uint32.MaxValue);
			whiteSmoke =  Color(4294309365u);
			yellow =  Color(4278255615u);
			yellowGreen =  Color(4281519514u);
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Color" /> struct.
		/// </summary>
		/// <param name="packetValue">The packet value.</param>
		public this(uint32 packetValue)
		{
			R = (uint8)(packetValue & 0xFFu);
			G = (uint8)((packetValue >> 8) & 0xFFu);
			B = (uint8)((packetValue >> 16) & 0xFFu);
			A = (uint8)((packetValue >> 24) & 0xFFu);
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Color" /> struct.
		/// </summary>
		/// <param name="v">Grayscale tone in the [0, 1] range.</param>
		public this(float v)
			: this(v, v, v)
		{
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Color" /> struct.
		/// </summary>
		/// <param name="r">Red component in the [0, 1] range.</param>
		/// <param name="g">Green component in the [0, 1] range.</param>
		/// <param name="b">Blue component in the [0, 1] range.</param>
		/// <param name="a">Alpha component in the [0, 1] range.</param>
		public this(float r, float g, float b, float a = 1f)
		{
			R = (uint8)Math.Round(r * 255f);
			G = (uint8)Math.Round(g * 255f);
			B = (uint8)Math.Round(b * 255f);
			A = (uint8)Math.Round(a * 255f);
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Color" /> struct.
		/// </summary>
		/// <param name="v">Grayscale tone.</param>
		public this(uint8 v)
			: this(v, v, v)
		{
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Color" /> struct.
		/// </summary>
		/// <param name="r">Red component.</param>
		/// <param name="g">Green component.</param>
		/// <param name="b">Blue component.</param>
		/// <param name="a">Alpha component.</param>
		public this(uint8 r, uint8 g, uint8 b, uint8 a = uint8.MaxValue)
		{
			R = r;
			G = g;
			B = b;
			A = a;
		}

		/// <summary>
		/// Implements the operator +.
		/// </summary>
		/// <param name="a">First color.</param>
		/// <param name="b">Second color.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static Color operator +(Color a, Color b)
		{
			int32 red = a.R + b.R;
			int32 green = a.G + b.G;
			int32 blue = a.B + b.B;
			int32 alpha = a.A + b.A;
			if (red > 255)
			{
				red = 255;
			}
			if (green > 255)
			{
				green = 255;
			}
			if (blue > 255)
			{
				blue = 255;
			}
			if (alpha > 255)
			{
				alpha = 255;
			}
			return Color((uint8)red, (uint8)green, (uint8)blue, (uint8)alpha);
		}

		/// <summary>
		/// Implements the operator -.
		/// </summary>
		/// <param name="a">First color.</param>
		/// <param name="b">Second color.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static Color operator -(Color a, Color b)
		{
			int32 red = a.R - b.R;
			int32 green = a.G - b.G;
			int32 blue = a.B - b.B;
			int32 alpha = a.A - b.A;
			if (red < 0)
			{
				red = 0;
			}
			if (green < 0)
			{
				green = 0;
			}
			if (blue < 0)
			{
				blue = 0;
			}
			if (alpha < 0)
			{
				alpha = 0;
			}
			return Color((uint8)red, (uint8)green, (uint8)blue, (uint8)alpha);
		}

		/// <summary>
		/// Implements the operator *.
		/// </summary>
		/// <param name="a">First color.</param>
		/// <param name="b">Second color.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static Color operator *(Color a, Color b)
		{
			int32 red = a.R * b.R / 255;
			int32 green = a.G * b.G / 255;
			int32 blue = a.B * b.B / 255;
			int32 alpha = a.A * b.A / 255;
			if (red > 255)
			{
				red = 255;
			}
			if (green > 255)
			{
				green = 255;
			}
			if (blue > 255)
			{
				blue = 255;
			}
			if (alpha > 255)
			{
				alpha = 255;
			}
			return Color((uint8)red, (uint8)green, (uint8)blue, (uint8)alpha);
		}

		/// <summary>
		/// Implements the operator *.
		/// </summary>
		/// <param name="a">First color.</param>
		/// <param name="b">Second color.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static Color operator *(Color a, float b)
		{
			return Color((uint8)Math.Round((float)(int32)a.R * b), (uint8)Math.Round((float)(int32)a.G * b), (uint8)Math.Round((float)(int32)a.B * b), (uint8)Math.Round((float)(int32)a.A * b));
		}

		/// <summary>
		/// Implements the operator *.
		/// </summary>
		/// <param name="b">First color.</param>
		/// <param name="a">Second color.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static Color operator *(float b, Color a)
		{
			return Color((uint8)Math.Round((float)(int32)a.R * b), (uint8)Math.Round((float)(int32)a.G * b), (uint8)Math.Round((float)(int32)a.B * b), (uint8)Math.Round((float)(int32)a.A * b));
		}

		/// <summary>
		/// Implements the operator /.
		/// </summary>
		/// <param name="a">First color.</param>
		/// <param name="b">Second color.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static Color operator /(Color a, float b)
		{
			return Color((uint8)Math.Round((float)(int32)a.R / b), (uint8)Math.Round((float)(int32)a.G / b), (uint8)Math.Round((float)(int32)a.B / b), (uint8)Math.Round((float)(int32)a.A / b));
		}

		/// <summary>
		/// Implements the operator ==.
		/// </summary>
		/// <param name="lhs">The LHS.</param>
		/// <param name="rhs">The RHS.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator ==(Color lhs, Color rhs)
		{
			return lhs.Equals(rhs);
		}

		/// <summary>
		/// Implements the operator !=.
		/// </summary>
		/// <param name="lhs">The LHS.</param>
		/// <param name="rhs">The RHS.</param>
		/// <returns>
		/// The result of the operator.
		/// </returns>
		public static bool operator !=(Color lhs, Color rhs)
		{
			return !lhs.Equals(rhs);
		}

		/// <summary>
		/// Lerps the specified value1.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <param name="amount">The amount.</param>
		/// <returns>The result.</returns>
		public static Color Lerp(ref Color value1, ref Color value2, float amount)
		{
			Color result = default(Color);
			result.R = (uint8)Math.Round((float)(int32)value1.R + (float)(value2.R - value1.R) * amount);
			result.G = (uint8)Math.Round((float)(int32)value1.G + (float)(value2.G - value1.G) * amount);
			result.B = (uint8)Math.Round((float)(int32)value1.B + (float)(value2.B - value1.B) * amount);
			result.A = (uint8)Math.Round((float)(int32)value1.A + (float)(value2.A - value1.A) * amount);
			return result;
		}

		/// <summary>
		/// Lerps the specified value1.
		/// </summary>
		/// <param name="value1">The value1.</param>
		/// <param name="value2">The value2.</param>
		/// <param name="amount">The amount.</param>
		/// <returns>The result.</returns>
		public static Color Lerp(Color value1, Color value2, float amount)
		{
			Color result = default(Color);
			result.R = (uint8)Math.Round((float)(int32)value1.R + (float)(value2.R - value1.R) * amount);
			result.G = (uint8)Math.Round((float)(int32)value1.G + (float)(value2.G - value1.G) * amount);
			result.B = (uint8)Math.Round((float)(int32)value1.B + (float)(value2.B - value1.B) * amount);
			result.A = (uint8)Math.Round((float)(int32)value1.A + (float)(value2.A - value1.A) * amount);
			return result;
		}

		/// <summary>
		/// Returns a hash code for this instance.
		/// </summary>
		/// <returns>
		/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
		/// </returns>
		public int GetHashCode()
		{
			return ToInt();
		}

		/// <summary>
		/// Equalses the specified other.
		/// </summary>
		/// <param name="other">The other.</param>
		/// <returns>The result.</returns>
		public bool Equals(Color other)
		{
			if (A == other.A && R == other.R && G == other.G)
			{
				return B == other.B;
			}
			return false;
		}

		/// <summary>
		/// To int32 value.
		/// </summary>
		/// <returns>Color as int32 value.</returns>
		public int ToInt()
		{
			uint8 r = R;
			int g = (.)G << 8;
			int b = (.)B << 16;
			int a = (.)A << 24;
			return r | g | b | a;
		}

		/// <summary>
		/// Converts to a Vector3.
		/// </summary>
		/// <returns>Color as a Vector3.</returns>
		public Vector3 ToVector3()
		{
			return Vector3((float)(int32)R / 255f, (float)(int32)G / 255f, (float)(int32)B / 255f);
		}

		/// <summary>
		/// Converts to a Vector3.
		/// </summary>
		/// <param name="vector">Color as a Vector3.</param>
		public void ToVector3(ref Vector3 vector)
		{
			vector.X = (float)(int32)R / 255f;
			vector.Y = (float)(int32)G / 255f;
			vector.Z = (float)(int32)B / 255f;
		}

		/// <summary>
		/// Converts Vector3 to Color.
		/// </summary>
		/// <param name="vector">Vector3 with color.</param>
		/// <returns>The color.</returns>
		public static Color FromVector3(ref Vector3 vector)
		{
			return Color(vector.X, vector.Y, vector.Z);
		}

		/// <summary>
		/// Converts Vector4 to Color.
		/// </summary>
		/// <param name="vector">Vector3 with color.</param>
		/// <param name="color">The color.</param>
		public static void FromVector3(ref Vector4 vector, out Color color)
		{
			color = Color(vector.X, vector.Y, vector.Z);
		}

		/// <summary>
		/// Converts Vector4 to Color.
		/// </summary>
		/// <param name="vector">Vector4 with color.</param>
		/// <returns>The color.</returns>
		public static Color FromVector4(ref Vector4 vector)
		{
			return Color(vector.X, vector.Y, vector.Z, vector.W);
		}

		/// <summary>
		/// Converts Vector4 to Color.
		/// </summary>
		/// <param name="vector">Vector4 with color.</param>
		/// <param name="color">The color.</param>
		public static void FromVector4(ref Vector4 vector, out Color color)
		{
			color = Color(vector.X, vector.Y, vector.Z, vector.W);
		}

		/// <summary>
		/// Converts to a Vector4.
		/// </summary>
		/// <returns>Color as a Vector4.</returns>
		public Vector4 ToVector4()
		{
			return Vector4((float)(int32)R / 255f, (float)(int32)G / 255f, (float)(int32)B / 255f, (float)(int32)A / 255f);
		}

		/// <summary>
		/// Converts to a Vector4.
		/// </summary>
		/// <param name="vector">Color as a Vector4.</param>
		public void ToVector4(out Vector4 vector)
		{
			vector.X = (float)(int32)R / 255f;
			vector.Y = (float)(int32)G / 255f;
			vector.Z = (float)(int32)B / 255f;
			vector.W = (float)(int32)A / 255f;
		}
	}
}

using System;

namespace Sedulous.GAL
{
    public struct GraphicsApiVersion
    {
        public static GraphicsApiVersion Unknown => default;

        public int32 Major { get; }
        public int32 Minor { get; }
        public int32 Subminor { get; }
        public int32 Patch { get; }

        public bool IsKnown => Major != 0 && Minor != 0 && Subminor != 0 && Patch != 0;

        public this(int32 major, int32 minor, int32 subminor, int32 patch)
        {
            Major = major;
            Minor = minor;
            Subminor = subminor;
            Patch = patch;
        }

        public override void ToString(String outStr)
        {
            outStr.AppendF("{0}.{1}.{2}.{3}", Major, Minor, Subminor, Patch);
        }

        /// <summary>
        /// Parses OpenGL version strings with either of following formats:
        /// <list type="bullet">
        ///   <item>
        ///     <description>major_number.minor_number</description>
        ///   </item>
        ///   <item>
        ///     <description>major_number.minor_number.release_number</description>
        ///   </item>
        /// </list>
        /// </summary>
        /// <param name="versionString">The OpenGL version String.</param>
        /// <param name="version">The parsed <see cref="GraphicsApiVersion"/>.</param>
        /// <returns>True whether the parse succeeded; otherwise false.</returns>
        public static bool TryParseGLVersion(String versionString, out GraphicsApiVersion version)
        {
			/*versionString.Split(' ');
            String[] versionParts = versionString.Split(' ')[0].Split('.');

            if (!int.TryParse(versionParts[0], var major) ||
               !int.TryParse(versionParts[1], var minor))
            {
                version = default;
                return false;
            }

            int releaseNumber = 0;
            if (versionParts.Count == 3)
            {
                if (!int32.TryParse(versionParts[2], out releaseNumber))
                {
                    version = default;
                    return false;
                }
            }

            version = GraphicsApiVersion(major, minor, 0, releaseNumber);*/
			version = .(0,0,0,0);
            return true;
        }
    }
}

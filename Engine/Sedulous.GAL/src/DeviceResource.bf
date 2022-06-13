using System;
namespace Sedulous.GAL
{
    /// <summary>
    /// A resource owned by a <see cref="GraphicsDevice"/>, which can be given a String identifier for debugging and
    /// informational purposes.
    /// </summary>
    public interface DeviceResource
    {
        /// <summary>
        /// A String identifying this instance. Can be used to differentiate between objects in graphics debuggers and other
        /// tools.
        /// </summary>
        String Name { get; set; }
    }
}

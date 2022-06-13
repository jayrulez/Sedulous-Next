using System;
using System.Threading;

namespace Sedulous.GAL.Vulkan
{
    internal class ResourceRefCount
    {
        private readonly Action _disposeAction = null;
        private int32 _refCount;

        public this(Action disposeAction)
        {
            _disposeAction = disposeAction;
            _refCount = 1;
        }

		public ~this(){
			if(_disposeAction != null){
				delete _disposeAction;
			}
		}

        public int32 Increment()
        {
            int32 ret = Interlocked.Increment(ref _refCount);
#if VALIDATE_USAGE
            if (ret == 0)
            {
                Runtime.FatalError("An attempt was made to reference a disposed resource.");
            }
#endif
            return ret;
        }

        public int32 Decrement()
        {
            int32 ret = Interlocked.Decrement(ref _refCount);
            if (ret == 0)
            {
                _disposeAction();
            }

            return ret;
        }
    }
}

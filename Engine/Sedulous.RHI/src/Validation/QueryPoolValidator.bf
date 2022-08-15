using System.Collections;
using System;
namespace Sedulous.RHI.Validation
{
	class QueryPoolValidator : QueryPool
	{
		private readonly DeviceValidator mDevice;
		private readonly QueryPool mQueryPool;

		private List<uint64> m_DeviceState;
		private uint32 m_QueryNum;
		private QueryType m_QueryType;

		private readonly String mDebugName = new .() ~ delete _;

		public this(DeviceValidator device, QueryPool queryPool, QueryType queryType, uint32 queryNum)
		{
			mDevice = device;
			mQueryPool = queryPool;
			m_QueryType = queryType;

			m_DeviceState = Allocate!<List<uint64>>(mDevice.GetDeviceAllocator());

			m_QueryNum = queryNum;

			if (queryNum != 0)
			{
				readonly int batchNum = Math.Max(queryNum >> 6, 1u);
				m_DeviceState.Resize(batchNum, 0);
			}
		}

		public ~this()
		{
			Deallocate!(mDevice.GetDeviceAllocator(), m_DeviceState);
		}

		public override void SetDebugName(System.StringView name)
		{
			mDebugName.Set(name);
			mQueryPool.SetDebugName(name);
		}

		public String GetDebugName() => mDebugName;

		public override uint32 GetQuerySize()
		{
			return mQueryPool.GetQuerySize();
		}

		public  uint32 GetQueryNum()
		{
			return m_QueryNum;
		}

		public  QueryType GetQueryType()
		{
			return m_QueryType;
		}

		public  bool IsImported()
		{
			return m_QueryNum == 0;
		}

		public  bool SetQueryState(uint32 offset, bool state)
		{
			readonly int batchIndex = offset >> 6;
			readonly uint64 batchValue = m_DeviceState[batchIndex];
			readonly int bitIndex = 1uL << (offset & 63);
			readonly uint64 maskBitValue = (.)~bitIndex;
			readonly uint64 bitValue = state ? (.)bitIndex : 0;
			m_DeviceState[batchIndex] = (batchValue & maskBitValue) | bitValue;
			return batchValue & (.)bitIndex != 0;
		}

		public void ResetQueries(uint32 offset, uint32 number)
		{
			for (uint32 i = 0; i < number; i++)
				SetQueryState(offset + i, false);
		}
	}
}
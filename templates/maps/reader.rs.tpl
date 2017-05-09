<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisDecoder, CanDecode, EnumMap, RangeEnum};
use ::wire::{ArtemisUpdateDecoder, CanDecodeUpdate};
use ::packet::enums::{ConsoleStatus, ShipIndex, TubeIndex, TubeStatus, OrdnanceType, UpgradeType};

impl<T> CanDecode<EnumMap<T, ConsoleStatus>> for EnumMap<T, ConsoleStatus> where
    T: RangeEnum
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..T::HIGHEST+1 {
            data.push(rdr.read_enum8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecode<EnumMap<ShipIndex, bool>> for EnumMap<ShipIndex, bool>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..<ShipIndex as RangeEnum>::HIGHEST+1 {
            data.push(rdr.read_bool8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecode<EnumMap<UpgradeType, bool>> for EnumMap<UpgradeType, bool> where
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..<UpgradeType as RangeEnum>::HIGHEST+1 {
            data.push(rdr.read_bool8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl<E, V> CanDecode<EnumMap<E, V>> for EnumMap<E, V> where
    E: RangeEnum,
    V: CanDecode<V>,
{
    default fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..E::HIGHEST+1 {
            data.push(rdr.read()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecode<EnumMap<TubeIndex, TubeStatus>> for EnumMap<TubeIndex, TubeStatus>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..<TubeIndex as RangeEnum>::HIGHEST+1 {
            data.push(rdr.read_enum8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecode<EnumMap<TubeIndex, OrdnanceType>> for EnumMap<TubeIndex, OrdnanceType>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..<TubeIndex as RangeEnum>::HIGHEST+1 {
            data.push(rdr.read_enum8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl<E, V> CanDecodeUpdate<EnumMap<E, Option<V>>> for EnumMap<E, Option<V>> where
    E: RangeEnum,
    V: CanDecode<V>,
{
    default fn read(rdr: &mut ArtemisUpdateDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..E::HIGHEST+1 {
            data.push(rdr.read()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecodeUpdate<EnumMap<TubeIndex, Option<TubeStatus>>> for EnumMap<TubeIndex, Option<TubeStatus>>
{
    fn read(rdr: &mut ArtemisUpdateDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..<TubeIndex as RangeEnum>::HIGHEST+1 {
            data.push(rdr.read_enum8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecodeUpdate<EnumMap<TubeIndex, Option<OrdnanceType>>> for EnumMap<TubeIndex, Option<OrdnanceType>>
{
    fn read(rdr: &mut ArtemisUpdateDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..<TubeIndex as RangeEnum>::HIGHEST+1 {
            data.push(rdr.read_enum8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecodeUpdate<EnumMap<UpgradeType, Option<bool>>> for EnumMap<UpgradeType, Option<bool>> where
{
    fn read(rdr: &mut ArtemisUpdateDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..<UpgradeType as RangeEnum>::HIGHEST+1 {
            data.push(rdr.read_bool8()?);
        }
        Ok(EnumMap::new(data))
    }
}

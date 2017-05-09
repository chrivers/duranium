<% import rust %>\
${rust.header()}

use std::convert::From;
use std::io::Result;

use ::wire::{ArtemisDecoder, CanDecode, EnumMap};
use ::wire::{ArtemisUpdateDecoder, CanDecodeUpdate};
use ::packet::enums::{ConsoleType, ConsoleStatus, ShipIndex, ShipSystem, BeamFrequency, TubeIndex, TubeStatus, OrdnanceType};

impl CanDecode<EnumMap<ConsoleType, ConsoleStatus>> for EnumMap<ConsoleType, ConsoleStatus>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(ConsoleType::GameMaster)+1 {
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
        for _ in 0..u32::from(ShipIndex::Player8)+1 {
            data.push(rdr.read_bool8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl<T> CanDecode<EnumMap<ShipIndex, T>> for EnumMap<ShipIndex, T>
    where T: CanDecode<T>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(ShipIndex::Player8)+1 {
            data.push(rdr.read()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl<T> CanDecode<EnumMap<ShipSystem, T>> for EnumMap<ShipSystem, T>
    where T: CanDecode<T>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(ShipSystem::AftShields)+1 {
            data.push(rdr.read()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl<T> CanDecode<EnumMap<BeamFrequency, T>> for EnumMap<BeamFrequency, T>
    where T: CanDecode<T>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(BeamFrequency::E)+1 {
            data.push(rdr.read()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecode<EnumMap<TubeIndex, f32>> for EnumMap<TubeIndex, f32>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(TubeIndex::Tube6)+1 {
            data.push(rdr.read_f32()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecode<EnumMap<TubeIndex, TubeStatus>> for EnumMap<TubeIndex, TubeStatus>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(TubeIndex::Tube6)+1 {
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
        for _ in 0..u32::from(TubeIndex::Tube6)+1 {
            data.push(rdr.read_enum8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl<T> CanDecodeUpdate<EnumMap<ShipSystem, Option<T>>> for EnumMap<ShipSystem, Option<T>>
    where T: CanDecode<T>
{
    fn read(rdr: &mut ArtemisUpdateDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(ShipSystem::AftShields)+1 {
            data.push(rdr.read()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl<T> CanDecodeUpdate<EnumMap<BeamFrequency, Option<T>>> for EnumMap<BeamFrequency, Option<T>>
    where T: CanDecode<T>
{
    fn read(rdr: &mut ArtemisUpdateDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(BeamFrequency::E)+1 {
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
        for _ in 0..u32::from(TubeIndex::Tube6)+1 {
            data.push(rdr.read_enum8()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecodeUpdate<EnumMap<TubeIndex, Option<f32>>> for EnumMap<TubeIndex, Option<f32>>
{
    fn read(rdr: &mut ArtemisUpdateDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(TubeIndex::Tube6)+1 {
            data.push(rdr.read_f32()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl CanDecodeUpdate<EnumMap<TubeIndex, Option<OrdnanceType>>> for EnumMap<TubeIndex, Option<OrdnanceType>>
{
    fn read(rdr: &mut ArtemisUpdateDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(TubeIndex::Tube6)+1 {
            data.push(rdr.read_enum8()?);
        }
        Ok(EnumMap::new(data))
    }
}

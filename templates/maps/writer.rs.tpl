<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisEncoder, CanEncode, EnumMap};
use ::wire::{ArtemisUpdateEncoder, CanEncodeUpdate};
use ::packet::enums::{ConsoleType, ConsoleStatus, ShipIndex, ShipSystem, BeamFrequency, TubeIndex, TubeStatus, OrdnanceType};

impl CanEncode for EnumMap<ConsoleType, ConsoleStatus> where
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_enum8(*elm)?;
        }
        Ok(())
    }
}

impl CanEncode for EnumMap<ShipIndex, bool> where
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_bool8(*elm)?;
        }
        Ok(())
    }
}

impl<T> CanEncode for EnumMap<ShipIndex, T> where
    T: CanEncode
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(elm)?;
        }
        Ok(())
    }
}

impl<T> CanEncodeUpdate for EnumMap<ShipSystem, Option<T>> where
    T: CanEncode
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(&elm.as_ref())?;
        }
        Ok(())
    }
}

impl<T> CanEncodeUpdate for EnumMap<BeamFrequency, Option<T>> where
    T: CanEncode
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(&elm.as_ref())?;
        }
        Ok(())
    }
}

impl CanEncodeUpdate for EnumMap<TubeIndex, Option<TubeStatus>> where
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_enum8(elm)?;
        }
        Ok(())
    }
}

impl CanEncodeUpdate for EnumMap<TubeIndex, Option<OrdnanceType>> where
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_enum8(elm)?;
        }
        Ok(())
    }
}

impl CanEncodeUpdate for EnumMap<TubeIndex, Option<f32>> where
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_f32(&elm)?;
        }
        Ok(())
    }
}

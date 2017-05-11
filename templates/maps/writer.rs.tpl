<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisEncoder, CanEncode, EnumMap, RangeEnum};
use ::wire::{ArtemisUpdateEncoder, CanEncodeUpdate};
use ::packet::enums::ConsoleType;
use ::wire::types::*;

impl<S, T> CanEncode for Size<S, T> where
    Self: Repr<S> + Copy,
    S: CanEncode,
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        wtr.write::<S>(&Repr::encode(*self))
    }
}

impl<E, V> CanEncode for EnumMap<E, V> where
    E: RangeEnum,
    V: CanEncode
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(elm)?;
        }
        Ok(())
    }
}

impl<E, V> CanEncodeUpdate for EnumMap<E, Option<V>> where
    E: RangeEnum,
    V: CanEncode,
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(&elm.as_ref())?;
        }
        Ok(())
    }
}

impl CanEncode for Option<Size<u32, ConsoleType>> where
    Option<Size<u32, ConsoleType>>: Repr<u32>
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        wtr.write(&Repr::encode(*self))
    }
}

<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisEncoder, CanEncode, EnumMap, RangeEnum};
use ::wire::{ArtemisUpdateEncoder, CanEncodeUpdate};
use ::packet::enums::ConsoleType;
use ::packet::structs::ShipV240;
use ::wire::types::*;

impl<'a, E> CanEncode for &'a EnumMap<E, ShipV240> where
    E: RangeEnum,
{
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        let vals = self.get_ref();
        for elm in vals {
            wtr.write(elm)?;
        }
        Ok(())
    }
}

impl<S, T> CanEncode for Size<S, T> where
    Self: Repr<S> + Copy,
    S: CanEncode + Copy,
{
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        wtr.write::<S>(Repr::encode(self))
    }
}

impl<'a, E, R, T> CanEncode for &'a EnumMap<E, Size<R, T>> where
    E: RangeEnum,
    R: CanEncode + Copy,
    T: Copy,
    Size<R, T>: Repr<R>,
{
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(*elm)?;
        }
        Ok(())
    }
}

impl<'a, E, V> CanEncodeUpdate for &'a EnumMap<E, Option<V>> where
    E: RangeEnum,
    V: CanEncode + Copy,
{
    fn write(self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(*elm)?;
        }
        Ok(())
    }
}

impl<'a> CanEncode for &'a Option<Size<u32, ConsoleType>> where
    Option<Size<u32, ConsoleType>>: Repr<u32>
{
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        wtr.write(Repr::encode(*self))
    }
}

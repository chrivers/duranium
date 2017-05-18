<% import rust %>\
${rust.header()}

use std::io::Result;
use ::wire::types::Field;

use ::wire::{EnumMap, RangeEnum};
use ::wire::{ArtemisEncoder, CanEncode};

impl<'a, E, V> CanEncode for &'a EnumMap<E, Field<V>> where
    E: RangeEnum,
    V: CanEncode + Copy,
{
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(*elm)?;
        }
        Ok(())
    }
}

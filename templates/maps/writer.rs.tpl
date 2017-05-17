<% import rust %>\
${rust.header()}

use std::io::Result;
use ::wire::types::Field;

use ::wire::{CanEncode, EnumMap, RangeEnum};
use ::wire::{ArtemisUpdateEncoder, CanEncodeUpdate};

impl<'a, E, V> CanEncodeUpdate for &'a EnumMap<E, Field<V>> where
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

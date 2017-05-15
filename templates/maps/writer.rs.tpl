<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisEncoder, CanEncode, EnumMap, RangeEnum};
use ::wire::{ArtemisUpdateEncoder, CanEncodeUpdate};

impl<'a, E, T> CanEncode for &'a EnumMap<E, T> where
    E: RangeEnum,
    for <'b> &'b T: CanEncode,
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

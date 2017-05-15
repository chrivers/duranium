<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisDecoder, CanDecode, EnumMap, RangeEnum};
use ::wire::{ArtemisUpdateDecoder, CanDecodeUpdate};

impl<E, V> CanDecode for EnumMap<E, V> where
    E: RangeEnum,
    V: CanDecode,
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..E::HIGHEST+1 {
            data.push(rdr.read()?);
        }
        Ok(EnumMap::new(data))
    }
}

impl<E, V> CanDecodeUpdate for EnumMap<E, Option<V>> where
    E: RangeEnum,
    V: CanDecode,
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

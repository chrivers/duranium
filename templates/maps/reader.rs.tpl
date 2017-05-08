<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisDecoder, CanDecode, EnumMap};
use ::packet::enums::{ConsoleType, ConsoleStatus, GameShip};

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

impl CanDecode<EnumMap<GameShip, bool>> for EnumMap<GameShip, bool>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mut data = vec![];
        for _ in 0..u32::from(GameShip::Player8)+1 {
            data.push(rdr.read_bool8()?);
        }
        Ok(EnumMap::new(data))
    }
}

<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisEncoder, CanEncode, EnumMap};
use ::packet::enums::{ConsoleType, ConsoleStatus, ShipIndex};

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

<% import rust %>\
${rust.header()}

use std::io::{Error, ErrorKind, Result};

use ::wire::{ArtemisDecoder, ArtemisEncoder};
use ::wire::{CanDecode, CanEncode};
use ::packet::enums::*;

% for flag in flags:
impl CanDecode for ${flag.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        ${flag.name}::from_bits(rdr.read()?).ok_or_else(|| Error::new(ErrorKind::InvalidData, "could not parse ${flag.name} bitflags"))
    }
}

impl CanEncode for ${flag.name} {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        wtr.write(self.bits())
    }
}

% endfor

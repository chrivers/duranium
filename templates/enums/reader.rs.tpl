<% import rust %>\
${rust.header()}

use std::io::{Error, ErrorKind, Result};

use ::wire::ArtemisDecoder;
use ::wire::CanDecode;
use ::packet::enums::*;

% for enum in enums.without("FrameType"):
impl From<u32> for ${enum.name} {
    fn from(n: u32) -> ${enum.name} {
        match n {
            % for case in enum.fields:
            ${case.aligned_hex_value} => ${enum.name}::${case.name},
            % endfor
            val => ${enum.name}::__Unknown(val as u32)
        }
    }
}

% endfor

% for flag in flags:
impl CanDecode for ${flag.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        ${flag.name}::from_bits(rdr.read()?).ok_or_else(|| Error::new(ErrorKind::InvalidData, "could not parse ${flag.name} bitflags"))
    }
}
% endfor

impl CanDecode for Option<Size<u32, ConsoleType>> where
    Option<Size<u32, ConsoleType>>: Repr<u32>,
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        Ok(Repr::decode(rdr.read::<u32>()?))
    }
}

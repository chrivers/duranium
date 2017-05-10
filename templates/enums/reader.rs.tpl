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
impl CanDecode for ${flag.name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        ${flag.name}::from_bits(rdr.read_u32()?).ok_or(Error::new(ErrorKind::InvalidData, "could not parse ${flag.name} bitflags"))
    }
}
% endfor

impl CanDecode for Option<ConsoleType>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        rdr.read_u32().map(|x| match x { 0 => None, n => Some(ConsoleType::from(n - 1)) })
    }
}

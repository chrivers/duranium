<% import rust %>\
${rust.header()}

use std::io;

use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;
use ::packet::enums::*;

% for enum in enums.without("FrameType"):
impl From<${enum.name}> for u32 {
    fn from(n: ${enum.name}) -> u32 {
        match n {
            % for case in enum.fields:
            ${enum.name}::${case.aligned_name} => ${case.aligned_hex_value},
            % endfor
            ${enum.name}::__Unknown(val) => val
        }
    }
}

% endfor

% for flag in flags:
impl CanEncode for ${flag.name}
{
    fn write(&self, mut wtr: &mut ArtemisEncoder) -> io::Result<()>
    {
        wtr.write_u32(self.bits())
    }
}
% endfor

impl CanEncode for Option<ConsoleType>
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> io::Result<()>
    {
        wtr.write_u32(self.map_or(0, |ct| u32::from(ct) + 1))
    }
}

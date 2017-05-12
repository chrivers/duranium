<% import rust %>\
${rust.header()}

use std::io;

use ::wire::ArtemisEncoder;
use ::wire::CanEncode;
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
        wtr.write(&self.bits())
    }
}
% endfor

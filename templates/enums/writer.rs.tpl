<% import rust %>\
${rust.header()}

use std::io;
use num::ToPrimitive;

use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;
use ::packet::enums::*;

% for enum in enums.without("FrameType"):
impl ToPrimitive for ${enum.name} {
    fn to_i64(&self) -> Option<i64> {
        Self::to_u64(self).map(|x| x as i64)
    }

    fn to_u64(&self) -> Option<u64> {
        match self {
            % for case in enum.fields:
            &${enum.name}::${case.aligned_name} => Some(${case.aligned_hex_value}),
            % endfor
            &${enum.name}::__Unknown(val) => Some(val as u64)
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

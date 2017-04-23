<% import rust %>\
${rust.header()}

use num::ToPrimitive;
use ::packet::enums::*;

% for enum in enums:
<% if enum.name == "FrameType": continue %>\
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
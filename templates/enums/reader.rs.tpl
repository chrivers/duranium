<% import rust %>\
${rust.header()}

use num::FromPrimitive;
use ::packet::enums::*;

% for enum in enums:
<% if enum.name == "FrameType": continue %>\
impl FromPrimitive for ${enum.name} {
    fn from_i64(n: i64) -> Option<${enum.name}> {
        return Self::from_u64((n & 0xFFFFFFFFi64) as u64);
    }

    fn from_u64(n: u64) -> Option<${enum.name}> {
        match n {
            % for case in enum.fields:
            ${case.aligned_hex_value} => Some(${enum.name}::${case.name}),
            % endfor
            val => Some(${enum.name}::__Unknown(val as u32))
        }
    }
}

% endfor

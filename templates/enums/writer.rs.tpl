<% import rust %>\
${rust.header()}

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

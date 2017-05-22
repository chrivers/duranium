<% import rust %>\
${rust.header()}

use ::wire::types::*;
use ::wire::RangeEnum;

macro_rules! repr_impl {
    ($name:ident, $tp:ty) => {
        impl Repr<$tp> for super::$name {
            fn decode(x: $tp) -> Self { Self::from(x as u32) }
            fn encode(self) -> $tp { (u32::from(self)) as $tp }
        }
    }
}

% for enum in enums.without("FrameType"):
repr_impl!{ ${enum.name}, u8 }
repr_impl!{ ${enum.name}, u32 }
% endfor

% for enum in enums.without("FrameType"):
impl Default for super::${enum.name.ljust(20)} { fn default() -> Self { super::${enum.name}::${enum.fields[0].name} } }
% endfor

% for enum in enums.without("FrameType"):
impl RangeEnum for super::${enum.name.ljust(20)} { const HIGHEST: usize = ${enum.fields[-1].aligned_hex_value}; }
% endfor

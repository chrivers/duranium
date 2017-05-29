<% import rust %>\
${rust.header()}

use packet::prelude::*;

macro_rules! repr_impl {
    ($name:ident, $tp:ty) => {
        impl Repr<$tp> for super::$name {
            fn decode(x: $tp) -> Self { Self::from(x as u32) }
            fn encode(self) -> $tp { (u32::from(self)) as $tp }
        }
    }
}

% for enum in enums:
repr_impl!{ ${enum.name}, u8 }
repr_impl!{ ${enum.name}, u32 }
% endfor

% for enum in enums:
impl Default for super::${enum.name.ljust(20)} { fn default() -> Self { super::${enum.name}::${enum.consts[0].name} } }
% endfor

% for enum in enums:
impl RangeEnum for super::${enum.name.ljust(20)} { const HIGHEST: usize = ${enum.consts[-1].aligned_hex_value}; }
% endfor

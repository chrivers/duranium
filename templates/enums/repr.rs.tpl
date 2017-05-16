<% import rust %>\
${rust.header()}

use ::wire::types::*;

% for enum in enums.without("FrameType"):
impl Repr<u8> for super::${enum.name} {
    fn decode(x: u8) -> Self { Self::from(x as u32) }
    fn encode(self) -> u8 { (u32::from(self)) as u8 }
}

impl Repr<u32> for super::${enum.name} {
    fn decode(x: u32) -> Self { Self::from(x as u32) }
    fn encode(self) -> u32 { (u32::from(self)) as u32 }
}

% endfor

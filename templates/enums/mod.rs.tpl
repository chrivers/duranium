<% import rust %>\
${rust.header()}

mod repr;
mod snowflakes;
mod reader;
mod writer;

use packet::prelude::*;

% for enum in enums.without("FrameType"):
#[derive(PartialEq,Debug,Copy,Clone)]
pub enum ${enum.name} {
    % for case in enum.fields:
    ${case.name},
    % endfor
    __Unknown(u32),
}

% endfor
pub mod frametype {
    #![allow(non_upper_case_globals)]
    % for case in enums.get("FrameType").fields:
    pub const ${case.aligned_name} : u32 = ${case.aligned_hex_value};
    % endfor
}

pub mod mediacommand {
    #![allow(non_upper_case_globals)]
    % for case in enums.get("MediaCommand").fields:
    pub const ${case.aligned_name} : u32 = ${case.aligned_hex_value};
    % endfor
}

% for en in enums.without("FrameType"):
diff_impl!(${en.name});
apply_impl!(${en.name});
% endfor

<% import rust %>\
${rust.header()}

mod repr;
mod snowflakes;
mod reader;
mod writer;

use packet::prelude::*;

% for enum in _enums:
#[derive(PartialEq,Debug,Copy,Clone)]
pub enum ${enum.name} {
    % for case in enum.consts:
    ${case.name},
    % endfor
    __Unknown(u32),
}

% endfor

% for en in _enums:
diff_impl!(${en.name});
apply_impl!(${en.name});
% endfor

% for blk in _parser:
% if blk.expr == "enum":
pub mod ${blk.name.lower()} {
    #![allow(non_upper_case_globals)]
    % for case in blk.consts:
    pub const ${case.aligned_name} : u32 = ${case.aligned_hex_value};
    % endfor
}

% endif
% endfor

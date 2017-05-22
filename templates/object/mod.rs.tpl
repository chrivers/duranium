<% import rust %>\
${rust.header()}

pub mod reader;
pub mod apply;
pub mod diff;
pub mod new;

use wire::types::*;

use super::enums;

pub type ObjectID = u32;

% for object in objects:
#[derive(Debug,Default)]
pub struct ${object.name} {
% for field in object.fields:
    % if not loop.first:

    % endif
    % for line in util.format_comment(field.comment, indent="// ", width=74):
    ${line}
    % endfor
    pub ${field.name}: ${rust.declare_struct_type(field.type)},
% endfor
}

% endfor

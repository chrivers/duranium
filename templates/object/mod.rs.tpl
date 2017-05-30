<% import rust %>\
${rust.header()}

mod reader;
mod apply;
mod diff;
mod new;

use packet::prelude::*;

% for object in _objects:
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

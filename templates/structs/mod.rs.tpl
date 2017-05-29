<% import rust %>\
${rust.header()}
mod reader;
mod writer;

use packet::prelude::*;

pub use super::update::{Update};
pub use super::server::{ObjectUpdatesV210, ObjectUpdatesV240};
pub use super::update::{UpdateV210, UpdateV240};

% for struct in structs:
#[derive(Debug)]
pub struct ${struct.name} {
    % for field in struct.fields:
    % if not loop.first:

    % endif
    % for line in util.format_comment(field.comment, indent="/// ", width=74):
    ${line}
    % endfor
    pub ${field.name}: ${rust.declare_struct_type(field.type)},
    % endfor
}

% endfor

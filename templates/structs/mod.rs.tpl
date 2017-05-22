<% import rust %>\
${rust.header()}
pub mod reader;
pub mod writer;

use packet::prelude::*;

pub use super::update::ObjectUpdate;
pub use super::server::MediaPacket;

% for struct in structs.without("Update"):
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

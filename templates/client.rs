<% import rust as lang %>\
pub mod reader;
pub mod writer;

use ::packet::server::Ship;
use ::packet::enums::*;

<% packet = packets.get("ClientPacket") %>\
#[derive(Debug)]
pub enum ${packet.name}
{
    % for case in packet.fields:
    ${case.name}
    {
        % for index, field in enumerate(case.fields):
        % if index > 0:

        % endif
        % for line in util.format_comment(field.comment, indent="/// ", width=74):
        ${line}
        % endfor
        ${field.name}: ${lang.rust_type(field.type)},
        % endfor
    },

    % endfor
}

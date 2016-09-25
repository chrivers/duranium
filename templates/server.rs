pub mod reader;
pub mod writer;

use ::packet::server::Ship;
use ::packet::enums::*;

<% packet = packets.get("ServerPacket") %>\
#[derive(Debug)]
pub enum ${packet.name}
{
    % for name, case in packet.fields.items():
    ${case.name}
    {
        % for index, field in enumerate(case.fields.values()):
        % if index > 0:

        % endif
        % for line in format_comment(field.comment, indent="/// ", width=73):
        ${line}
        % endfor
        ${field.name}: ${field.type},
        % endfor
    },

    % endfor
}

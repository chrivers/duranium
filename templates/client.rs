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
        % for field in case.fields:
        % for line in format_comment(field.comment, indent="/// "):
        ${line}
        % endfor
        ${field.name}: ${field.type},
        % endfor
    },
    
    % endfor
}

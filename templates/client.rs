pub mod reader;
pub mod writer;

use ::packet::server::Ship;
use ::packet::enums::*;

<% packet = packets[0] %>\
#[derive(Debug)]
pub enum ${packet[0]}
{
    % for case in packet[1]:
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

pub mod reader;
pub mod writer;

use ::packet::server::Ship;
use ::packet::enums::*;

<% packet = packets[0] %>\
#[derive(Debug)]
pub enum ${packet[0]}
{
    % for case in packet[1]:
    ${case[0]}
    {
        % for field in case[1]:
        % for line in format_comment(field[2], indent="/// "):
        ${line}
        % endfor
        ${field[0]}: ${field[1]},
        % endfor
    },
    
    % endfor
}

<% import rust %>\
pub mod reader;
pub mod writer;
pub mod object;
pub mod update;

use ::packet::enums::*;
use ::packet::structs::*;
use ::packet::server::update::ObjectUpdate;

use std::collections::HashMap;
<% packet = packets.get("ServerPacket") %>\
#[derive(Debug)]
#[allow(non_camel_case_types)]
pub enum ${packet.name}
{
    % for case in packet.fields:
    ${case.name}
    {
        % for field in case.fields:
        % if not loop.first:

        % endif
        % for line in util.format_comment(field.comment, indent="/// ", width=74):
        ${line}
        % endfor
        ${field.name}: ${rust.declare_type(field.type)},
        % endfor
    },

    % endfor
}

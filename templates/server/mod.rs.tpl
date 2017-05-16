<% import rust %>\
${rust.header()}
pub mod reader;
pub mod writer;

use ::packet::enums;
use ::packet::structs::*;
use ::packet::update::ObjectUpdate;
use ::wire::EnumMap;
use ::wire::types::*;

% for packet in [packets.get("ServerPacket"), packets.get("MediaPacket")]:
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
        ${field.name}: ${rust.declare_struct_type(field.type)},
        % endfor
    },

    % endfor
}

% endfor

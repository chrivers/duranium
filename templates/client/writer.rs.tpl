#![allow(dead_code)]

use std::io;
use std::io::Result;

use ::packet::enums::frametype;
use ::packet::client::ClientPacket;
use ::stream::FrameWriter;
use ::wire::ArtemisEncoder;

pub struct ClientPacketWriter
{
}

impl ClientPacketWriter
{
    pub fn new() -> Self { ClientPacketWriter { } }
}

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

macro_rules! packet_type {
    ($wtr:ident, $major:expr) => {
        try!($wtr.write_u32($major));
    };
    ($wtr:ident, $major:expr, $minor:expr) => {
        try!($wtr.write_u32($major));
        try!($wtr.write_u32($minor));
    };
}
<%
def visit(parser, res):
    for field in parser.fields:
        if field.type.name == "struct":
            res[field.type.arg] = (field.type, field.name, None, None)
        elif field.type.name == "parser":
            prs = parsers.get(field.type.arg)
            for fld in prs.fields:
                res[fld.type.arg] = (fld.type, field.name, fld.name, prs.arg)

def get_packet(type):
    if "::" in name:
        packetname, casename = name.split("::",1)
        return packets.get(packetname).fields.get(casename)
    else:
        return packets.get(name)

packet_ids = dict()
parser = parsers.get("ClientParser")
visit(parser, packet_ids)

def get_padding(info):
    packet = get_packet(info[0])
    if info[1] == "valueInt":
        return 1 - len(packet.fields)
    elif info[1] == "valueFourInts":
        return 4 - len(packet.fields)
    else:
        return 0
%>
<%def name="write_field(name, fld, type)">\
% if type.name == "sizedarray":
for num in ${fld.name}.iter() { try!(wtr.write_f32(*num)); }\
% elif type.name == "struct":
try!(${fld.name}.write(&mut wtr));
% elif name == "ClientPacket::GameMasterMessage" and fld.name == "console_type":
try!(wtr.write_u32(console_type.map_or(0, |ct| ct as u32 + 1)));\
% else:
try!(wtr.write_${type.name}(${fld.name}));\
% endif
</%def>\
impl FrameWriter for ClientPacketWriter
{
    type Frame = ClientPacket;
    fn write_frame(&mut self, frame: &Self::Frame) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        match frame
        {
        % for name, info in sorted(packet_ids.items()):
            &${name} {
            % for fld in get_packet(info[0]).fields:
            % if fld.type.name in ("string", "struct"):
                ref ${fld.name},
            % else:
                ${fld.name},
            % endif
            % endfor
            } => {
            % if info[2]:
                packet_type!(wtr, frametype::${info[1]}, ${info[2]});
            % else:
                packet_type!(wtr, frametype::${info[1]});
            % endif
            % for fld in get_packet(info[0]).fields:
                ${write_field(name, fld, fld.type)}
                ## try!(wtr.write_${fld.type.name}(${fld.name}));
            % endfor
            % for x in range(get_padding(info)):
                % if loop.first:
                // padding
                % endif
                try!(wtr.write_u32(0));
            % endfor
            },

        % endfor
        }
        Ok(wtr.into_inner())
    }
}

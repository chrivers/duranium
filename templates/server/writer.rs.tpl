#![allow(dead_code)]

use std::io;
use std::io::Result;

use ::stream::FrameWriter;
use ::wire::ArtemisEncoder;
use ::packet::enums::*;
use ::packet::structs::*;
use ::packet::server::ServerPacket;
use ::packet::server::update::ObjectUpdateWriter;

pub struct ServerPacketWriter
{
}

impl ServerPacketWriter
{
    pub fn new() -> Self { ServerPacketWriter { } }
}

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

macro_rules! packet_type {
    ($wtr:ident, $major:expr) => {
        try!($wtr.write_u32($major));
    };
    ($wtr:ident, $major:expr, $minor:expr => u8) => {
        try!($wtr.write_u32($major));
        try!($wtr.write_u8($minor));
    };
    ($wtr:ident, $major:expr, $minor:expr) => {
        try!($wtr.write_u32($major));
        try!($wtr.write_u32($minor));
    };
}


impl Ship
{
    pub fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        try!(wtr.write_enum32(self.drive_type));
        try!(wtr.write_u32(self.ship_type));
        try!(wtr.write_u32(self.accent_color));
        try!(wtr.write_u32(self.__unknown_1));
        try!(wtr.write_string(&self.name));
        Ok(())
    }
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
parser = parsers.get("ServerParser")
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
try!(wtr.write_array(${fld.name}));\
% elif type.name == "array":
%   if not type.arg:
try!(wtr.write_array(${fld.name}));\
%   elif len(type.arg) <= 4:
try!(wtr.write_array_u8(${fld.name}, ${type.arg}));\
%   else:
try!(wtr.write_array_u32(${fld.name}, ${type.arg}));\
%   endif
% elif type.name == "struct":
try!(${fld.name}.write(&mut wtr));
% elif name == "ClientPacket::GameMasterMessage" and fld.name == "console_type":
try!(wtr.write_u32(console_type.map_or(0, |ct| ct as u32 + 1)));\
% else:
try!(wtr.write_${type.name}(${fld.name}));\
% endif
</%def>\
impl FrameWriter for ServerPacketWriter
{
    type Frame = ServerPacket;
    fn write_frame(&mut self, frame: &Self::Frame) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        match frame
        {
        % for name, info in sorted(packet_ids.items()):
            &${name}
            {
            % for fld in get_packet(info[0]).fields:
            % if fld.type.name in ("ascii_string", "string", "struct", "option", "array", "sizedarray", "map"):
                ref ${fld.name},
            % else:
                ${fld.name},
            % endif
            % endfor
            } => {
            % if info[2] and info[3] == "u8":
                packet_type!(wtr, frametype::${info[1]}, ${info[2]}u8 => u8);
            % elif info[2]:
                packet_type!(wtr, frametype::${info[1]}, ${info[2]});
            % else:
                packet_type!(wtr, frametype::${info[1]});
            % endif
            % for fld in get_packet(info[0]).fields:
                ${write_field(name, fld, fld.type)}
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

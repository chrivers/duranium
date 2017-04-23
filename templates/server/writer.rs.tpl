<% import rust %>\
${rust.header()}
use std::io::Result;

use ::stream::FrameWriter;
use ::wire::ArtemisEncoder;
use ::wire::traits::IterEnum;
use ::packet::enums::*;
use ::packet::structs::*;
use ::packet::server::ServerPacket;

pub struct ServerPacketWriter
{
}

impl ServerPacketWriter
{
    pub fn new() -> Self { ServerPacketWriter { } }
}

macro_rules! packet_type {
    ($wtr:ident, $major:expr) => {
        $wtr.write_u32($major)?;
    };
    ($wtr:ident, $major:expr, $minor:expr => u8) => {
        $wtr.write_u32($major)?;
        $wtr.write_u8($minor)?;
    };
    ($wtr:ident, $major:expr, $minor:expr) => {
        $wtr.write_u32($major)?;
        $wtr.write_u32($minor)?;
    };
}


impl Ship
{
    pub fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        wtr.write_enum32(self.drive_type)?;
        wtr.write_u32(self.ship_type)?;
        wtr.write_f32(self.accent_hue)?;
        wtr.write_u32(self.__unknown_1)?;
        wtr.write_string(&self.name)?;
        Ok(())
    }
}
<%
def visit(parser, res):
    for field in parser.fields:
        if field.type.name == "struct":
            res[field.type[0].name] = (field.type, field.name, None, None)
        elif field.type.name == "parser":
            prs = parsers.get(field.type[0].name)
            for fld in prs.fields:
                res[fld.type[0].name] = (fld.type, field.name, fld.name, prs.arg)

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
                ${rust.write_field(name, fld.name, fld.type)};
            % endfor
            % for x in range(get_padding(info)):
                % if loop.first:
                // padding
                % endif
                wtr.write_u32(0)?;
            % endfor
            },

        % endfor
        }
        Ok(wtr.into_inner())
    }
}

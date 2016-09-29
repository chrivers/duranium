use std::io;
use std::collections::HashMap;

use ::wire::{ArtemisDecoder};
use ::frame::{ArtemisPayload};
use ::stream::{FrameReader, FrameReadAttempt};
use ::packet::enums::*;
use ::packet::structs::*;
use ::packet::server::ServerPacket;
use ::packet::server::update::ObjectUpdateReader;

#[derive(Debug)]
pub struct ServerPacketReader
{
}

impl ServerPacketReader
{
    pub fn new() -> Self { ServerPacketReader { } }
}

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

<%def name="get_packet(name)">\
<%
  if "::" in name:
    packetname, casename = name.split("::",1)
    return packets.get(packetname).fields.get(casename)
  else:
    return packets.get(name)
%>
</%def>\
<%def name="get_parser(name)">\
<%
  return parsers.get(name)
%>
</%def>\
<%def name="read_field(pkt, fld)">\
% if pkt.type.arg == "ServerPacket::SetShipSettingsV240" and fld.name == "ship":
try_parse!(Ship::read(&mut rdr))\
% elif pkt.type.arg == "ServerPacket::__unknown_4" and fld.name == "__unknown_1":
[\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()) \
]\
% elif pkt.type.arg == "ServerPacket::GameMasterMessage" and fld.name == "console_type":
{ match try_parse!(rdr.read_u32()) { 0 => None, n => Some(try_enum!(ConsoleType, n - 1)) } }\
% else:
try_parse!(rdr.read_${fld.type.name}())\
% endif
</%def>\
<% parser = parsers.get("ServerParser") %>\
impl FrameReader for ServerPacketReader
{
    type Frame = ArtemisPayload;
    type Error = io::Error;

    fn read_frame(&mut self, buffer: &[u8]) -> FrameReadAttempt<Self::Frame, Self::Error>
    {
        let mut rdr = ArtemisDecoder::new(buffer);

        return FrameReadAttempt::Ok(0, ArtemisPayload::ServerPacket(match try_parse!(rdr.read_u32()) {

            % for parser in [parser]:
            % for field in parser.fields:
            % if field.type.name == "struct":
            frametype::${field.name} => ${field.type.arg} {
                % for fld in get_packet(field.type.arg).fields:
                ${fld.name}: ${read_field(field, fld)},
                % endfor
            },
            % else:
            supertype @ frametype::${field.name} => {
                match try_parse!(rdr.read_${get_parser(field.type.arg).arg}()) {
                % for pkt in get_parser(field.type.arg).fields:
                    ${pkt.name} => ${pkt.type.arg} {
                        % for fld in get_packet(pkt.type.arg).fields:
                        ${fld.name}: ${read_field(pkt, fld)},
                        % endfor
                    },
                    % endfor
                    subtype => return FrameReadAttempt::Error(make_error(&format!("Server frame 0x{:08x} unknown subtype: 0x{:02x} (length {})", supertype, subtype, buffer.len())))
                }
            },
            % endif

            % endfor
            % endfor
            supertype => return FrameReadAttempt::Error(make_error(&format!("Unknown server frame type 0x{:08x} (length {})", supertype, buffer.len()))),
        }))
    }
}

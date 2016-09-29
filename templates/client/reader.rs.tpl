#![allow(dead_code)]

use std::io;
use enum_primitive::FromPrimitive;

use ::packet::enums::{ConsoleType, frametype};
use ::frame::{ArtemisPayload};
use ::stream::{FrameReader, FrameReadAttempt};
use ::packet::client::*;
use ::wire::{ArtemisDecoder};
use ::packet::structs::Ship;

#[derive(Debug)]
pub struct ClientPacketReader
{
}

impl ClientPacketReader
{
    pub fn new() -> Self { ClientPacketReader { } }
}

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

macro_rules! try_enum {
    ($t:tt, $n:expr) => {
        match $t::from_u32($n) {
            None => return FrameReadAttempt::Error(
                make_error(&format!("unknown {} 0x{:02x}", stringify!($t), $n))
            ),
            Some(x) => x,
        }
    }
}
<%def name="get_packet(name)">\
<%
  packetname, casename = name.split("::",1)
  return packets.get(packetname).fields.get(casename)
%>
</%def>\
<%def name="get_parser(name)">\
<%
  return parsers.get(name)
%>
</%def>\
<%def name="read_field(pkt, fld)">\
% if pkt.type.arg == "ClientPacket::SetShipSettingsV240" and fld.name == "ship":
try_parse!(Ship::read(&mut rdr))\
% elif pkt.type.arg == "ClientPacket::__unknown_4" and fld.name == "__unknown_1":
[\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()),\
 try_parse!(rdr.read_f32()) \
]\
% elif pkt.type.arg == "ClientPacket::GameMasterMessage" and fld.name == "console_type":
{ match try_parse!(rdr.read_u32()) { 0 => None, n => Some(try_enum!(ConsoleType, n - 1)) } }\
% else:
try_parse!(rdr.read_${fld.type.name}())\
% endif
</%def>\
<% parser = parsers.get("ClientParser") %>
impl FrameReader for ClientPacketReader
{
    type Frame = ArtemisPayload;
    type Error = io::Error;

    fn read_frame(&mut self, buffer: &[u8]) -> FrameReadAttempt<Self::Frame, Self::Error>
    {
        let mut rdr = ArtemisDecoder::new(buffer);
        return FrameReadAttempt::Ok(0, ArtemisPayload::ClientPacket(match try_parse!(rdr.read_u32()) {

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
                let subtype = try_parse!(rdr.read_${parser.arg}());
                match subtype {
                % for pkt in get_parser(field.type.arg).fields:
                    ${pkt.name} => ${pkt.type.arg} {
                        % for fld in get_packet(pkt.type.arg).fields:
                        ${fld.name}: ${read_field(pkt, fld)},
                        % endfor
                    },
                    % endfor
                    subtype => return FrameReadAttempt::Error(make_error(&format!("Client frame 0x{:08x} unknown subtype: 0x{:02x} (length {})", supertype, subtype, buffer.len())))
                }
            },
            % endif

            % endfor
            % endfor
            supertype => return FrameReadAttempt::Error(make_error(&format!("Unknown client frame type 0x{:08x} (length {})", supertype, buffer.len())))
        }))
    }
}

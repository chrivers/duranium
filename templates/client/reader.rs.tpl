#![allow(dead_code)]

use std::io;
use enum_primitive::FromPrimitive;

use ::packet::enums::{ConsoleType, frametype};
use ::frame::{ArtemisPayload};
use ::stream::{FrameReader, FrameReadAttempt};
use ::packet::PacketID;
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
<%def name="get_packet(field)">\
<%
  packetname, casename = field.type.arg.split("::",1)
  return packets.get(packetname).fields.get(casename)
%>
</%def>
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
                % for fld in get_packet(field).fields:
                ${fld.name}: try_parse!(rdr.read_${fld.type.name}()),
                % endfor
            },
            % else:
            supertype @ frametype::${field.name} => {
            },
            % endif
            % endfor
            % endfor
            supertype => return FrameReadAttempt::Error(make_error(&format!("Unknown client frame type 0x{:08x} (length {})", supertype, buffer.len())))
        }))
    }
}

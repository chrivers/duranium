<% import rust %>\
#![allow(dead_code)]

use std::io;
use enum_primitive::FromPrimitive;

use ::packet::enums::{ConsoleType, frametype};
use ::frame::{ArtemisPayload};
use ::stream::{FrameReader, FrameReadAttempt};
use ::packet::client::*;
use ::wire::{ArtemisDecoder};

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
            frametype::${field.name} => ${field.type[0].name} {
                % for fld in rust.get_packet(field.type[0].name).fields:
                ${fld.name}: ${rust.read_struct_field_parse(fld.type)},
                % endfor
            },
            % else:
            supertype @ frametype::${field.name} => {
                match try_parse!(rdr.read_${parser.arg}()) {
                % for pkt in rust.get_parser(field.type[0].name).fields:
                    ${pkt.name} => ${pkt.type[0].name} {
                        % for fld in rust.get_packet(pkt.type[0].name).fields:
                        ${fld.name}: ${rust.read_struct_field_parse(fld.type)},
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

<% import rust %>\
${rust.header()}
use std::io;

use ::wire::{ArtemisDecoder};
use ::frame::{ArtemisPayload};
use ::stream::{FrameReader, FrameReadAttempt, FramePoll};
use ::packet::enums::*;
use ::packet::server::ServerPacket;
use ::packet::update::reader::read_frame_stream;

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

<% parser = parsers.get("ServerParser") %>\
impl FrameReader for ServerPacketReader
{
    type Frame = ArtemisPayload;
    type Error = io::Error;

    fn read_frame(&mut self, buffer: &[u8]) -> FrameReadAttempt<Self::Frame, Self::Error>
    {
        let mut rdr = ArtemisDecoder::new(buffer);

        return Ok(FramePoll::Ready(0, ArtemisPayload::ServerPacket(match rdr.read_u32()? {

            % for field in parser.fields:
            % if field.type.name == "struct":
            frametype::${field.name} => ${field.type[0].name} {
                % for fld in rust.get_packet(field.type[0].name).fields:
                ${fld.name}: trace_field_read!("${field.type[0].name}", "${fld.name}", ${rust.read_struct_field_parse(fld.type)}),
                % endfor
            },
            % else:
            supertype @ frametype::${field.name} => {
                match rdr.read_${rust.get_parser(field.type[0].name).arg}()? {
                % for pkt in rust.get_parser(field.type[0].name).fields:
                    ${pkt.name} => ${pkt.type[0].name} {
                        % for fld in rust.get_packet(pkt.type[0].name).fields:
                        ${fld.name}: trace_field_read!("${pkt.type[0].name}", "${fld.name}", ${rust.read_struct_field_parse(fld.type)}),
                        % endfor
                    },
                    % endfor
                    subtype => return Err(make_error(&format!("Server frame 0x{:08x} unknown subtype: 0x{:02x} (length {})", supertype, subtype, buffer.len())))
                }
            },
            % endif

            % endfor
            supertype => return Err(make_error(&format!("Unknown server frame type 0x{:08x} (length {})", supertype, buffer.len()))),
        }))
    )}
}

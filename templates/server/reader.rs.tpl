<% import rust %>\
${rust.header()}
use std::io;

use ::wire::{ArtemisDecoder};
use ::frame::{ArtemisPayload};
use ::stream::{FrameReader, FrameReadAttempt};
use ::packet::enums::*;
use ::packet::server::ServerPacket;
use ::packet::server::update::{ObjectUpdate, ObjectUpdateReader};

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

fn read_frame_stream(buffer: &[u8], rdr: &mut ArtemisDecoder) -> FrameReadAttempt<Vec<ObjectUpdate>, io::Error> {
    let mut updates = vec![];
    let mut uprdr = ObjectUpdateReader::new();
    let mut pos = rdr.position() as usize;
    loop {
        // if pos == buffer.len()-1 {
        //     return FrameReadAttempt::Closed
        // } else if pos >= buffer.len() {
        //     return FrameReadAttempt::Error(make_error("tried to read past end of array"));
        // }
        match uprdr.read_frame(&buffer[pos..]) {
            FrameReadAttempt::Closed => break,
            FrameReadAttempt::NeedBytes(bytes) => return FrameReadAttempt::NeedBytes(bytes),
            FrameReadAttempt::Error(e) => return FrameReadAttempt::Error(e),
            FrameReadAttempt::Ok(size, upd) => {
                pos += size;
                updates.push(upd);
            }
        }
    }
    FrameReadAttempt::Ok(pos, updates)
}

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
            frametype::${field.name} => ${field.type[0].name} {
                % for fld in rust.get_packet(field.type[0].name).fields:
                ${fld.name}: {
                    trace!("Reading field ${field.name}::${fld.name}");
                    let f = ${rust.read_struct_field_parse(fld.type)};
                    trace!("  -> {:?}", f);
                    f
                },
                % endfor
            },
            % else:
            supertype @ frametype::${field.name} => {
                match try_parse!(rdr.read_${rust.get_parser(field.type[0].name).arg}()) {
                % for pkt in rust.get_parser(field.type[0].name).fields:
                    ${pkt.name} => ${pkt.type[0].name} {
                        % for fld in rust.get_packet(pkt.type[0].name).fields:
                        ${fld.name}: {
                          trace!("Reading field ${field.name}::${fld.name}");
                          let f = ${rust.read_struct_field_parse(fld.type)};
                          trace!("  -> {:?}", f);
                          f
                        },
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

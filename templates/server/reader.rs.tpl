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
<%def name="read_field(pkt, name, type)">\
% if pkt.type.arg == "ServerPacket::ObjectUpdate" and name == "updates":
try_subparse!(read_frame_stream(buffer, &mut rdr))\
% elif type.name == "sizedarray":
[ \
% for x in range(type.arg):
% if not loop.first:
, \
% endif
${read_field(pkt, name, type.target)}\
% endfor
 ]\
% elif type.name == "array":
%   if not type.arg:
try_parse!(rdr.read_array())\
%   elif len(type.arg) <= 4:
try_parse!(rdr.read_array_u8(${type.arg}))\
%   else:
try_parse!(rdr.read_array_u32(${type.arg}))\
%   endif
% elif type.name == "map":
try_parse!(rdr.read_struct())\
% elif type.name == "option":
rdr.read_${type.target.name}().ok()\
% else:
try_parse!(rdr.read_${type.name}())\
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
                ${fld.name}: ${read_field(field, fld.name, fld.type)},
                % endfor
            },
            % else:
            supertype @ frametype::${field.name} => {
                match try_parse!(rdr.read_${get_parser(field.type.arg).arg}()) {
                % for pkt in get_parser(field.type.arg).fields:
                    ${pkt.name} => ${pkt.type.arg} {
                        % for fld in get_packet(pkt.type.arg).fields:
                        ${fld.name}: ${read_field(pkt, fld.name, fld.type)},
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

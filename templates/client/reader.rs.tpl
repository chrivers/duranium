<% import rust %>\
${rust.header()}

use std::io;
use std::io::Result;

use ::packet::enums::frametype;
use ::packet::client::*;
use ::wire::{ArtemisDecoder};
use ::wire::traits::{CanDecode};
use ::wire::trace;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

<% parser = parsers.get("ClientParser") %>
impl CanDecode<ClientPacket> for ClientPacket
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<ClientPacket>
    {
        return Ok(match rdr.read_u32()? {

            % for field in parser.fields:
            % if field.type.name == "struct":
            frametype::${field.name} => { trace::struct_read("${field.type[0].name}"); ${field.type[0].name} {
                % for fld in rust.get_packet(field.type[0].name).fields:
                ${fld.name}: parse_field!("${fld.name}", ${rust.read_struct_field(fld.type)}),
                % endfor
            } },
            % else:
            supertype @ frametype::${field.name} => {
                match rdr.read_${parser.arg}()? {
                % for pkt in rust.get_parser(field.type[0].name).fields:
                    ${pkt.name} => { trace::struct_read("${pkt.type[0].name}"); ${pkt.type[0].name} {
                        % for fld in rust.get_packet(pkt.type[0].name).fields:
                        ${fld.name}: parse_field!("${fld.name}", ${rust.read_struct_field(fld.type)}),
                        % endfor
                    } },
                    % endfor
                    subtype => return Err(make_error(&format!("Client frame 0x{:08x} unknown subtype: 0x{:02x}", supertype, subtype)))
                }
            },
            % endif

            % endfor
            supertype => return Err(make_error(&format!("Unknown client frame type 0x{:08x}", supertype)))
        })
    }
}

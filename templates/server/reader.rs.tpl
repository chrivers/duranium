<% import rust %>\
${rust.header()}

use std::io;
use std::io::Result;

use ::packet::enums::frametype;
use ::wire::ArtemisDecoder;
use ::wire::traits::CanDecode;
use ::packet::server::ServerPacket;


fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

<% parser = parsers.get("ServerParser") %>\
impl CanDecode<ServerPacket> for ServerPacket
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<ServerPacket>
    {
        return Ok(match rdr.read_u32()? {

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
                    subtype => return Err(make_error(&format!("Server frame 0x{:08x} unknown subtype: 0x{:02x}", supertype, subtype)))
                }
            },
            % endif

            % endfor
            supertype => return Err(make_error(&format!("Unknown server frame type 0x{:08x}", supertype))),
        })
    }
}

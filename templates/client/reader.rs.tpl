<% import rust %>\
${rust.header()}

use std::io::{Result, Error, ErrorKind};

use ::packet::enums::frametype;
use ::wire::ArtemisDecoder;
use ::wire::CanDecode;
use ::wire::trace;
use super::ClientPacket;

<% parser = parsers.get("ClientParser") %>
impl CanDecode for ClientPacket
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        match rdr.read::<u32>()? {
            % for field in parser.fields:
            % if field.type.name == "struct":
            frametype::${field.name.ljust(15)} => Ok(ClientPacket::${field.type[0].name.split("::", 1)[-1]}(rdr.read()?)),
            % else:
            frametype::${field.name.ljust(15)} => match rdr.read::<${rust.get_parser(field.type[0].name).arg}>()? {
                % for pkt in rust.get_parser(field.type[0].name).fields:
                ${pkt.name} => Ok(ClientPacket::${pkt.type[0].name.split("::", 1)[-1]}(rdr.read()?)),
                % endfor
                subtype => Err(Error::new(ErrorKind::InvalidData, format!("Client frame 0x{:08x} unknown subtype: 0x{:02x}", frametype::${field.name}, subtype)))
            },
            % endif
            % endfor
            supertype => Err(Error::new(ErrorKind::InvalidData, format!("Unknown client frame type 0x{:08x}", supertype)))
        }
    }
}

% for lname, info in sorted(rust.generate_packet_ids("ClientParser").items()):
<% name = lname.split("::", 1)[-1] %>\
impl CanDecode for super::${name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::packet_read("${name}");
        let res = super::${name} {
            % for fld in rust.get_packet("ClientPacket::%s" % name).fields:
            ${fld.name}: parse_field!("packet", "${fld.name}", ${rust.read_struct_field(fld.type)}),
            % endfor
        };
        % for x in range(rust.get_packet_padding(rust.get_packet(lname), info[1])):
        rdr.read::<u32>()?; // padding
        % endfor
        Ok(res)
    }
}

% endfor

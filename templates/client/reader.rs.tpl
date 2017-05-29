<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::enums::frametype;
use super::ClientPacket;

<% parser = parsers.get("ClientParser") %>
impl CanDecode for ClientPacket
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        match rdr.read::<u32>()? {
            % for field in parser.fields:
            % if field.type.name == "struct":
            frametype::${field.name.ljust(15)} => Ok(ClientPacket::${field.type[0].name}(rdr.read()?)),
            % else:
            frametype::${field.name.ljust(15)} => match rdr.read::<${field.type.link.arg.name}>()? {
                % for pkt in field.type.link.fields:
                ${pkt.name} => Ok(ClientPacket::${pkt.type[0].name}(rdr.read()?)),
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
        trace::packet_read("ClientPacket::${name}");
        Ok(super::${name} {
            % for fld in client.get("ClientPacket").get(lname).fields:
            ${fld.aligned_name}: parse_field!("packet", "${fld.name}", rdr.read()?),
            % endfor
        })
    }
}

% endfor

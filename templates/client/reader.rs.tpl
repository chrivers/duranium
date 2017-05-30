<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::enums::frametype;
use super::ClientPacket;

impl CanDecode for ClientPacket
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        match rdr.read::<u32>()? {
            % for field in _parser.get("ClientParser").fields:
            % if field.type.name == "struct":
            frametype::${field.aligned_name} => Ok(ClientPacket::${field.type[0].name}(rdr.read()?)),
            % else:
            frametype::${field.aligned_name} => match rdr.read::<${field.type[0][0]}>()? {
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

% for packet in _client.get("ClientPacket"):
impl CanDecode for super::${packet.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::packet_read("ClientPacket::${packet.name}");
        Ok(super::${packet.name} {
            % for fld in packet.fields:
            ${fld.aligned_name}: parse_field!("packet", "${fld.name}", rdr.read()?),
            % endfor
        })
    }
}

% endfor

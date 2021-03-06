<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::enums::{frametype, mediacommand};
use super::{ServerPacket, MediaPacket};

% for packet in _server:
<% parser = packet.field("@parser").type.link %>\
<% prefix = parser.field("@type").type.link.name.lower() %>\
impl CanDecode for ${packet.name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        match rdr.read::<u32>()? {
            % for field in parser.fields:
            % if field.type.name == "struct":
            ${prefix}::${field.aligned_name} => Ok(${packet.name}::${field.type[0].name} ( rdr.read()? )),
            % else:
            ${prefix}::${field.aligned_name} => {
                match rdr.read::<${field.type[0][0]}>()? {
                    % for pkt in field.type.link.fields:
                    ${pkt.name} => Ok(${packet.name}::${pkt.type[0].name} ( rdr.read()? )),
                    % endfor
                    subtype => Err(Error::new(ErrorKind::InvalidData, format!("Server frame 0x{:08x} unknown subtype: 0x{:02x}", ${prefix}::${field.name}, subtype)))
                }
            },
            % endif
            % endfor
            supertype => Err(Error::new(ErrorKind::InvalidData, format!("Unknown server frame type 0x{:08x}", supertype))),
        }
    }
}

% for case in packet:
impl CanDecode for super::${case.name} {
    fn read(_rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::packet_read("${packet.name}::${case.name}");
        Ok(super::${case.name} {
            % for fld in case.fields:
            ${fld.aligned_name} : parse_field!("packet", "${fld.name}", _rdr.read()?),
            % endfor
        })
    }
}

% endfor
% endfor

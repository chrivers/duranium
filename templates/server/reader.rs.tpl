<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::enums::{frametype, mediacommand};
use super::{ServerPacket, MediaPacket};

% for name, prefix, parser in [("ServerPacket", "frametype", parsers.get("ServerParser")), ("MediaPacket", "mediacommand", parsers.get("MediaParser")) ]:
impl CanDecode for ${name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        match rdr.read::<u32>()? {
            % for field in parser.fields:
            % if field.type.name == "struct":
            ${prefix}::${field.aligned_name} => Ok(${name}::${field.type[0].name} ( rdr.read()? )),
            % else:
            ${prefix}::${field.aligned_name} => {
                match rdr.read::<${field.type.link.arg.name}>()? {
                    % for pkt in field.type.link.fields:
                    ${pkt.name} => Ok(${name}::${pkt.type[0].name} ( rdr.read()? )),
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
% endfor

% for prefix, parser in [("ServerPacket", "ServerParser"), ("MediaPacket", "MediaParser")]:
% for name, info in rust.generate_packet_ids(parser):
impl CanDecode for super::${name} {
    fn read(_rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::packet_read("${prefix}::${name}");
        Ok(super::${name} {
            % for fld in server.get(prefix).get(name).fields:
            ${fld.aligned_name} : parse_field!("packet", "${fld.name}", _rdr.read()?),
            % endfor
        })
    }
}

% endfor
% endfor

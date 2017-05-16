<% import rust %>\
${rust.header()}

use std::io::{Result, Error, ErrorKind};

use ::packet::enums::{frametype, mediacommand};
use ::wire::ArtemisDecoder;
use ::wire::CanDecode;
use ::wire::trace;
use super::{ServerPacket, MediaPacket};

% for name, prefix, parser in [("ServerPacket", "frametype", parsers.get("ServerParser")), ("MediaPacket", "mediacommand", parsers.get("MediaParser")) ]:
impl CanDecode for ${name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        Ok(match rdr.read::<u32>()? {

            % for field in parser.fields:
            % if field.type.name == "struct":
            ${prefix}::${field.name.ljust(20)} => { trace::packet_read("${field.type[0].name}"); ${field.type[0].name} ( rdr.read()? ) },
            % else:
            ${prefix}::${field.name.ljust(20)} => {
                match rdr.read::<${rust.get_parser(field.type[0].name).arg}>()? {
                % for pkt in rust.get_parser(field.type[0].name).fields:
                    ${pkt.name} => { trace::packet_read("${pkt.type[0].name}"); ${pkt.type[0].name} ( rdr.read()? ) },
                    % endfor
                    subtype => return Err(Error::new(ErrorKind::InvalidData, format!("Server frame 0x{:08x} unknown subtype: 0x{:02x}", ${prefix}::${field.name}, subtype)))
                }
            },
            % endif
            % endfor
            supertype => return Err(Error::new(ErrorKind::InvalidData, format!("Unknown server frame type 0x{:08x}", supertype))),
        })
    }
}
% endfor

% for prefix, parser in [("ServerPacket", "ServerParser"), ("MediaPacket", "MediaParser") ]:
% for lname, info in sorted(rust.generate_packet_ids(parser).items()):
<% name = lname.split("::", 1)[-1] %>\
impl CanDecode for super::${name} {
    fn read(_rdr: &mut ArtemisDecoder) -> Result<Self> {
        Ok(super::${name} {
            % for fld in rust.get_packet("%s::%s" % (prefix, name)).fields:
            ${fld.name}: parse_field!("packet", "${fld.name}", _rdr.read()?),
            % endfor
        })
    }
}

% endfor
% endfor

<% import rust %>\
${rust.header()}

use std::io::{Result, Error, ErrorKind};

use ::packet::enums::frametype;
use ::packet::client::ClientPacket;
use ::wire::ArtemisEncoder;
use ::wire::CanEncode;
use ::wire::trace;
use packet::client;

impl<'a> CanEncode for &'a ClientPacket {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        match self {
        % for name, info in sorted(rust.generate_packet_ids("ClientParser").items()):
            &${name}(ref pkt) => {
                trace::packet_write("${name}");
                wtr.write::<u32>(frametype::${info[1]})?;
            % if info[2]:
                wtr.write::<u32>(${info[2]})?;
            % endif
                wtr.write(pkt)
            },
        % endfor
            _ => Err(Error::new(ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

% for lname, info in sorted(rust.generate_packet_ids("ClientParser").items()):
<% name = lname.split("::", 1)[-1] %>\
impl<'a> CanEncode for &'a client::${name} {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        % for fld in rust.get_packet(lname).fields:
        write_field!("packet", "${fld.name}", self.${fld.name}, ${rust.write_struct_field("self.%s" % fld.name, fld.type, False)});
        % endfor
        % for x in range(rust.get_packet_padding(rust.get_packet(lname), info[1])):
        wtr.write::<u32>(0)?; // padding
        % endfor
        Ok(())
    }
}

% endfor

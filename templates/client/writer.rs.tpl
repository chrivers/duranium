<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::enums::frametype;
use packet::client::ClientPacket;
use packet::client;

macro_rules! write_packet {
    ($name:expr, $major:expr, None,        $wtr:ident, $pkt:ident) => {{
        trace::packet_write($name);
        $wtr.write::<u32>($major)?;
        $wtr.write($pkt)
    }};
    ($name:expr, $major:expr, $minor:expr, $wtr:ident, $pkt:ident) => {{
        trace::packet_write($name);
        $wtr.write::<u32>($major)?;
        $wtr.write::<u32>($minor)?;
        $wtr.write($pkt)
    }};
}

impl<'a> CanEncode for &'a ClientPacket {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        match *self {
        % for name, info in sorted(rust.generate_packet_ids("ClientParser").items()):
            ClientPacket::${name}(ref pkt) => write_packet!("ClientPacket::${name}", frametype::${info[1]}, ${info[2]}, wtr, pkt),
        % endfor
            _ => Err(Error::new(ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

% for lname, info in sorted(rust.generate_packet_ids("ClientParser").items()):
<% name = lname.split("::", 1)[-1] %>\
impl<'a> CanEncode for &'a client::${name} {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        % for fld in client.get("ClientPacket").get(lname).fields:
        write_field!("packet", "${fld.name}", self.${fld.name}, ${rust.write_struct_field("self.%s" % fld.name, fld.type)});
        % endfor
        Ok(())
    }
}

% endfor

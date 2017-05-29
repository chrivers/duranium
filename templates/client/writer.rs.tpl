<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::enums::frametype;
use super::ClientPacket;

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

% for name, info in sorted(rust.generate_packet_ids("ClientParser").items()):
impl<'a> CanEncode for &'a super::${name} {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        % for fld in client.get("ClientPacket").get(name).fields:
        write_field!("packet", "${fld.name}", self.${fld.name}, ${rust.write_struct_field(fld)});
        % endfor
        Ok(())
    }
}

% endfor

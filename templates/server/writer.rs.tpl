<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::enums::{frametype, mediacommand};
use super::{ServerPacket, MediaPacket};

macro_rules! write_packet {
    ($name:expr, $major:expr, $minor:expr, None,   $wtr:ident, $pkt:ident) => {{
        trace::packet_write($name);
        $wtr.write::<u32>($major)?;
        $wtr.write($pkt)
    }};
    ($name:expr, $major:expr, $minor:expr, $tp:ty, $wtr:ident, $pkt:ident) => {{
        trace::packet_write($name);
        $wtr.write::<u32>($major)?;
        $wtr.write::<$tp>($minor)?;
        $wtr.write($pkt)
    }};
}

% for name, prefix, parser in [("ServerPacket", "frametype", "ServerParser"), ("MediaPacket", "mediacommand", "MediaParser") ]:
impl<'a> CanEncode for &'a ${name} {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        match *self {
        % for fname, info in rust.generate_packet_ids(parser):
            ${name}::${fname}(ref pkt) => write_packet!("${name}::${fname}", ${prefix}::${info[1]}, ${info[2]}, ${info[3]}, wtr, pkt),
        % endfor
        % if name == "ServerPacket":
        ref unknown => return Err(Error::new(ErrorKind::InvalidData, format!("unknown server packet type [{:?}]", unknown))),
        % endif
        }
    }
}
% endfor

% for prefix, parser in [("ServerPacket", "ServerParser"), ("MediaPacket", "MediaParser") ]:
% for name, info in rust.generate_packet_ids(parser):
impl<'a> CanEncode for &'a super::${name} {
    fn write(self, _wtr: &mut ArtemisEncoder) -> Result<()> {
        % for fld in server.get(prefix).get(name).fields:
        ${rust.write_struct_field("packet", fld)};
        % endfor
        Ok(())
    }
}

% endfor
% endfor

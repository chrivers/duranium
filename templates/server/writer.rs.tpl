<% import rust %>\
${rust.header()}

use packet::prelude::*;
use super::enums::{frametype, mediacommand};
use super::{ServerPacket, MediaPacket};

macro_rules! write_packet {
    ($name:expr, $major:expr, $tp:ty, None,        $wtr:ident, $pkt:ident) => {{
        trace::packet_write($name);
        $wtr.write::<u32>($major)?;
        $wtr.write($pkt)
    }};
    ($name:expr, $major:expr, $tp:ty, $minor:expr, $wtr:ident, $pkt:ident) => {{
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
        % for name, info in sorted(rust.generate_packet_ids(parser).items()):
            ${name}(ref pkt) => write_packet!("${name}", ${prefix}::${info[1]}, ${info[3]}, ${info[2]}, wtr, pkt),
        % endfor
        }
    }
}
% endfor

% for prefix, parser in [("ServerPacket", "ServerParser"), ("MediaPacket", "MediaParser") ]:
% for lname, info in sorted(rust.generate_packet_ids(parser).items()):
<% name = lname.split("::", 1)[-1] %>\
impl<'a> CanEncode for &'a super::${name} {
    fn write(self, _wtr: &mut ArtemisEncoder) -> Result<()> {
        % for fld in rust.get_packet("%s::%s" % (prefix, name)).fields:
        write_field!("packet", "${fld.name}", self.${fld.name}, _${rust.write_struct_field("self.%s" % fld.name, fld.type)});
        % endfor
        Ok(())
    }
}

% endfor
% endfor

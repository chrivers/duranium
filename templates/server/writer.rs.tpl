<% import rust %>\
${rust.header()}
use std::io::Result;

use ::packet::enums::{frametype, mediacommand};
use ::wire::ArtemisEncoder;
use ::wire::CanEncode;
use ::wire::trace;

use ::packet::server::{ServerPacket, MediaPacket};

% for name, prefix, parser in [("ServerPacket", "frametype", "ServerParser"), ("MediaPacket", "mediacommand", "MediaParser") ]:
impl<'a> CanEncode for &'a ${name}
{
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        match self
        {
        % for name, info in sorted(rust.generate_packet_ids(parser).items()):
            &${name}(ref pkt) => {
                trace::packet_write("${name}");
                wtr.write::<u32>(${prefix}::${info[1]})?;
            % if info[2]:
                wtr.write::<${info[3]}>(${info[2]})?;
            % endif
                wtr.write(pkt)
            },

        % endfor
        }
    }
}
% endfor

% for prefix, parser in [("ServerPacket", "ServerParser"), ("MediaPacket", "MediaParser") ]:
% for lname, info in sorted(rust.generate_packet_ids(parser).items()):
<% name = lname.split("::", 1)[-1] %>\
impl<'a> CanEncode for &'a super::${name}
{
    fn write(self, _wtr: &mut ArtemisEncoder) -> Result<()>
    {
        % for fld in rust.get_packet("%s::%s" % (prefix, name)).fields:
        write_field!("packet", "${fld.name}", self.${fld.name}, _${rust.write_struct_field("self.%s" % fld.name, fld.type)});
        % endfor
        Ok(())
    }
}

% endfor
% endfor

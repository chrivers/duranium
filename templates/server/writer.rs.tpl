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
            &${name}
            {
            % for fld in rust.get_packet(name).fields:
                ${rust.ref_struct_field(fld)},
            % endfor
            } => {
                trace::packet_write("${name}");
                wtr.write::<u32>(${prefix}::${info[1]})?;
            % if info[2]:
                wtr.write::<${info[3]}>(${info[2]})?;
            % endif
            % for fld in rust.get_packet(name).fields:
                write_field!("packet", "${fld.name}", &${fld.name}, ${rust.write_struct_field(fld.name, fld.type, True)});
            % endfor
            },

        % endfor
        }
        Ok(())
    }
}
% endfor

<% import rust %>\
${rust.header()}

use std::io::Result;
use num::ToPrimitive;

use ::packet::enums::frametype;
use ::packet::client::ClientPacket;
use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;

impl CanEncode for ClientPacket
{
    fn write(&self, mut wtr: &mut ArtemisEncoder) -> Result<()>
    {
        match self
        {
        % for name, info in sorted(rust.generate_packet_ids("ClientParser").items()):
            &${name} {
            % for fld in rust.get_packet(name).fields:
                ${rust.ref_struct_field(fld)},
            % endfor
            } => {
                wtr.write_u32(frametype::${info[1]})?;
            % if info[2]:
                wtr.write_u32(${info[2]})?;
            % endif
            % for fld in rust.get_packet(name).fields:
                ${rust.write_struct_field(name, fld.name, fld.type)};
            % endfor
            % for x in range(rust.get_packet_padding(rust.get_packet(name), info[1])):
                % if loop.first:
                // padding
                % endif
                wtr.write_u32(0)?;
            % endfor
            },

        % endfor
        }
        Ok(())
    }
}

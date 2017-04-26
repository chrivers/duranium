<% import rust %>\
${rust.header()}
use std::io::Result;

use ::packet::enums::frametype;
use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;
use ::wire::trace;

use ::packet::server::ServerPacket;

impl CanEncode for ServerPacket
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        match self
        {
        % for name, info in sorted(rust.generate_packet_ids("ServerParser").items()):
            &${name}
            {
            % for fld in rust.get_packet(name).fields:
                ${rust.ref_struct_field(fld)},
            % endfor
            } => {
                trace::struct_write("${name}");
                wtr.write_u32(frametype::${info[1]})?;
            % if info[2] and info[3] == "u8":
                wtr.write_u8(${info[2]})?;
            % elif info[2]:
                wtr.write_u32(${info[2]})?;
            % endif
            % for fld in rust.get_packet(name).fields:
                trace::field_write("${fld.name}", &${fld.name});
                ${rust.write_struct_field(name, fld.name, fld.type)};
            % endfor
            },

        % endfor
        }
        Ok(())
    }
}

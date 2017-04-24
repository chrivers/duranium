<% import rust %>\
${rust.header()}

use std::io::Result;
use num::ToPrimitive;

use ::packet::enums::frametype;
use ::packet::client::ClientPacket;
use ::stream::FrameWriter;
use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;

pub struct ClientPacketWriter
{
}

impl ClientPacketWriter
{
    pub fn new() -> Self { ClientPacketWriter { } }
}

impl FrameWriter for ClientPacketWriter
{
    type Frame = ClientPacket;
    fn write_frame(&mut self, frame: &Self::Frame) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        match frame
        {
        % for name, info in sorted(rust.generate_packet_ids("ClientParser").items()):
            &${name} {
            % for fld in rust.get_packet(name).fields:
            % if rust.is_ref_type(fld.type):
                ref ${fld.name},
            % else:
                ${fld.name},
            % endif
            % endfor
            } => {
                wtr.write_u32(frametype::${info[1]})?;
            % if info[2]:
                wtr.write_u32(${info[2]})?;
            % endif
            % for fld in rust.get_packet(name).fields:
                ${rust.write_field(name, fld.name, fld.type)};
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
        Ok(wtr.into_inner())
    }
}

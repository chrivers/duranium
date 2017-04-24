<% import rust %>\
${rust.header()}
use std::io::Result;

use ::stream::FrameWriter;
use ::wire::ArtemisEncoder;
use ::wire::traits::IterEnum;
use ::packet::enums::*;
use ::packet::server::ServerPacket;

pub struct ServerPacketWriter
{
}

impl ServerPacketWriter
{
    pub fn new() -> Self { ServerPacketWriter { } }
}

impl FrameWriter for ServerPacketWriter
{
    type Frame = ServerPacket;
    fn write_frame(&mut self, frame: &Self::Frame) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        match frame
        {
        % for name, info in sorted(rust.generate_packet_ids("ServerParser").items()):
            &${name}
            {
            % for fld in rust.get_packet(name).fields:
            % if rust.is_ref_type(fld.type):
                ref ${fld.name},
            % else:
                ${fld.name},
            % endif
            % endfor
            } => {
                wtr.write_u32(frametype::${info[1]})?;
            % if info[2] and info[3] == "u8":
                wtr.write_u8(${info[2]})?;
            % elif info[2]:
                wtr.write_u32(${info[2]})?;
            % endif
            % for fld in rust.get_packet(name).fields:
                ${rust.write_field(name, fld.name, fld.type)};
            % endfor
            % for x in range(rust.sp_get_padding(name)):
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

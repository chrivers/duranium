<% import rust %>\
${rust.header()}

use std::io;
use std::io::Result;
use num::FromPrimitive;
use num::ToPrimitive;

use ::packet::enums::*;
use ::wire::ArtemisEncoder;
use ::wire::ArtemisDecoder;
use ::wire::bitwriter::BitWriter;
use ::wire::bitreader::BitIterator;
use ::stream::FrameReadAttempt;

pub mod reader;
pub mod writer;
pub mod debug;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

#[derive(Debug)]
pub enum ObjectUpdate {
% for object in objects:
    ${object.name}(${object.name}Update),
% endfor
}

% for object in objects:
pub struct ${object.name}Update {
    object_id: u32,
% for field in object.fields:
    % if object.name == "PlayerShipUpgrade":
    pub ${"{:30}".format(field.name+":")} ${rust.declare_update_type(field.type)},
    % else:
    pub ${field.name}: ${rust.declare_update_type(field.type)},
    % endif
% endfor
}

impl ${object.name}Update {
    #[allow(unused_mut)]
    pub fn read(rdr: &mut ArtemisDecoder, mask_byte_size: usize) -> FrameReadAttempt<ObjectUpdate, io::Error>
    {
        const HEADER_SIZE: u32 = 1;
        let a = rdr.position();
        let object_id = try_parse!(rdr.read_u32());
        let mask_bytes = try_parse!(rdr.read_bytes(mask_byte_size));
        let mut mask = BitIterator::new(mask_bytes, 0);
        let parse = ${object.name}Update {
            object_id: object_id,
            % for field in object.fields:
                ${field.name}: {
                    trace!("Reading field ${object.name}::${field.name}");
                    ${rust.read_update_field("rdr", "mask", object, field, field.type)}
                },
            % endfor
        };
        let b = rdr.position();
        FrameReadAttempt::Ok((b - a + HEADER_SIZE as u64) as usize, ObjectUpdate::${object.name}(parse))
    }

    #[allow(unused_mut)]
    pub fn write(&self, object_type: ObjectType, mask_byte_size: usize) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        let mut mask = BitWriter::fixed_size(mask_byte_size, 0);
        % for field in object.fields:
        trace!("Writing field ${object.name}::${field.name}");
        ${rust.write_update_field("wtr", "mask", "self."+field.name, field.type)};
        % endfor
        let mut res = ArtemisEncoder::new();
        res.write_u8(object_type.to_u8().unwrap())?;
        res.write_u32(self.object_id)?;
        res.write_bytes(&mask.into_inner())?;
        res.write_bytes(&wtr.into_inner())?;
        Ok(res.into_inner())
    }
}
% endfor

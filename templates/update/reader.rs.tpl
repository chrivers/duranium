<% import rust %>\
${rust.header()}
use std::io;

use num::FromPrimitive;

use ::wire::ArtemisDecoder;
use ::stream::{FrameReader, FrameReadAttempt};
use ::packet::update::*;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

pub struct ObjectUpdateReader {
}

impl ObjectUpdateReader
{
    pub fn new() -> Self { ObjectUpdateReader { } }
}

impl FrameReader for ObjectUpdateReader
{
    type Frame = ObjectUpdate;
    type Error = io::Error;

    fn read_frame(&mut self, buffer: &[u8]) -> FrameReadAttempt<Self::Frame, Self::Error>
    {
        let mut rdr = ArtemisDecoder::new(buffer);
        let typeid = rdr.read_enum8();
        match try_parse!(typeid) {
            ObjectType::END_MARKER         => return FrameReadAttempt::Closed,
            % for type in enums.get("ObjectType").fields:
<% if type.name == "END_MARKER": continue %>\
            ObjectType::${type.name.ljust(18)} => ${type.name}Update::read(&mut rdr, ${objects.get(type.name)._match}),
            % endfor
            ObjectType::__Unknown(_)       => FrameReadAttempt::Error(make_error("unknown object update type")),
        }
    }
}

% for object in objects:
impl ${object.name}Update {
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
}
% endfor

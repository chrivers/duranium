<% import rust %>\
${rust.header()}
use std::io;

use ::wire::ArtemisDecoder;
use ::stream::{FrameReader, FrameReadAttempt, FramePoll};
use ::packet::update;
use ::packet::update::ObjectUpdate;
use ::packet::enums::ObjectType;
use ::wire::bitreader::BitIterator;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

pub struct ObjectUpdateReader {
}

impl ObjectUpdateReader
{
    pub fn new() -> Self { ObjectUpdateReader { } }
}

pub fn read_frame_stream(buffer: &[u8], rdr: &mut ArtemisDecoder) -> FrameReadAttempt<Vec<ObjectUpdate>, io::Error> {
    let mut updates = vec![];
    let mut uprdr = ObjectUpdateReader::new();
    let mut pos = rdr.position() as usize;
    loop {
        // if pos == buffer.len()-1 {
        //     return FrameReadAttempt::Closed
        // } else if pos >= buffer.len() {
        //     return FrameReadAttempt::Error(make_error("tried to read past end of array"));
        // }
        match uprdr.read_frame(&buffer[pos..])? {
            FramePoll::Closed => break,
            FramePoll::NotReady(bytes) => return Ok(FramePoll::NotReady(bytes)),
            FramePoll::Ready(size, upd) => {
                pos += size;
                updates.push(upd);
            }
        }
    }
    Ok(FramePoll::Ready(pos, updates))
}

impl FrameReader for ObjectUpdateReader
{
    type Frame = ObjectUpdate;
    type Error = io::Error;

    fn read_frame(&mut self, buffer: &[u8]) -> FrameReadAttempt<Self::Frame, Self::Error>
    {
        let mut rdr = ArtemisDecoder::new(buffer);
        let typeid = rdr.read_enum8();
        match typeid? {
            ObjectType::END_MARKER         => return Ok(FramePoll::Closed),
            % for type in enums.get("ObjectType").fields.without("END_MARKER"):
            ObjectType::${type.name.ljust(18)} => update::${type.name}Update::read(&mut rdr, ${objects.get(type.name)._match}),
            % endfor
            ObjectType::__Unknown(_)       => Err(make_error("unknown object update type")),
        }
    }
}

% for object in objects:
impl update::${object.name}Update {
    pub fn read(rdr: &mut ArtemisDecoder, mask_byte_size: usize) -> FrameReadAttempt<ObjectUpdate, io::Error>
    {
        const HEADER_SIZE: u32 = 1;
        let a = rdr.position();
        let object_id = rdr.read_u32()?;
        let mask_bytes = rdr.read_bytes(mask_byte_size)?;
        let mut mask = BitIterator::new(&mask_bytes);
        let parsed = ObjectUpdate::${object.name}(update::${object.name}Update {
            object_id: object_id,
            % for field in object.fields:
                ${field.name}: trace_field_read!("${object.name}", "${field.name}", ${rust.read_update_field("rdr", "mask", object, field, field.type)}),
            % endfor
        });
        let b = rdr.position();
        Ok(FramePoll::Ready((b - a + HEADER_SIZE as u64) as usize, parsed))
    }
}
% endfor

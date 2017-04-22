<% import rust %>\
${rust.header()}
use std::io;

use ::packet::enums::*;
use ::packet::object::*;
use ::wire::ArtemisDecoder;
use ::stream::{FrameReader, FrameReadAttempt};
use ::packet::update::ObjectUpdate;

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

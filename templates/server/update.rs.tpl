use std::io;
use std::io::Result;

use ::packet::enums::*;
use ::packet::server::object::*;
use ::wire::ArtemisDecoder;
use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;
use ::stream::{FrameReader, FrameWriter, FrameReadAttempt};

#[derive(Debug)]
pub enum ObjectUpdate {
% for object in objects:
    ${object.name}(${object.name}Update),
% endfor
}

impl CanEncode for ObjectUpdate {
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        let mut upwtr = ObjectUpdateWriter::new();
        try!(wtr.write_bytes(&try!(upwtr.write_frame(self))));
        Ok(())
    }
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


pub struct ObjectUpdateWriter {
}

impl ObjectUpdateWriter
{
    pub fn new() -> Self { ObjectUpdateWriter { } }
}

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

impl FrameWriter for ObjectUpdateWriter
{
    type Frame = ObjectUpdate;

    fn write_frame(&mut self, frame: &Self::Frame) -> Result<Vec<u8>>
    {
        match frame {
            % for type in enums.get("ObjectType").fields:
<% if type.name == "END_MARKER": continue %>\
            &ObjectUpdate::${("%s(ref data)" % type.name).ljust(28)} => Ok(try!(data.write(ObjectType::${type.name}, ${objects.get(type.name)._match}))),
            % endfor
            &ObjectUpdate::Whale(_)              => Err(make_error("unsupported protocol version")),
        }
    }
}

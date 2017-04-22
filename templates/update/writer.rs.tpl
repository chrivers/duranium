<% import rust %>\
${rust.header()}
use std::io;
use std::io::Result;

use ::packet::enums::*;
use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;
use ::stream::FrameWriter;
use ::packet::update::ObjectUpdate;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

pub struct ObjectUpdateWriter {
}

impl ObjectUpdateWriter
{
    pub fn new() -> Self { ObjectUpdateWriter { } }
}

impl CanEncode for ObjectUpdate {
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        let mut upwtr = ObjectUpdateWriter::new();
        wtr.write_bytes(&upwtr.write_frame(self)?)?;
        Ok(())
    }
}

impl FrameWriter for ObjectUpdateWriter
{
    type Frame = ObjectUpdate;

    fn write_frame(&mut self, frame: &Self::Frame) -> Result<Vec<u8>>
    {
        match frame {
            % for type in enums.get("ObjectType").fields:
<% if type.name == "END_MARKER": continue %>\
            &ObjectUpdate::${("%s(ref data)" % type.name).ljust(28)} => Ok(data.write(ObjectType::${type.name}, ${objects.get(type.name)._match})?),
            % endfor
            &ObjectUpdate::Whale(_)              => Err(make_error("unsupported protocol version")),
        }
    }
}

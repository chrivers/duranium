<% import rust %>\
${rust.header()}
use std::io;
use std::io::Result;

use ::wire::ArtemisEncoder;
use ::wire::ArtemisUpdateEncoder;
use ::wire::CanEncode;
use ::wire::trace;
use ::wire::types::*;

use ::packet::update::{self, Update, ObjectUpdate};
use ::packet::enums::ObjectType;

macro_rules! write_update
{
    ( $name:ident, $wtr:ident, $slf:expr, $data:expr ) => (
        {
            $wtr.write(&Size::<u8, _>::new(ObjectType::$name))?;
            $wtr.write_u32($slf.object_id)?;
            $wtr.write($data)
        }
    )
}

impl CanEncode for ObjectUpdate {
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        match &self.update {
            % for type in enums.get("ObjectType").fields:
            &Update::${type.name}(ref data) => write_update!(${type.name}, wtr, self, data),
            % endfor
            _ => Err(io::Error::new(io::ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

% for object in objects.without("Whale"):
impl CanEncode for update::${object.name} {

    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        let mask_byte_size = ${object._match};
        let mut wtr = ArtemisUpdateEncoder::new(wtr, mask_byte_size)?;
        trace::update_write("${object.name}");
        % for field in object.fields:
        ${rust.write_update_field("self."+field.name, field.type)};
        % endfor
        wtr.finish()
    }
}
% endfor

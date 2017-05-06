<% import rust %>\
${rust.header()}
use std::io;
use std::io::Result;

use ::wire::ArtemisEncoder;
use ::wire::CanEncode;
use ::wire::bitwriter::BitWriter;
use ::wire::trace;

use ::packet::update::{self, Update, ObjectUpdate};
use ::packet::enums::ObjectType;

macro_rules! write_update
{
    ( $name:ident, $wtr:ident, $slf:expr, $data:expr ) => (
        {
            $wtr.write_enum8(ObjectType::$name)?;
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
        let mut mask = BitWriter::fixed_size(mask_byte_size);
        let maskpos = wtr.position();
        wtr.skip_bytes(mask_byte_size as i64)?;
        trace::update_write("${object.name}");
        % for field in object.fields:
        ${rust.write_update_field("wtr", "mask", "self."+field.name, field.type)};
        % endfor
        let endpos = wtr.position();
        wtr.seek_bytes(maskpos)?;
        wtr.write_bytes(&mask.into_inner())?;
        wtr.seek_bytes(endpos)?;
        Ok(())
    }
}
% endfor

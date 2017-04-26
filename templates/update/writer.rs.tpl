<% import rust %>\
${rust.header()}
use std::io;
use std::io::Result;

use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;
use ::wire::bitwriter::BitWriter;
use ::wire::trace;

use ::packet::update::{self, ObjectUpdate};
use ::packet::enums::ObjectType;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

impl CanEncode for ObjectUpdate {
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        match self {
            % for type in enums.get("ObjectType").fields.without("END_MARKER"):
            &ObjectUpdate::${type.name}(ref data) => data.write(wtr),
            % endfor
            _ => Err(make_error("unsupported protocol version")),
        }
    }
}

% for object in objects.without("Whale"):
impl CanEncode for update::${object.name}Update {

    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        let mask_byte_size = ${object._match};
        let mut mask = BitWriter::fixed_size(mask_byte_size);
        wtr.write_enum8(ObjectType::${object.name})?;
        wtr.write_u32(self.object_id)?;
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

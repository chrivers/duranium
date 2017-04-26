<% import rust %>\
${rust.header()}
use std::io;
use std::io::Result;

use ::wire::ArtemisDecoder;
use ::packet::update;
use ::packet::update::ObjectUpdate;
use ::packet::enums::ObjectType;
use ::wire::bitreader::BitIterator;
use ::wire::traits::CanDecode;
use ::wire::trace::trace_field_read;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

impl CanDecode<ObjectUpdate> for ObjectUpdate
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<ObjectUpdate>
    {
        match rdr.read_enum8()? {
            % for type in enums.get("ObjectType").fields.without("END_MARKER"):
            ObjectType::${type.name} => update::${type.name}Update::read(rdr),
            % endfor
            _ => Err(make_error("unknown object update type")),
        }
    }
}

% for object in objects:
impl CanDecode<ObjectUpdate> for update::${object.name}Update  {
    fn read(rdr: &mut ArtemisDecoder) -> Result<ObjectUpdate>
    {
        let mask_byte_size = ${object._match};
        let object_id = rdr.read_u32()?;
        let mask_bytes = rdr.read_bytes(mask_byte_size)?;
        let mut mask = BitIterator::new(&mask_bytes);
        trace_struct_read!("${object.name}");
        let parsed = ObjectUpdate::${object.name}(update::${object.name}Update {
            object_id: object_id,
            % for field in object.fields:
                ${field.name}: trace_field_read!("${object.name}", "${field.name}", ${rust.read_update_field("rdr", "mask", object, field, field.type)}),
            % endfor
        });
        Ok(parsed)
    }
}
% endfor

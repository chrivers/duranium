<% import rust %>\
${rust.header()}
use std::io;
use std::io::Result;

use ::wire::ArtemisDecoder;
use ::packet::update;
use ::packet::update::{Update, ObjectUpdate};
use ::packet::enums::ObjectType;
use ::wire::bitreader::BitIterator;
use ::wire::traits::CanDecode;
use ::wire::trace;

impl CanDecode<ObjectUpdate> for ObjectUpdate
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<ObjectUpdate>
    {
        let object_type = rdr.read_enum8()?;
        let object_id   = rdr.read_u32()?;
        Ok(
            ObjectUpdate {
                object_id: object_id,
                update: match object_type {
                    % for type in enums.get("ObjectType").fields:
                    ObjectType::${type.name} => update::${type.name}::read(rdr)?,
                    % endfor
                    ObjectType::__Unknown(x) => return Err(io::Error::new(io::ErrorKind::InvalidData, format!("unknown object update type [{}]", x))),
                }
            }
        )
    }
}

% for object in objects:
impl CanDecode<Update> for update::${object.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Update>
    {
        let mask_byte_size = ${object._match};
        let mask_bytes = rdr.read_bytes(mask_byte_size)?;
        let mut mask = BitIterator::new(&mask_bytes);
        trace::update_read("${object.name}");
        let parsed = Update::${object.name}(update::${object.name} {
            % for field in object.fields:
                ${field.name}: parse_field!("packet", "${field.name}", ${rust.read_update_field("rdr", "mask", object, field, field.type)}),
            % endfor
        });
        Ok(parsed)
    }
}
% endfor

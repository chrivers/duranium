<% import rust %>\
${rust.header()}
use std::io;
use std::io::Result;

use ::wire::{ArtemisDecoder, ArtemisUpdateDecoder};
use ::packet::update;
use ::packet::update::{Update, ObjectUpdate};
use ::packet::enums::ObjectType;
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
        let mask = rdr.read_slice(mask_byte_size)?;
        trace::update_read("${object.name}");
        let mut rdr = ArtemisUpdateDecoder::new(rdr, mask);
        let parsed = Update::${object.name}(update::${object.name} {
            % for field in object.fields:
                ${field.name}: parse_field!("packet", "${field.name}", ${rust.read_struct_field(field.type)}),
            % endfor
        });
        Ok(parsed)
    }
}
% endfor

<% import rust %>\
${rust.header()}
use std::io::{Result, Error, ErrorKind};

use ::packet::update;
use ::packet::update::{Update, ObjectUpdate};
use ::packet::enums::ObjectType;
use ::wire::{CanDecode, ArtemisDecoder, ArtemisUpdateDecoder};
use ::wire::trace;
use ::wire::types::*;

impl CanDecode for ObjectUpdate
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let object_type: Size<u8, _> = rdr.read()?;
        let object_id   = rdr.read()?;
        Ok(
            ObjectUpdate {
                object_id: object_id,
                update: match *object_type {
                    % for type in enums.get("ObjectType").fields:
                    ObjectType::${type.name.ljust(20)} => Update::${type.name}(rdr.read()?),
                    % endfor
                    ObjectType::__Unknown(x) => return Err(Error::new(ErrorKind::InvalidData, format!("unknown object update type [{}]", x))),
                }
            }
        )
    }
}

% for object in objects:
impl CanDecode for update::${object.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        let mask_byte_size = ${object._match};
        let mask = rdr.read_slice(mask_byte_size)?;
        trace::update_read("${object.name}");
        let mut rdr = ArtemisUpdateDecoder::new(rdr, mask);
        Ok(update::${object.name} {
            % for field in object.fields:
            ${field.name.ljust(15)}: parse_field!("packet", "${field.name}", ${rust.read_update_field(field.type)}),
            % endfor
        })
    }
}
% endfor

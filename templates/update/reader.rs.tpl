<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::update::{Update, ObjectUpdate};
use packet::enums::ObjectTypeV240;

impl CanDecode for ObjectUpdate {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        let object_type: Size<u8, _> = rdr.read()?;
        let object_id   = rdr.read()?;
        Ok(ObjectUpdate {
            object_id: object_id,
            update: match *object_type {
                % for fld in parsers.get("ObjectUpdateV240").fields:
                ObjectTypeV240::${fld.name.ljust(20)} => Update::${fld.name}(rdr.read()?),
                % endfor
                ObjectTypeV240::__Unknown(x) => return Err(Error::new(ErrorKind::InvalidData, format!("unknown object update type [{}]", x))),
            }
        })
    }
}

% for object in objects:
impl CanDecode for update::${object.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::update_read("${object.name}");
        rdr.read_mask(${object._match})?;
        Ok(update::${object.name} {
            % for field in object.fields:
            ${field.name.ljust(20)}: parse_field!("update", "${field.name}", rdr.read()?),
            % endfor
        })
    }
}
% endfor

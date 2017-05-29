<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::update::{Update, UpdateV210, UpdateV240};
use packet::enums::{ObjectTypeV210, ObjectTypeV240};

impl CanDecode for UpdateV210 {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        let object_type: Size<u8, _> = rdr.read()?;
        let object_id   = rdr.read()?;
        Ok(UpdateV210 {
            object_id: object_id,
            update: match *object_type {
                % for fld in parsers.get("ObjectUpdateV210").fields:
                ObjectTypeV210::${fld.name.ljust(20)} => Update::${fld.name}(rdr.read()?),
                % endfor
                ObjectTypeV210::__Unknown(x) => return Err(Error::new(ErrorKind::InvalidData, format!("unknown object update type [{}]", x))),
            }
        })
    }
}

impl CanDecode for UpdateV240 {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        let object_type: Size<u8, _> = rdr.read()?;
        let object_id   = rdr.read()?;
        Ok(UpdateV240 {
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
        rdr.read_mask(${object.arg.name})?;
        Ok(update::${object.name} {
            % for field in object.fields:
            ${field.aligned_name} : parse_field!("update", "${field.name}", rdr.read()?),
            % endfor
        })
    }
}
% endfor

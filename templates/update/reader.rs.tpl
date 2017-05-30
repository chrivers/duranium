<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::update::{Update, UpdateV210, UpdateV240};
use packet::enums::{ObjectTypeV210, ObjectTypeV240};

% for update, parser in [("UpdateV210", _parser.get("ObjectUpdateV210")), ("UpdateV240", _parser.get("ObjectUpdateV240"))]:
<% prefix = parser.field("@type").type.link.name %>\
impl CanDecode for ${update} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        let object_type: Size<u8, _> = rdr.read()?;
        let object_id   = rdr.read()?;
        Ok(${update} {
            object_id: object_id,
            update: match *object_type {
                % for fld in parser.field("@type").type.link.consts:
                ${prefix}::${fld.aligned_name} => Update::${fld.name}(rdr.read()?),
                % endfor
                ${prefix}::__Unknown(x) => return Err(Error::new(ErrorKind::InvalidData, format!("unknown object update type [{}]", x))),
            }
        })
    }
}

% endfor

% for object in _objects:
impl CanDecode for update::${object.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::update_read("${object.name}");
        rdr.read_mask(${object.const("@mask_bytes")})?;
        Ok(update::${object.name} {
            % for field in object.fields:
            ${field.aligned_name} : parse_field!("update", "${field.name}", rdr.read()?),
            % endfor
        })
    }
}
% endfor

<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::update::{Update};
use packet::update::{UpdateV210, UpdateV240};
use packet::enums::{ObjectTypeV210, ObjectTypeV240};

macro_rules! write_update
{
    ( $group:ident, $name:ident, $wtr:ident, $slf:expr, $data:expr ) => (
        {
            $wtr.write(Size::<u8, _>::new($group::$name))?;
            $wtr.write($slf.object_id)?;
            $wtr.write($data)
        }
    )
}

% for update, types in [("UpdateV210", "ObjectTypeV210"), ("UpdateV240", "ObjectTypeV240")]:
impl<'a> CanEncode for &'a ${update} {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        match self.update {
            % for type in _enums.get(types).consts:
            Update::${type.name}(ref data) => write_update!(${types}, ${type.name}, wtr, self, data),
            % endfor
            _ => Err(Error::new(ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

% endfor

% for object in _objects:
impl<'a> CanEncode for &'a update::${object.name} {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        trace::update_write("${object.name}");
        wtr.begin_mask(${object.const("@mask_bytes")})?;
        % for field in object.fields:
        ${rust.write_update_field(field)};
        % endfor
        wtr.end_mask()
    }
}

% endfor

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

impl<'a> CanEncode for &'a UpdateV210 {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        match self.update {
            % for type in enums.get("ObjectTypeV210").consts:
            Update::${type.name}(ref data) => write_update!(ObjectTypeV210, ${type.name}, wtr, self, data),
            % endfor
            _ => Err(Error::new(ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

impl<'a> CanEncode for &'a UpdateV240 {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        match self.update {
            % for type in enums.get("ObjectTypeV240").consts:
            Update::${type.name}(ref data) => write_update!(ObjectTypeV240, ${type.name}, wtr, self, data),
            % endfor
            _ => Err(Error::new(ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

% for object in objects:
impl<'a> CanEncode for &'a update::${object.name} {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        trace::update_write("${object.name}");
        wtr.begin_mask(${object.arg.name})?;
        % for field in object.fields:
        ${rust.write_update_field("self."+field.name, field.type)};
        % endfor
        wtr.end_mask()
    }
}

% endfor

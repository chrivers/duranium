<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::update::{Update, ObjectUpdate};
use packet::enums::ObjectTypeV240;

macro_rules! write_update
{
    ( $name:ident, $wtr:ident, $slf:expr, $data:expr ) => (
        {
            $wtr.write(Size::<u8, _>::new(ObjectTypeV240::$name))?;
            $wtr.write($slf.object_id)?;
            $wtr.write($data)
        }
    )
}

impl<'a> CanEncode for &'a ObjectUpdate {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        match self.update {
            % for type in enums.get("ObjectTypeV240").fields:
            Update::${type.name}(ref data) => write_update!(${type.name}, wtr, self, data),
            % endfor
            _ => Err(Error::new(ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

% for object in objects:
impl<'a> CanEncode for &'a update::${object.name} {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        trace::update_write("${object.name}");
        wtr.begin_mask(${object._match})?;
        % for field in object.fields:
        ${rust.write_update_field("self."+field.name, field.type)};
        % endfor
        wtr.end_mask()
    }
}

% endfor

<% import rust %>\
${rust.header()}
use std::io;
use std::io::Result;
use num::ToPrimitive;

use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;
use ::wire::bitwriter::BitWriter;
use ::packet::update::ObjectUpdate;
use ::packet::update;
use ::packet::enums::*;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

impl CanEncode for ObjectUpdate {
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        let bytes = match self {
            % for type in enums.get("ObjectType").fields.without("END_MARKER"):
            &ObjectUpdate::${("%s(ref data)" % type.name).ljust(28)} => data.write(ObjectType::${type.name}, ${objects.get(type.name)._match}),
            % endfor
            &ObjectUpdate::Whale(_)              => Err(make_error("unsupported protocol version")),
        }?;
        wtr.write_bytes(&bytes)
    }
}

% for object in objects.without("Whale"):
impl update::${object.name}Update {

    pub fn write(&self, object_type: ObjectType, mask_byte_size: usize) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        let mut mask = BitWriter::fixed_size(mask_byte_size);
        % for field in object.fields:
        trace!("Writing field ${object.name}::${field.name}");
        ${rust.write_update_field("wtr", "mask", "self."+field.name, field.type)};
        % endfor
        let mut res = ArtemisEncoder::new();
        res.write_u8(object_type.to_u8().unwrap())?;
        res.write_u32(self.object_id)?;
        res.write_bytes(&mask.into_inner())?;
        res.write_bytes(&wtr.into_inner())?;
        Ok(res.into_inner())
    }
}
% endfor

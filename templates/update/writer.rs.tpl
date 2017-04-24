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
        match self {
            % for type in enums.get("ObjectType").fields.without("END_MARKER"):
            &ObjectUpdate::${("%s(ref data)" % type.name).ljust(28)} => data.write(wtr),
            % endfor
            &ObjectUpdate::Whale(_)              => Err(make_error("unsupported protocol version")),
        }
    }
}

% for object in objects.without("Whale"):
impl update::${object.name}Update {

    pub fn write(&self, res: &mut ArtemisEncoder) -> Result<()>
    {
        let mask_byte_size = ${object._match};
        let mut mask = BitWriter::fixed_size(mask_byte_size);
        res.write_u8(ObjectType::${object.name}.to_u8().unwrap())?;
        res.write_u32(self.object_id)?;
        let maskpos = res.position();
        res.skip_bytes(mask_byte_size as i64)?;
        % for field in object.fields:
        trace!("Writing field ${object.name}::${field.name}");
        ${rust.write_update_field("res", "mask", "self."+field.name, field.type)};
        % endfor
        let endpos = res.position();
        res.seek_bytes(maskpos)?;
        res.write_bytes(&mask.into_inner())?;
        res.seek_bytes(endpos)?;
        Ok(())
    }
}
% endfor

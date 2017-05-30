<% import rust %>\
${rust.header()}

use packet::prelude::*;

% for object in _objects:
impl CanDecode for super::${object.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::struct_read("object::${object.name}");
        Ok(super::${object.name} {
            % for fld in object.fields:
            ${fld.aligned_name} : parse_field!("packet", "${fld.name}", rdr.read()?),
            % endfor
        })
    }
}

% endfor

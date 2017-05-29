<% import rust %>\
${rust.header()}

use packet::prelude::*;

% for object in objects:
<%obj = "object::%s" % object.name %>
impl CanDecode for ${obj} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::struct_read("${obj}");
        Ok(${obj} {
            % for fld in object.fields:
            ${fld.aligned_name} : parse_field!("packet", "${fld.name}", rdr.read()?),
            % endfor
        })
    }
}

% endfor

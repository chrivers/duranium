<% import rust %>\
${rust.header()}
use std::io::Result;

use ::packet::object;
use ::wire::ArtemisDecoder;
use ::wire::traits::CanDecode;
use ::wire::trace;

% for object in objects:
<%obj = "object::%s" % object.name %>
impl CanDecode<${obj}> for ${obj}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<${obj}>
    {
        trace::struct_read("${obj}");
        Ok(${obj} {
            % for fld in object.fields:
            ${fld.name}: parse_field!("packet", "${fld.name}", ${rust.read_struct_field(fld.type)}),
            % endfor
        })
    }
}

% endfor

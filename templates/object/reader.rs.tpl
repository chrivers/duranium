<% import rust %>\
${rust.header()}
use std::io::Result;

use ::packet::object;
use ::wire::ArtemisDecoder;
use ::wire::traits::CanDecode;
use ::wire::trace::trace_field_read;

% for object in objects:
<%obj = "object::%s" % object.name %>
impl CanDecode<${obj}> for ${obj}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<${obj}>
    {
        trace_struct_read!("${obj}");
        Ok(${obj} {
            object_id: trace_field_read!("${obj}", "object_id", rdr.read_u32()?),
            % for fld in object.fields:
            ${fld.name}: trace_field_read!("${obj}", "${fld.name}", ${rust.read_struct_field_parse(fld.type)}),
            % endfor
        })
    }
}

% endfor

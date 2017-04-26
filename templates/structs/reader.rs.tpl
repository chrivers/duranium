<% import rust %>\
${rust.header()}
use std::io;

use ::packet::structs::*;
use ::wire::ArtemisDecoder;
use ::wire::traits::CanDecode;
use ::wire::trace::trace_field_read;

% for struct in structs.without("Update"):

impl CanDecode<${struct.name}> for ${struct.name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<${struct.name}, io::Error>
    {
        trace_struct_read!("${struct.name}");
        Ok(
            ${struct.name} {
                % for field in struct.fields:
                ${field.name}: parse_field!(trace_field_read, "${field.name}", ${rust.read_struct_field_parse(field.type)}),
                % endfor
            }
        )
    }
}
% endfor

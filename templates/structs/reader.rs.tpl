<% import rust %>\
${rust.header()}
use std::io;

use ::packet::structs::*;
use ::wire::ArtemisDecoder;
use ::wire::CanDecode;
use ::wire::trace;

% for struct in structs.without("Update"):

impl CanDecode<${struct.name}> for ${struct.name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<${struct.name}, io::Error>
    {
        trace::struct_read("${struct.name}");
        Ok(
            ${struct.name} {
                % for field in struct.fields:
                ${field.name}: parse_field!("struct", "${field.name}", ${rust.read_struct_field(field.type)}),
                % endfor
            }
        )
    }
}
% endfor

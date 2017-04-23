<% import rust %>\
${rust.header()}
use std::io;

use ::packet::structs::*;
use ::wire::ArtemisDecoder;
use ::wire::traits::CanDecode;

% for struct in structs:
<% if struct.name == "Update": continue %>\

impl CanDecode<${struct.name}> for ${struct.name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<${struct.name}, io::Error>
    {
        Ok(
            ${struct.name} {
                % for field in struct.fields:
                ${field.name}: ${rust.read_struct_field(field.type)},
                % endfor
            }
        )
    }
}
% endfor
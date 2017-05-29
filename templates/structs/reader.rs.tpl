<% import rust %>\
${rust.header()}

use packet::prelude::*;
use super::*;

% for struct in structs.without("ObjectUpdateV210", "ObjectUpdateV240"):
impl CanDecode for ${struct.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::struct_read("${struct.name}");
        Ok(${struct.name} {
            % for field in struct.fields:
            ${field.aligned_name} : parse_field!("struct", "${field.name}", rdr.read()?),
            % endfor
        })
    }
}

% endfor

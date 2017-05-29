<% import rust %>\
${rust.header()}

use packet::prelude::*;
use super::*;

% for struct in structs.without("ObjectUpdateV210", "ObjectUpdateV240"):
impl<'a> CanEncode for &'a ${struct.name} {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        trace::struct_write("${struct.name}");
        % for field in struct.fields:
        write_field!("struct", "${field.name}", &self.${field.name}, ${rust.write_struct_field(field)});
        % endfor
        Ok(())
    }
}

% endfor

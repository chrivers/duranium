<% import rust %>\
${rust.header()}

use packet::prelude::*;
use super::*;

% for struct in structs.without("ObjectUpdateV210", "ObjectUpdateV240"):
impl<'a> CanEncode for &'a ${struct.name} {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        trace::struct_write("${struct.name}");
        % for fld in struct.fields:
        write_field!("struct", "${fld.name}", self.${fld.name}, ${rust.write_struct_field(fld)});
        % endfor
        Ok(())
    }
}

% endfor

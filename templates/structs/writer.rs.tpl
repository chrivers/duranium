<% import rust %>\
${rust.header()}

use packet::prelude::*;
use super::*;

% for struct in _structs.without("ObjectUpdateV210", "ObjectUpdateV240"):
impl<'a> CanEncode for &'a ${struct.name} {
    fn write(self, _wtr: &mut ArtemisEncoder) -> Result<()> {
        trace::struct_write("${struct.name}");
        % for fld in struct.fields:
        ${rust.write_struct_field("struct", fld)};
        % endfor
        Ok(())
    }
}

% endfor

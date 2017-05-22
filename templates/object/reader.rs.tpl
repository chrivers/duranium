<% import rust %>\
${rust.header()}
use std::io::Result;

use wire::types::*;
use wire::trace;

use packet::object;

% for object in objects:
<%obj = "object::%s" % object.name %>
impl CanDecode for ${obj} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::struct_read("${obj}");
        Ok(${obj} {
            % for fld in object.fields:
            ${fld.name}: parse_field!("packet", "${fld.name}", rdr.read()?),
            % endfor
        })
    }
}

% endfor

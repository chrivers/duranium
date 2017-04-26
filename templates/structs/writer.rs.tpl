<% import rust %>\
${rust.header()}
use std::io;

use ::packet::structs::*;
use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;
use ::wire::trace;

% for struct in structs.without("Update"):

impl CanEncode for ${struct.name}
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<(), io::Error>
    {
        trace::struct_write("${struct.name}");
        % for field in struct.fields:
        trace::field_write("${field.name}", &self.${field.name});
        ${rust.write_struct_field("self.%s" % field.name, field.type)};
        % endfor
        Ok(())
    }
}

% endfor

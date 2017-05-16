<% import rust %>\
${rust.header()}

use std::fmt;
use ::packet::update::*;

% for object in objects:
impl fmt::Debug for ${object.name} {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result
    {
        % for field in object.fields:
        % if field.type.name in {"array", "sizedarray", "map"}:
        debug_opt_array!(f, self.${field.name});
        % elif field.type.name == "map":
        write!(f, "${field.name}: {:?},\n", self.${field.name})?;
        % else:
        debug_opt_field!(f, self.${field.name});
        % endif
        % endfor
        Ok(())
    }
}

% endfor

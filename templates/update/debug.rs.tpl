<% import rust %>\
${rust.header()}

use std::fmt;
use ::packet::update::*;

% for object in objects:
impl fmt::Debug for ${object.name}Update {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result
    {
        write!(f, "[{}]\n", self.object_id)?;
        % for field in object.fields:
        % if field.type.name in ("array", "sizedarray"):
        debug_opt_array!(self, f, &self.${field.name});
        % else:
        debug_opt_field!(self, f, &self.${field.name});
        % endif
        % endfor
        Ok(())
    }
}

% endfor
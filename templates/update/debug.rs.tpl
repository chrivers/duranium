<% import rust %>\
${rust.header()}

use std::fmt;
use wire::types::Field;

macro_rules! debug_opt_array {
    ( $fmt:ident, $slf:ident.$field:ident ) => {
        write!($fmt, "{}: {:?},\n", stringify!($field), &$slf.$field)?;
    }
}

macro_rules! debug_opt_field {
    ( $fmt:ident, $slf:ident.$field:ident ) => {
        if let Field::Val(ref value) = $slf.$field {
            write!($fmt, "{}: {:?},\n", stringify!($field), value)?;
        }
    };
}

% for object in objects:
impl fmt::Debug for super::${object.name} {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
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

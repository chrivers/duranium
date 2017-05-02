<% import rust %>\
${rust.header()}

use std::default::Default;

use ::packet::object;

% for object in objects:
impl object::${object.name} {
    pub fn new() -> Self {
        Default::default()
    }
}
% endfor

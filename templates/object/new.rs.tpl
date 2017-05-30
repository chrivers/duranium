<% import rust %>\
${rust.header()}

use std::default::Default;

use packet::object;

% for object in _objects:
impl object::${object.name} {
    pub fn new() -> Self {
        Default::default()
    }
}
% endfor

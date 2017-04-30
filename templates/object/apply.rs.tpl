<% import rust %>\
${rust.header()}

use ::packet::object::Apply;
use ::packet::object;
use ::packet::update;

% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%sUpdate" % object.name
 %>
impl Apply<${U}> for ${T} {
    fn apply(&mut self, update: &${U}) {
        % for field in object.fields:
        ${rust.apply_update_field(field.name, field.type)};
        % endfor
    }
    fn produce(&self, update: &${U}) -> Self {
        ${T} {
        object_id: self.object_id,
        % for field in object.fields:
            ${field.name}: ${rust.produce_update_field(field.name, field.type)},
        % endfor
        }
    }
}
% endfor

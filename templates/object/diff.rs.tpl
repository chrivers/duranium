<% import rust %>\
${rust.header()}

use ::packet::object::Diff;
use ::packet::object;
use ::packet::update;

% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%sUpdate" % object.name
 %>
impl Diff<${T}, ${U}> for ${T} {
    fn diff(&self, other: &${T}) -> ${U} {
        ${U} {
            object_id: 0,
            % for field in object.fields:
            ${field.name}: ${rust.diff_update_field(field.name, field.type)},
            % endfor
        }
    }
}
% endfor

<% import rust %>\
${rust.header()}

use packet::prelude::*;

% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%s" % object.name
 %>
impl<'a, 'b> Diff for &'a ${T} {
    type Other = ${T};
    type Update = ${U};
    fn diff(&self, other: ${T}) -> ${U} {
        ${U} {
            % for field in object.fields:
            ${field.name}: self.${field.name}.diff(other.${field.name}),
            % endfor
        }
    }
}
% endfor

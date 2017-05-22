<% import rust %>\
${rust.header()}

use packet::prelude::*;

% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%s" % object.name
 %>
impl Apply for ${T} {
    type Update = ${U};
    fn apply(&mut self, update: &${U}) {
        % for field in object.fields:
        self.${field.name}.apply(&update.${field.name});
        % endfor
    }
    fn produce(&self, update: &${U}) -> Self {
        Self {
        % for field in object.fields:
            ${field.name}: self.${field.name}.produce(&update.${field.name}),
        % endfor
        }
    }
}
% endfor

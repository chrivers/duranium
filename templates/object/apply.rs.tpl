<% import rust %>\
${rust.header()}

use wire::types::*;

use packet::enums;
use packet::object;
use packet::update;

% for en in enums.without("FrameType") + flags:
apply_impl!(enums::${en.name});
% endfor

% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%s" % object.name
 %>
impl Apply for ${T} where
{
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

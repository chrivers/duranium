<% import rust %>\
${rust.header()}

use ::packet::object::traits::Diff;
use ::packet::object;
use ::packet::update;

macro_rules! diff_field {
    ( $ours:expr, $theirs:expr ) => {
        if $ours != $theirs { Some($theirs) } else { None }
    }
}

% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%s" % object.name
 %>
impl Diff<${T}, ${U}> for ${T} {
    fn diff(&self, other: &${T}) -> ${U} {
        ${U} {
            % for field in object.fields:
            ${field.name}: ${rust.diff_update_field(field.name, field.type)},
            % endfor
        }
    }
}
% endfor

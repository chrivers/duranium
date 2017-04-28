<% import rust %>\
${rust.header()}

use ::packet::enums::*;

pub mod reader;
pub mod writer;
pub mod debug;

#[derive(Debug)]
pub enum ObjectUpdate {
% for object in objects:
    ${object.name}(${object.name}Update),
% endfor
}

% for object in objects:
pub struct ${object.name}Update {
    pub object_id: u32,
% for field in object.fields:
    % if object.name == "PlayerShipUpgrade":
    pub ${"{:30}".format(field.name+":")} ${rust.declare_update_type(field.type)},
    % else:
    pub ${field.name}: ${rust.declare_update_type(field.type)},
    % endif
% endfor
}
% endfor

<% import rust %>\
${rust.header()}

use ::wire::EnumMap;
use ::packet::enums;
use ::packet::object::ObjectID;

pub mod reader;
pub mod writer;
pub mod debug;
use ::wire::types::*;

#[derive(Debug)]
pub struct ObjectUpdate {
    pub object_id: ObjectID,
    pub update: Update,
}

#[derive(Debug)]
pub enum Update {
% for object in objects:
    ${object.name}(${object.name}),
% endfor
}

% for object in objects:
pub struct ${object.name} {
% for field in object.fields:
    % if object.name == "PlayerShipUpgrade":
    pub ${"{:30}".format(field.name+":")} ${rust.declare_update_type(field.type)},
    % else:
    pub ${field.name}: ${rust.declare_update_type(field.type)},
    % endif
% endfor
}

% endfor

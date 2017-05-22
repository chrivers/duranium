<% import rust %>\
${rust.header()}

mod reader;
mod writer;
mod debug;

use packet::prelude::*;

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
    pub ${field.name}: ${rust.declare_update_type(field.type)},
% endfor
}

% endfor

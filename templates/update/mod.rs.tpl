<% import rust %>\
${rust.header()}

mod reader;
mod writer;
mod debug;

use packet::prelude::*;

#[derive(Debug)]
pub struct UpdateV210 {
    pub object_id: ObjectID,
    pub update: Update,
}

#[derive(Debug)]
pub struct UpdateV240 {
    pub object_id: ObjectID,
    pub update: Update,
}

#[derive(Debug)]
pub enum Update {
% for fld in parsers.get("ObjectUpdateV240").fields:
    ${fld.name}(${fld.type[0].link.name}),
% endfor
% for fld in parsers.get("ObjectUpdateV210").fields:
<% if parsers.get("ObjectUpdateV240").fields.get(fld.name, False): continue %>\
    ${fld.name}(${fld.type[0].link.name}),
% endfor
}

% for object in objects:
pub struct ${object.name} {
% for field in object.fields:
    pub ${field.name}: ${rust.declare_update_type(field.type)},
% endfor
}

% endfor

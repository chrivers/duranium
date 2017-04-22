<% import rust %>\
${rust.header()}

use ::packet::object::*;

pub mod reader;
pub mod writer;

#[derive(Debug)]
pub enum ObjectUpdate {
% for object in objects:
    ${object.name}(${object.name}Update),
% endfor
}

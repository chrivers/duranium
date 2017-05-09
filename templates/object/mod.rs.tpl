<% import rust %>\
${rust.header()}

pub mod reader;
pub mod apply;
pub mod diff;
pub mod traits;
pub mod new;

pub type ObjectID = u32;

use ::wire::EnumMap;
use ::packet::enums::*;

% for object in objects:
#[derive(Debug,Default)]
pub struct ${object.name} {
% for field in object.fields:
    % if object.name == "PlayerShipUpgrades":
    ${"{:30}".format(field.name+":")} ${rust.declare_struct_type(field.type)}, // ${"".join(field.comment)}
    % else:
    % if not loop.first:

    % endif
    % for line in util.format_comment(field.comment, indent="// ", width=74):
    ${line}
    % endfor
    pub ${field.name}: ${rust.declare_struct_type(field.type)},
    % endif
% endfor
}

% endfor

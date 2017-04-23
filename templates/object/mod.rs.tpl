<% import rust %>\
${rust.header()}

pub mod reader;

use ::packet::enums::*;

% for object in objects:
#[derive(Debug)]
pub struct ${object.name} {
    object_id: u32,
% for field in object.fields:
    % if object.name == "PlayerShipUpgrades":
    ${"{:30}".format(field.name+":")} ${rust.declare_type(field.type)}, // ${"".join(field.comment)}
    % else:
    % if not loop.first:

    % endif
    % for line in util.format_comment(field.comment, indent="// ", width=74):
    ${line}
    % endfor
    pub ${field.name}: ${rust.declare_type(field.type)},
    % endif
% endfor
}

% endfor

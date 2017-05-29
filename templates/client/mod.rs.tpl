<% import rust %>\
${rust.header()}

mod reader;
mod writer;

use packet::prelude::*;

<% packet = client.get("ClientPacket") %>\
#[derive(Debug)]
#[allow(non_camel_case_types)]
pub enum ${packet.name}
{
% for case in packet:
    ${case.name}(${case.name}),
% endfor
}

% for case in packet:
% if case.name.startswith("__"):
#[allow(non_camel_case_types)]
% endif
#[derive(Debug)]
pub struct ${case.name}
{
    % for field in case.fields:
    % if not loop.first:

    % endif
    % for line in util.format_comment(field.comment, indent="/// ", width=74):
    ${line}
    % endfor
    pub ${field.name}: ${rust.declare_struct_type(field.type)},
    % endfor
}

% endfor

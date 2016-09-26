<% import rust as lang %>\
% for struct in structs:
#[derive(Debug)]
pub struct ${struct.name}
{
    % for field in struct.fields:
    % if loop.index > 0:

    % endif
    % for line in util.format_comment(field.comment, indent="/// ", width=74):
    ${line}
    % endfor
    ${field.name}: ${lang.rust_type(field.type)},
    % endfor
}

% endfor

% for struct in structs:
#[derive(Debug)]
pub enum ${struct.name}
{
    % for index, field in enumerate(struct.fields):
    % if index > 0:

    % endif
    % for line in util.format_comment(field.comment, indent="/// ", width=74):
    ${line}
    % endfor
    ${field.name}: ${lang.rust_type(field.type)},
    % endfor
}

% endfor

% for struct in structs.values():
#[derive(Debug)]
pub enum ${struct.name}
{
    % for index, field in enumerate(struct.fields):
    % if index > 0:

    % endif
    % for line in format_comment(field.comment, indent="/// ", width=73):
    ${line}
    % endfor
    ${field.name}: ${field.type},
    % endfor
}

% endfor

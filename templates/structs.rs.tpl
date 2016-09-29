<% import rust as lang %>\
use std::io;

use ::packet::enums::*;
use ::wire::{ArtemisDecoder};
use ::wire::traits::CanDecode;

% for struct in structs:
<% if struct.name == "Update": continue %>\
#[derive(Debug)]
pub struct ${struct.name}
{
    % for field in struct.fields:
    % if not loop.first:

    % endif
    % for line in util.format_comment(field.comment, indent="/// ", width=74):
    ${line}
    % endfor
    pub ${field.name}: ${lang.rust_type(field.type)},
    % endfor
}

% endfor

% for struct in structs:
<% if struct.name == "Update": continue %>\
impl CanDecode<${struct.name}> for ${struct.name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<${struct.name}, io::Error>
    {
        Ok(
            ${struct.name} {
            % for field in struct.fields:
                ${field.name}: try!(rdr.read_${field.type.name}()),
            % endfor
            }
        )
    }
}

% endfor

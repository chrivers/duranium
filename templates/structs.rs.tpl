<% import rust %>\
${rust.header()}
use std::io;

use ::packet::enums::*;
use ::wire::{ArtemisDecoder, ArtemisEncoder};
use ::wire::traits::{CanDecode, CanEncode};

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
    pub ${field.name}: ${rust.declare_type(field.type)},
    % endfor
}

% endfor
% for struct in structs:
<% if struct.name == "Update": continue %>\

impl CanEncode for ${struct.name}
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<(), io::Error>
    {
        % for field in struct.fields:
        ${rust.write_field(None, "self.%s" % field.name, field.type)};
        % endfor
        Ok(())
    }
}

impl CanDecode<${struct.name}> for ${struct.name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<${struct.name}, io::Error>
    {
        Ok(
            ${struct.name} {
                % for field in struct.fields:
                ${field.name}: ${rust.read_struct_field(field.type)},
                % endfor
            }
        )
    }
}
% endfor
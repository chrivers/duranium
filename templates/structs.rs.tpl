<% import rust %>\
use std::io;

use ::packet::enums::*;
use ::wire::{ArtemisDecoder, ArtemisEncoder};
use ::wire::traits::{CanDecode, CanEncode};

<%def name="read_field(type)">\
try!(rdr.${rust.reader_function(type)}())\
</%def>\
\
<%def name="write_field(name, type)">\
% if type.name == "string":
try!(wtr.${rust.writer_function(type)}(&${name}));\
% else:
try!(wtr.${rust.writer_function(type)}(${name}));\
% endif
</%def>\
\
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
        ${write_field("self.%s" % field.name, field.type)}
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
                ${field.name}: ${read_field(field.type)},
            % endfor
            }
        )
    }
}

% endfor

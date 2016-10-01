<% import rust as lang %>\
use std::io;

use ::packet::enums::*;
use ::wire::{ArtemisDecoder, ArtemisEncoder};
use ::wire::traits::{CanDecode, CanEncode};

<%def name="read_field(type)">\
% if type.name == "enum":
try!(rdr.read_enum${type[0].name[1:]}())\
% else:
try!(rdr.read_${type.name}())\
% endif
</%def>\
\
<%def name="write_field(name, type)">\
% if type.name == "enum":
try!(wtr.write_${type.name}${type[0].name[1:]}(${name}));\
% else:
try!(wtr.write_${type.name}(${name}));\
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
    pub ${field.name}: ${lang.rust_type(field.type)},
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
        % if field.type.name == "string":
        try!(wtr.write_${field.type.name}(&self.${field.name}));
        % else:
        ${write_field("self.%s" % field.name, field.type)}
        % endif
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

<% import rust as lang %>\
#![allow(unused_variables)]
use std::io;
use std::io::Result;
use std::fmt;
use enum_primitive::FromPrimitive;

use ::packet::enums::*;
use ::packet::server::update::ObjectUpdate;
use ::wire::{ArtemisDecoder, ArtemisEncoder};
use ::wire::bitwriter::BitWriter;
use ::wire::bitreader::BitIterator;
use ::stream::FrameReadAttempt;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

% for object in objects:
#[derive(Debug)]
pub struct ${object.name} {
    object_id: u32,
% for field in object.fields:
    % if object.name == "PlayerShipUpgrade":
    ${"{:30}".format(field.name+":")} ${lang.rust_type(field.type)}, // ${"".join(field.comment)}
    % else:
    % if not loop.first:

    % endif
    % for line in util.format_comment(field.comment, indent="// ", width=74):
    ${line}
    % endfor
    pub ${field.name}: ${lang.rust_type(field.type)},
    % endif
% endfor
}
<%def name="read_update_field(rdr, mask, object, field, type)">\
% if type.name == "enum" and type.arg(1).name == "OrdnanceType":
try_update_parse_opt!(${mask}, ${rdr}, OrdnanceType)\
% elif lang.is_primitive(type):
try_update_parse!(${mask}, ${rdr}.read_${type.name}())\
% elif type.name == "bitflags":
try_update_parse!(${mask}, ${rdr}.read_item())\
% elif type.name == "enum":
try_update_parse!(${mask}, ${rdr}.read_enum${type.arg(0).name[1:]}())\
% elif type.name == "sizedarray":
[\
% for x in range(0, int(type.arg(1).name)):
${read_update_field(rdr, mask, object, field, type.arg(0))}, \
% endfor
]\
% else:
  PANIC: ${type}
% endif
</%def>\
##
##
##
<%def name="write_update_field(wtr, mask, fieldname, type)">\
% if type.name == "string":
write_single_field!(${fieldname}.as_ref(), ${wtr}, ${mask}, write_string)\
% elif type.name == "bitflags":
write_single_field!(${fieldname}.map(|v| v.bits()), ${wtr}, ${mask}, write_u32)\
% elif type.name == "sizedarray":
##% for x in range(0, type.arg):
##${write_update_field(wtr, mask, field, type.target)}; \
##% endfor
for _elem in ${fieldname}.iter() { ${write_update_field(wtr, mask, "*_elem", type.arg(0))} }\
% elif lang.is_primitive(type):
write_single_field!(${fieldname}, ${wtr}, ${mask}, write_${type.name})\
% elif type.name == "enum":
write_single_field!(${fieldname}, ${wtr}, ${mask}, write_enum${type.arg(0).name[1:]})\
% else:
  PANIC: ${type}
% endif
</%def>\

pub struct ${object.name}Update {
    object_id: u32,
% for field in object.fields:
    % if object.name == "PlayerShipUpgrade":
    pub ${"{:30}".format(field.name+":")} ${lang.update_type(field.type)},
    % else:
    pub ${field.name}: ${lang.update_type(field.type)},
    % endif
% endfor
}

impl ${object.name} {
    pub fn read(rdr: &mut ArtemisDecoder, header_size: usize) -> FrameReadAttempt<ObjectUpdate, io::Error>
    {
        ## let a = rdr.position();
        ## let parse = ${object.name} {
        ##     % for field in object.fields:
        ##     ${field.name}: {
        ##         trace!("Reading field {}::{}", "${object.name}", "${field.name}");
        ##         ${read_field("rdr", field)}
        ##     },
        ##     % endfor
        ## };
        ## let b = rdr.position();
        ## FrameReadAttempt::Ok((b - a + header_size as u64) as usize, ObjectUpdate::${object.name}(parse))
        FrameReadAttempt::Closed
    }
}


impl ${object.name}Update {
    #[allow(unused_mut)]
    pub fn read(rdr: &mut ArtemisDecoder, header_size: usize, mask_byte_size: usize, skip_fields: usize) -> FrameReadAttempt<ObjectUpdate, io::Error>
    {
        let a = rdr.position();
        let object_id = try_parse!(rdr.read_u32());
        let mask_bytes = try_parse!(rdr.read_bytes(mask_byte_size));
        let mut mask = BitIterator::new(mask_bytes, skip_fields);
        let parse = ${object.name}Update {
            object_id: object_id,
            % for field in object.fields:
                ${field.name}: {
                    trace!("Reading field ${object.name}::${field.name}");
                    ${read_update_field("rdr", "mask", object, field, field.type)}
                },
            % endfor
        };
        let b = rdr.position();
        FrameReadAttempt::Ok((b - a + header_size as u64) as usize, ObjectUpdate::${object.name}(parse))
    }

    #[allow(unused_mut)]
    pub fn write(&self, object_type: ObjectType, header_size: usize, mask_byte_size: usize, skip_fields: usize) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        assert_eq!(header_size, 1);
        let mut mask = BitWriter::fixed_size(mask_byte_size, skip_fields);
        % for field in object.fields:
        trace!("Writing field ${object.name}::${field.name}");
        ${write_update_field("wtr", "mask", "self."+field.name, field.type)};
        % endfor
        let mut res = ArtemisEncoder::new();
        try!(res.write_u8(object_type as u8));
        try!(res.write_u32(self.object_id));
        try!(res.write_bytes(&mask.into_inner()));
        try!(res.write_bytes(&wtr.into_inner()));
        Ok(res.into_inner())
    }
}

impl fmt::Debug for ${object.name}Update {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result
    {
        try!(write!(f, "[{}]\n", self.object_id));
        % for field in object.fields:
        % if field.type.name in ("array", "sizedarray"):
        debug_opt_array!(self, f, &self.${field.name});
        % else:
        debug_opt_field!(self, f, &self.${field.name});
        % endif
        % endfor
        Ok(())
    }
}

% endfor

<% import rust %>\
#![allow(unused_variables)]
use std::io;
use std::io::Result;
use std::fmt;
use num::{ToPrimitive, FromPrimitive};

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

pub struct ${object.name}Update {
    object_id: u32,
% for field in object.fields:
    % if object.name == "PlayerShipUpgrade":
    pub ${"{:30}".format(field.name+":")} ${rust.declare_update_type(field.type)},
    % else:
    pub ${field.name}: ${rust.declare_update_type(field.type)},
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
    pub fn read(rdr: &mut ArtemisDecoder, mask_byte_size: usize) -> FrameReadAttempt<ObjectUpdate, io::Error>
    {
        const HEADER_SIZE: u32 = 1;
        let a = rdr.position();
        let object_id = try_parse!(rdr.read_u32());
        let mask_bytes = try_parse!(rdr.read_bytes(mask_byte_size));
        let mut mask = BitIterator::new(mask_bytes, 0);
        let parse = ${object.name}Update {
            object_id: object_id,
            % for field in object.fields:
                ${field.name}: {
                    trace!("Reading field ${object.name}::${field.name}");
                    ${rust.read_update_field("rdr", "mask", object, field, field.type)}
                },
            % endfor
        };
        let b = rdr.position();
        FrameReadAttempt::Ok((b - a + HEADER_SIZE as u64) as usize, ObjectUpdate::${object.name}(parse))
    }

    #[allow(unused_mut)]
    pub fn write(&self, object_type: ObjectType, mask_byte_size: usize) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        let mut mask = BitWriter::fixed_size(mask_byte_size, 0);
        % for field in object.fields:
        trace!("Writing field ${object.name}::${field.name}");
        ${rust.write_update_field("wtr", "mask", "self."+field.name, field.type)};
        % endfor
        let mut res = ArtemisEncoder::new();
        try!(res.write_u8(object_type.to_u8().unwrap()));
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
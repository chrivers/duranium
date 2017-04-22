<% import rust %>\
${rust.header()}
#![allow(unused_variables)]
use std::io;
use std::io::Result;
use std::fmt;
use num::{ToPrimitive, FromPrimitive};

use ::packet::enums::*;
use ::packet::update::ObjectUpdate;
use ::wire::{ArtemisDecoder, ArtemisEncoder};
use ::wire::bitwriter::BitWriter;
use ::wire::bitreader::BitIterator;
use ::stream::FrameReadAttempt;

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}
% for object in objects:

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

% endfor
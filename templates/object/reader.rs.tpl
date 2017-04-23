<% import rust %>\
${rust.header()}
//#![allow(unused_variables)]
use std::io;

use ::packet::object::*;
use ::packet::update::ObjectUpdate;
use ::wire::ArtemisDecoder;
use ::stream::FrameReadAttempt;

% for object in objects:

impl ${object.name} {
    #[allow(unused_variables)]
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

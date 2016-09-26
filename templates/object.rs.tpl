<% import rust as lang %>\
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
protocol! {
    % for line in util.format_comment(object.comment, indent="// ", width=74):
    ${line}
    % endfor
    object ${object.name}, ${object.name}Update {
    % for index, field in enumerate(object.fields):
        % if object.name == "PlayerShipUpgrade":
        ${"{:30}".format(field.name+":")} ${lang.object_type(field.type)}, // ${"".join(field.comment)}
        % else:
        % if index > 0:

        % endif
        % for line in util.format_comment(field.comment, indent="// ", width=74):
        ${line}
        % endfor
        ${field.name}: ${lang.object_type(field.type)},
        % endif
    % endfor
    }
}

% endfor

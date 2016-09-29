<% import rust as lang %>\
use std::io;

use ::packet::enums::*;
use ::wire::{ArtemisDecoder};

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
impl Ship
{
    pub fn new(
        drive_type: DriveType,
        ship_type: u32,
        accent_color: u32,
        __unknown_1: u32,
        name: String
    ) -> Ship
    {
        Ship {
            drive_type: drive_type,
            ship_type: ship_type,
            __unknown_1: __unknown_1,
            accent_color: accent_color,
            name: name
        }
    }

    pub fn read(rdr: &mut ArtemisDecoder) -> Result<Ship, io::Error>
    {
        Ok(Ship::new(
            try!(rdr.read_enum32()),
            try!(rdr.read_u32()),
            try!(rdr.read_u32()),
            try!(rdr.read_u32()),
            try!(rdr.read_string()),
        ))
    }

}

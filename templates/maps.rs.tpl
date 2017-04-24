<% import rust %>\
${rust.header()}
use std::io;
use std::mem;
use std::collections::HashMap;
use ::packet::enums::*;
use ::wire::traits::{CanDecode, IterEnum};
use ::wire::ArtemisDecoder;
use ::frame::PacketType;

impl CanDecode<HashMap<ConsoleType, ConsoleStatus>> for HashMap<ConsoleType, ConsoleStatus>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<HashMap<ConsoleType, ConsoleStatus>, io::Error>
    {
        let mut map = HashMap::new();
        % for case in enums.get("ConsoleType").fields:
        map.insert(ConsoleType::${"%-15s" % (case.name + ",")} rdr.read_enum8()?);
        % endfor
        Ok(map)
    }
}

fn make_error(desc: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, desc)
}

% for flag in flags:
impl CanDecode<${flag.name}> for ${flag.name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<${flag.name}, io::Error>
    {
        ${flag.name}::from_bits(rdr.read_u32()?).ok_or(make_error("could not parse ${flag.name} bitflags"))
    }
}
% endfor

% for item in [enums.get("ConsoleType")]:
impl IterEnum<${item.name}> for ${item.name} {
    fn iter_enum() -> &'static [${item.name}]
    {
        static TYPES: &'static [${item.name}] =
            &[
            % for field in enums.get(item.name).fields:
                ${item.name}::${field.name},
            % endfor
            ];
        TYPES
    }
}
% endfor

<% types = enums.get("FrameType") %>\
pub fn classify(sig: u32) -> PacketType
{
    match sig {
        // Client messages
        % for x in rust.get_parser("ClientParser").fields:
        ${types.fields.get(x.name).aligned_hex_value} => PacketType::Client, // ${x.name}
        % endfor
        // Server messages
        % for x in rust.get_parser("ServerParser").fields:
        ${types.fields.get(x.name).aligned_hex_value} => PacketType::Server, // ${x.name}
        % endfor
        _ => PacketType::Unknown,
    }
}

pub fn classify_mem(sig: &[u8]) -> PacketType
{
    if sig.len() >= 4 {
        let id = unsafe { mem::transmute::${'<'}&[u8], &[u32]>(&sig)[0] };
        classify(id)
    } else {
        PacketType::Unknown
    }
}

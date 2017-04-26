<% import rust %>\
${rust.header()}
use std::io;
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
    if let Some(id) = ::wire::first_u32(sig) {
        classify(id)
    } else {
        PacketType::Unknown
    }
}

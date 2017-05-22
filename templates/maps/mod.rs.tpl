<% import rust %>\
${rust.header()}

use ::packet::enums::{ConsoleType, ConnectionType};
use ::wire::IterEnum;

% for item in [enums.get("ConsoleType")]:
impl IterEnum<${item.name}> for ${item.name} {
    fn iter_enum() -> &'static [${item.name}] {
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
pub fn classify(sig: u32) -> ConnectionType {
    match sig {
        // Client messages
        % for x in rust.get_parser("ClientParser").fields:
        ${types.fields.get(x.name).aligned_hex_value} => ConnectionType::Client, // ${x.name}
        % endfor
        // Server messages
        % for x in rust.get_parser("ServerParser").fields:
        ${types.fields.get(x.name).aligned_hex_value} => ConnectionType::Server, // ${x.name}
        % endfor
        _ => ConnectionType::__Unknown(0),
    }
}

pub fn classify_mem(sig: &[u8]) -> ConnectionType {
    if let Some(id) = ::wire::first_u32(sig) {
        classify(id)
    } else {
        ConnectionType::__Unknown(0)
    }
}

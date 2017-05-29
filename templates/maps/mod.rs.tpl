<% import rust %>\
${rust.header()}

use packet::enums::ConnectionType;

<% types = parsers.get("FrameType") %>\
pub fn classify(sig: u32) -> ConnectionType {
    match sig {
        // Client messages
        % for x in parsers.get("ClientParser").fields:
        ${types.consts.get(x.name).aligned_hex_value} => ConnectionType::Client, // ${x.name}
        % endfor
        // Server messages
        % for x in parsers.get("ServerParser").fields:
        ${types.consts.get(x.name).aligned_hex_value} => ConnectionType::Server, // ${x.name}
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

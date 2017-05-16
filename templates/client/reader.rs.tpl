<% import rust %>\
${rust.header()}

use std::io;
use std::io::Result;

use ::packet::enums::frametype;
use ::packet::client;
use ::wire::ArtemisDecoder;
use ::wire::CanDecode;
use ::wire::trace;

<% parser = parsers.get("ClientParser") %>
impl CanDecode for client::ClientPacket
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        Ok(match rdr.read::<u32>()? {
            % for field in parser.fields:
            % if field.type.name == "struct":
            frametype::${field.name.ljust(15)} => client::ClientPacket::${field.type[0].name.split("::", 1)[-1]}(rdr.read()?),
            % else:
            frametype::${field.name.ljust(15)} => match rdr.read::<${rust.get_parser(field.type[0].name).arg}>()? {
                % for pkt in rust.get_parser(field.type[0].name).fields:
                ${pkt.name} => client::ClientPacket::${pkt.type[0].name.split("::", 1)[-1]}(rdr.read()?),
                % endfor
                subtype => return Err(io::Error::new(io::ErrorKind::InvalidData, format!("Client frame 0x{:08x} unknown subtype: 0x{:02x}", frametype::${field.name}, subtype)))
            },
            % endif
            % endfor
            supertype => return Err(io::Error::new(io::ErrorKind::InvalidData, format!("Unknown client frame type 0x{:08x}", supertype)))
        })
    }
}

% for lname, info in sorted(rust.generate_packet_ids("ClientParser").items()):
<% name = lname.split("::", 1)[-1] %>\
impl CanDecode for client::${name}
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self>
    {
        trace::packet_read("${name}");
        let res = client::${name} {
            % for fld in rust.get_packet("ClientPacket::%s" % name).fields:
            ${fld.name}: parse_field!("packet", "${fld.name}", ${rust.read_struct_field(fld.type)}),
            % endfor
        };
        % for x in range(rust.get_packet_padding(rust.get_packet(lname), info[1])):
        rdr.read::<u32>()?; // padding
        % endfor
        Ok(res)
    }
}
% endfor

<% import rust %>\
${rust.header()}

pub mod reader;
pub mod writer;

% for enum in enums.without("FrameType"):
%if enum.name in ("AudioMode", "ConsoleType"):
#[derive(Eq,Hash)]
%endif
%if enum.name == "ObjectType":
#[allow(non_camel_case_types)]
%endif
#[derive(PartialEq,Debug,Copy,Clone)]
pub enum ${enum.name}
{
    % for case in enum.fields:
    ${case.name},
    % endfor
    __Unknown(u32),
}

% endfor
pub mod frametype {
    #![allow(non_upper_case_globals)]
    % for case in enums.get("FrameType").fields:
    pub const ${case.aligned_name} : u32 = ${case.aligned_hex_value};
    % endfor
}

% for flag in flags:
bitflags!
{
    pub flags ${flag.name}: u32
    {
        % for field in flag.fields:
        const ${field.aligned_name} = ${field.aligned_hex_value},
        % endfor
    }
}
% endfor

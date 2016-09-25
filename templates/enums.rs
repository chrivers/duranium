#![allow(dead_code)]

use num::ToPrimitive;

macro_rules! enum_to_primitive {
    ($name:ident) => {
        impl ToPrimitive for $name {
            fn to_i64(&self) -> Option<i64> {
                return Some(*self as i64);
            }

            fn to_u64(&self) -> Option<u64> {
                return Some(*self as u64);
            }
        }
    }
}

% for enum in enums:
<% if enum.name == "FrameType": continue %>\
enum_from_primitive! {
    %if enum.name in ("AudioMode", "ConsoleType"):
    #[derive(Debug,Clone,Copy,Eq,PartialEq,Hash)]
    %else:
    #[derive(Debug,Clone,Copy)]
    %endif
    %if enum.name == "ObjectType":
    #[allow(non_camel_case_types)]
    %endif    
    pub enum ${enum.name}
    {
        % for case in enum.fields:
        ${case.aligned_name} = ${case.aligned_hex_value},
        % endfor
    }
}
enum_to_primitive!(${enum.name});

% endfor
pub mod frametype {
    #![allow(non_upper_case_globals)]
    % for enum in enums:
    <% if enum.name != "FrameType": continue %>\
    % for case in enum.fields:
    pub const ${case.aligned_name}: u32 = ${case.aligned_hex_value};
    % endfor
    % endfor
}

% for Flag in flags:
bitflags!
{
    pub flags ${Flag.name}: u32
    {
        % for flag in Flag.fields:
        const ${flag.aligned_name} = ${flag.aligned_hex_value},
        % endfor
    }
}
% endfor

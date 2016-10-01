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

macro_rules! enum_primitive {
    (
        $(#[$mt:meta])*
        pub enum $name:ident {
            $($field:tt)*
        }
    ) =>
    {
        enum_from_primitive! {
            $(#[$mt])*
            #[derive(Debug,Clone,Copy)]
            pub enum $name {
                $($field)*
            }
        }
        enum_to_primitive!($name);
    }
}

% for enum in enums:
<% if enum.name == "FrameType": continue %>\
enum_primitive! {
    %if enum.name in ("AudioMode", "ConsoleType"):
    #[derive(Eq,PartialEq,Hash)]
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

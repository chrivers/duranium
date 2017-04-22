#![allow(dead_code)]

use std::io::Result;
use wire::ArtemisDecoder;
use wire::traits::CanEncode;
use wire::traits::CanDecode;
use num::ToPrimitive;
use num::FromPrimitive;

% for enum in enums:
<% if enum.name == "FrameType": continue %>\
%if enum.name in ("AudioMode", "ConsoleType"):
#[derive(Eq,PartialEq,Hash)]
%endif
%if enum.name == "ObjectType":
#[allow(non_camel_case_types)]
%endif
#[derive(Debug,Copy,Clone)]
pub enum ${enum.name}
{
    % for case in enum.fields:
    ${case.name},
    % endfor
    __Unknown(u32),
}

impl FromPrimitive for ${enum.name} {
    fn from_i64(n: i64) -> Option<${enum.name}> {
        return Self::from_u64((n & 0xFFFFFFFFi64) as u64);
    }

    fn from_u64(n: u64) -> Option<${enum.name}> {
        match n {
            % for case in enum.fields:
            ${case.aligned_hex_value} => Some(${enum.name}::${case.name}),
            % endfor
            val => Some(${enum.name}::__Unknown(val as u32))
        }
    }
}

impl ToPrimitive for ${enum.name} {
    fn to_i64(&self) -> Option<i64> {
        Self::to_u64(self).map(|x| x as i64)
    }

    fn to_u64(&self) -> Option<u64> {
        match self {
            % for case in enum.fields:
            &${enum.name}::${case.name} => Some(${case.aligned_hex_value}),
            % endfor
            &${enum.name}::__Unknown(val) => Some(val as u64)
        }
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

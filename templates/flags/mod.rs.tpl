<% import rust %>\
${rust.header()}

use std::io::{Error, ErrorKind, Result};

use wire::types::*;

% for flag in flags:
bitflags! {
    #[derive(Default)]
    pub struct ${flag.name}: u32 {
        % for field in flag.fields:
        const ${field.aligned_name} = ${field.aligned_hex_value};
        % endfor
    }
}

% endfor

% for flag in flags:
impl CanDecode for ${flag.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        ${flag.name}::from_bits(rdr.read()?).ok_or_else(|| Error::new(ErrorKind::InvalidData, "could not parse ${flag.name} bitflags"))
    }
}

% endfor
% for flag in flags:
impl CanEncode for ${flag.name} {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        wtr.write(self.bits())
    }
}

% endfor

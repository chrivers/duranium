<% import rust %>\
${rust.header()}

use packet::prelude::*;

% for flag in flags:
bitflags! {
    #[derive(Default)]
    pub struct ${flag.name}: ${flag.fields.get("@type").type} {
        % for field in flag.consts:
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

% for flag in flags:
diff_impl!(${flag.name});
apply_impl!(${flag.name});
% endfor

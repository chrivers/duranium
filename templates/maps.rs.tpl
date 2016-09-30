use std::io;
use std::collections::HashMap;
use ::packet::enums::*;
use ::wire::traits::{CanDecode, IterEnum};
use ::wire::ArtemisDecoder;

<% constype = enums.get("ConsoleType") %>\
impl CanDecode<HashMap<ConsoleType, ConsoleStatus>> for HashMap<ConsoleType, ConsoleStatus>
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<HashMap<ConsoleType, ConsoleStatus>, io::Error>
    {
        let mut map = HashMap::new();
        % for case in constype.fields:
        map.insert(ConsoleType::${"%-15s" % (case.name + ",")} try!(rdr.read_enum8()));
        % endfor
        Ok(map)
    }
}

impl IterEnum<ConsoleType> for ConsoleType {
    fn iter_enum() -> &'static [ConsoleType]
    {
        static TYPES: &'static [ConsoleType] =
            &[
            % for field in enums.get("ConsoleType").fields:
                ConsoleType::${field.name},
            % endfor
            ];
        TYPES
    }
}

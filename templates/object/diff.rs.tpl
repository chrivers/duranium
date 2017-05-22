<% import rust %>\
${rust.header()}

use std::iter::FromIterator;
use ::packet::enums;
use ::packet::object;
use ::packet::update;
use ::wire::types::Field;
use ::wire::{Diff, EnumMap, RangeEnum};

impl<E, V> Diff for EnumMap<E, V>
where
    V: Diff<Other=V> + Copy,
    E: RangeEnum,
    Vec<Field<V>>: FromIterator<V::Update>
{
    type Other = EnumMap<E, V>;
    type Update = EnumMap<E, Field<V>>;
    fn diff(&self, other: EnumMap<E, V>) -> Self::Update {
        EnumMap::new(self.data.iter().zip(other.data.into_iter()).map(
            |(s, o)| s.diff(o)).collect()
        )
    }
}

% for en in enums.without("FrameType") + flags:
diff_impl!(enums::${en.name});
% endfor

% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%s" % object.name
 %>
impl<'a, 'b> Diff for &'a ${T} {
    type Other = ${T};
    type Update = ${U};
    fn diff(&self, other: ${T}) -> ${U} {
        ${U} {
            % for field in object.fields:
            ${field.name}: self.${field.name}.diff(other.${field.name}),
            % endfor
        }
    }
}
% endfor

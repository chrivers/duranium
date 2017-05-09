<% import rust %>\
${rust.header()}

use ::packet::enums;
use ::packet::object::traits::Diff;
use ::packet::object;
use ::packet::update;
use ::wire::EnumMap;

macro_rules! diff_impl {
    ( $tp:ty ) => {
        impl Diff<$tp, Option<$tp>> for $tp
        {
            fn diff(&self, other: $tp) -> Option<$tp> {
                if *self == other {
                    None
                } else {
                    Some(other)
                }
            }
        }
    }
}

impl<E, V> Diff<EnumMap<E, V>, EnumMap<E, Option<V>>> for EnumMap<E, V> where
    V: Diff<V, Option<V>> + Copy
{
    fn diff(&self, other: EnumMap<E, V>) -> EnumMap<E, Option<V>> {
        EnumMap::new(self.data.iter().zip(other.data.into_iter()).map(
            |(s, o)| s.diff(o)).collect()
        )
    }
}

diff_impl!(bool);

diff_impl!(i8);
diff_impl!(i16);
diff_impl!(i32);

diff_impl!(u8);
diff_impl!(u16);
diff_impl!(u32);
diff_impl!(u64);
diff_impl!(f32);

diff_impl!(String);

% for en in enums.without("FrameType") + flags:
diff_impl!(enums::${en.name});
% endfor

% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%s" % object.name
 %>
impl<'a, 'b> Diff<${T}, ${U}> for &'a ${T} where
{
    fn diff(&self, other: ${T}) -> ${U} {
        ${U} {
            % for field in object.fields:
            ${field.name}: self.${field.name}.diff(other.${field.name}),
            % endfor
        }
    }
}
% endfor

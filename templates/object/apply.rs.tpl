<% import rust %>\
${rust.header()}

use ::packet::enums;
use ::packet::object;
use ::packet::update;
use ::wire::types::Field;
use ::wire::{Apply, EnumMap, RangeEnum};

impl<E, V> Apply for EnumMap<E, V> where
    V: Apply<Update=Field<V>>,
    E: RangeEnum,
{
    type Update = EnumMap<E, Field<V>>;

    fn apply(&mut self, update: &EnumMap<E, Field<V>>) {
        self.data.iter_mut().zip(update.data.iter()).map(
            |(s, o)| s.apply(o)
        ).last();
    }
    fn produce(&self, update: &EnumMap<E, Field<V>>) -> Self {
        EnumMap::new(self.data.iter().zip(update.data.iter()).map(
            |(s, o)| s.produce(o)).collect()
        )
    }
}

% for en in enums.without("FrameType") + flags:
apply_impl!(enums::${en.name});
% endfor
% for object in objects:
<%
 T = "object::%s" % object.name
 U = "update::%s" % object.name
 %>
impl Apply for ${T} where
{
    type Update = ${U};
    fn apply(&mut self, update: &${U}) {
        % for field in object.fields:
        self.${field.name}.apply(&update.${field.name});
        % endfor
    }
    fn produce(&self, update: &${U}) -> Self {
        Self {
        % for field in object.fields:
            ${field.name}: self.${field.name}.produce(&update.${field.name}),
        % endfor
        }
    }
}
% endfor

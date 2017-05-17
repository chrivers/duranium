<% import rust %>\
${rust.header()}

use ::packet::object::traits::Apply;
use ::packet::enums;
use ::packet::object;
use ::packet::update;
use ::wire::{EnumMap, RangeEnum};

macro_rules! apply_impl {
    ($tp:ty) => {
        impl Apply for $tp
        {
            type Update = Option<$tp>;
            fn apply(&mut self, update: &Option<$tp>) {
                if let Some(x) = *update {
                    *self = x
                }
            }
            fn produce(&self, update: &Option<$tp>) -> Self {
                update.unwrap_or(*self)
            }
        }
    }
}

impl Apply for String {
    type Update = Option<String>;
    fn apply(&mut self, update: &Option<String>) {
        if let &Some(ref x) = update {
            *self = x.to_string()
        }
    }
    fn produce(&self, update: &Option<String>) -> Self {
        match update {
            &Some(ref s) => s.clone(),
            &None => self.clone()
        }
    }
}

impl<E, V> Apply for EnumMap<E, V> where
    V: Apply<Update=Option<V>>,
    E: RangeEnum,
{
    type Update = EnumMap<E, Option<V>>;

    fn apply(&mut self, update: &EnumMap<E, Option<V>>) {
        self.data.iter_mut().zip(update.data.iter()).map(
            |(s, o)| s.apply(o)
        ).last();
    }
    fn produce(&self, update: &EnumMap<E, Option<V>>) -> Self {
        EnumMap::new(self.data.iter().zip(update.data.iter()).map(
            |(s, o)| s.produce(o)).collect()
        )
    }
}

apply_impl!(bool);

apply_impl!(i8);
apply_impl!(i16);
apply_impl!(i32);

apply_impl!(u8);
apply_impl!(u16);
apply_impl!(u32);
apply_impl!(u64);
apply_impl!(f32);

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

<% import rust %>\
${rust.header()}

pub trait Apply<U> {
    fn apply(&mut self, update: U);
    fn produce(&self, update: U) -> Self;
}

pub trait Diff<T, U>
{
    fn diff(&self, other: T) -> U;
}

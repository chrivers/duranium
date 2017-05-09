<% import rust %>\
${rust.header()}

pub trait Apply<U> {
    fn apply(&mut self, update: U);
    fn produce(&self, update: U) -> Self;
}

pub trait Diff
{
    type Other;
    type Update = Option<Self::Other>;
    fn diff(&self, other: Self::Other) -> Self::Update;
}

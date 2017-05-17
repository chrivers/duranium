<% import rust %>\
${rust.header()}
use ::wire::types::Field;

pub trait Apply {
    type Update;
    fn apply(&mut self, update: &Self::Update);
    fn produce(&self, update: &Self::Update) -> Self;
}

pub trait Diff {
    type Other;
    type Update = Field<Self::Other>;
    fn diff(&self, other: Self::Other) -> Self::Update;
}

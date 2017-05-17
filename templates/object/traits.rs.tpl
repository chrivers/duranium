<% import rust %>\
${rust.header()}

pub trait Apply {
    type Update;
    fn apply(&mut self, update: &Self::Update);
    fn produce(&self, update: &Self::Update) -> Self;
}

pub trait Diff {
    type Other;
    type Update = Option<Self::Other>;
    fn diff(&self, other: Self::Other) -> Self::Update;
}

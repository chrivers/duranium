<% import rust %>\
${rust.header()}
pub mod maps;
pub mod enums;
pub mod client;
pub mod server;
pub mod structs;
pub mod object;
pub mod update;
pub mod flags;

mod prelude {
    pub use std::io::{Result, Error, ErrorKind};

    pub use wire::trace;
    pub use wire::types::*;

    pub use super::structs;
    pub use super::enums;
    pub use super::flags;
    pub use super::client;
    pub use super::server;
    pub use super::object;
    pub use super::update;
}

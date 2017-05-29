<% import rust %>\
${rust.header()}

use packet::prelude::*;

impl ArrayMarker for structs::SystemNodeStatus {
    type Item = u8;
    const MARKER: u8 = 0xff;
}

impl ArrayMarker for structs::DamconTeamStatus {
    type Item = u8;
    const MARKER: u8 = 0xfe;
}

impl ArrayMarker for structs::Statistic {
    type Item = u8;
    const MARKER: u8 = 0xce;
}

impl ArrayMarker for structs::FighterBay {
    type Item = u32;
    const MARKER: u32 = 0x00000000;
}

impl ArrayMarker for structs::UpdateV210 {
    type Item = u32;
    const MARKER: u32 = 0x00000000;
}

impl ArrayMarker for structs::UpdateV240 {
    type Item = u32;
    const MARKER: u32 = 0x00000000;
}

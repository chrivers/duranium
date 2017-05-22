use packet::prelude::*;

use super::ConsoleType;

impl Repr<u32> for Option<Size<u32, ConsoleType>> where
    Self: Copy
{
    fn decode(x: u32) -> Self {
        match x {
            0 => None,
            n => Some(Size::new(ConsoleType::from(n - 1))
            )
        }
    }

    fn encode(self) -> u32 {
        self.map_or(0, |ct| u32::from(ct) + 1)
    }
}

impl<T> CanDecode for Option<Size<u32, T>> where
    Option<Size<u32, T>>: Repr<u32>,
{
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        Ok(Repr::decode(rdr.read::<u32>()?))
    }
}

impl CanEncode for Option<Size<u32, ConsoleType>> {
    fn write(self, wtr: &mut ArtemisEncoder) -> Result<()> {
        wtr.write::<u32>(self.encode())
    }
}

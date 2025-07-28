use rand::prelude::*;

fn main() {
    let char = rand::rng().random::<char>();
    println!("Hello, world! {char} 11");
}

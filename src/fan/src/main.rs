extern crate arguments;
extern crate flate2;

use flate2::read::GzDecoder;

use std::env;
use std::fs::{File, OpenOptions};
use std::io::{BufRead, BufReader, Write};
use std::path::Path;

const DELIMITER: &'static str = ",";
const NAME_INDEX: usize = 2;
const SELECTION: &'static [usize] = &[0, 1, 2, 3, 4, 5];

macro_rules! ok(($result:expr) => ($result.unwrap()));

fn main() {
    let arguments = ok!(arguments::parse(env::args()));
    let input = ok!(arguments.get::<String>("input"));
    let output = ok!(arguments.get::<String>("output"));
    let output = Path::new(&output);
    let mut input = ok!(File::open(input));
    let mut decoder = ok!(GzDecoder::new(&mut input));
    let reader = BufReader::new(&mut decoder);
    for line in reader.lines() {
        let line = ok!(line);
        let chunks = line.split(DELIMITER).collect::<Vec<_>>();
        let output = output.join(chunks[NAME_INDEX]).with_extension("csv");
        let mut output = ok!(OpenOptions::new().append(true).create(true).open(output));
        for (i, &j) in SELECTION.iter().enumerate() {
            if i > 0 {
                ok!(output.write_all(DELIMITER.as_bytes()));
            }
            ok!(output.write_all(chunks[j].as_bytes()));
        }
        ok!(output.write_all("\n".as_bytes()));
    }
}

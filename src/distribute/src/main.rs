extern crate arguments;
extern crate flate2;
extern crate md5;

use flate2::read::GzDecoder;

use std::env;
use std::fs::{self, File, OpenOptions};
use std::io::{BufRead, BufReader, Write};
use std::path::Path;

macro_rules! ok(($result:expr) => ($result.unwrap()));

fn main() {
    let arguments = ok!(arguments::parse(env::args()));
    let input = ok!(arguments.get::<String>("input"));
    let split = arguments.get::<String>("split").unwrap_or(",".to_string());
    let group = ok!(arguments.get::<usize>("group"));
    let select = ok!(arguments.get::<String>("select")).split(&split)
                                                       .map(|i| ok!(i.parse::<usize>()))
                                                       .collect::<Vec<_>>();
    let output = ok!(arguments.get::<String>("output"));
    let output = Path::new(&output);
    let mut input = ok!(File::open(input));
    let mut decoder = ok!(GzDecoder::new(&mut input));
    let reader = BufReader::new(&mut decoder);
    for line in reader.lines() {
        let line = ok!(line);
        let chunks = line.split(&split).collect::<Vec<_>>();
        let digest = format!("{:x}", md5::compute(chunks[group].as_bytes()));
        let directory = output.join(&digest[..2]);
        ok!(fs::create_dir_all(&directory));
        let output = directory.join(chunks[group]).with_extension("csv");
        let mut output = ok!(OpenOptions::new().append(true).create(true).open(output));
        for (i, &j) in select.iter().enumerate() {
            if i > 0 {
                ok!(output.write_all(split.as_bytes()));
            }
            ok!(output.write_all(chunks[j].as_bytes()));
        }
        ok!(output.write_all("\n".as_bytes()));
    }
}

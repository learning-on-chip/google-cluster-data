extern crate arguments;
extern crate flate2;
extern crate md5;

use flate2::read::GzDecoder;

use std::env;
use std::fs::{self, File, OpenOptions};
use std::io::{BufRead, BufReader, Write};
use std::path::Path;

const DEFAULT_DELIMITER: &'static str = ",";
const DEFAULT_DEPTH: usize = 4;

macro_rules! ok(($result:expr) => ($result.unwrap()));

fn main() {
    let arguments = ok!(arguments::parse(env::args()));
    let input = ok!(arguments.get::<String>("input"));
    let delimiter = arguments.get::<String>("delimiter").unwrap_or(DEFAULT_DELIMITER.to_string());
    let group = ok!(arguments.get::<String>("group")).split(&delimiter)
                                                     .map(|i| ok!(i.parse::<usize>()))
                                                     .collect::<Vec<_>>();
    let select = ok!(arguments.get::<String>("select")).split(&delimiter)
                                                       .map(|i| ok!(i.parse::<usize>()))
                                                       .collect::<Vec<_>>();
    let depth = arguments.get::<usize>("depth").unwrap_or(DEFAULT_DEPTH);
    let output = ok!(arguments.get::<String>("output"));
    let output = Path::new(&output);
    let mut input = ok!(File::open(input));
    let mut decoder = ok!(GzDecoder::new(&mut input));
    let reader = BufReader::new(&mut decoder);
    for line in reader.lines() {
        let line = ok!(line);
        let chunks = line.split(&delimiter).collect::<Vec<_>>();
        let mut name = String::new();
        for (i, &j) in group.iter().enumerate() {
            if i > 0 {
                name.push_str(&delimiter);
            }
            name.push_str(&chunks[j]);
        }
        let digest = format!("{:x}", md5::compute(name.as_bytes()));
        let directory = output.join(&digest[..depth]);
        ok!(fs::create_dir_all(&directory));
        let output = directory.join(name).with_extension("csv");
        let mut output = ok!(OpenOptions::new().append(true).create(true).open(output));
        for (i, &j) in select.iter().enumerate() {
            if i > 0 {
                ok!(output.write_all(delimiter.as_bytes()));
            }
            ok!(output.write_all(chunks[j].as_bytes()));
        }
        ok!(output.write_all("\n".as_bytes()));
    }
}

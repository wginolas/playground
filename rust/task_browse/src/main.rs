extern crate clap;
extern crate rustc_serialize;

use std::process::Command;
use rustc_serialize::json;
use clap::{Arg, App, AppSettings};

struct Args {
    filter: Vec<String>
}

fn parse_args() -> Args {
    let matches = App::new("task_browse")
        .version("0.0.1")
        .author("Wolfgang Ginolas <wolfgang.ginolas@gwif.eu>")
        .about("Open links in a task in a browser")
        .setting(AppSettings::ColoredHelp)
        .arg(Arg::with_name("FILTER")
             .help("Filter query which specifies the tasks to open")
             .takes_value(true)
            .multiple(true))
        .get_matches();

    Args {
        filter: match matches.values_of("FILTER") {
            Some(x) => x.map(|s| s.to_string()).collect(),
            None => vec![]
        }
    }
}

#[derive(RustcDecodable, Debug)]
struct Task {
    id: i32,
    description: String,
    uuid: String,
    annotations: Option<Vec<Annotation>>
}

#[derive(RustcDecodable, Debug)]
struct Annotation {
    description: String,
}

fn load_tasks(filter: &[String]) -> Vec<Task> {
    let output = Command::new("task")
        .args(filter)
        .arg("export")
        .output()
        .unwrap();

    let result: Vec<Task> = json::decode(&String::from_utf8_lossy(&output.stdout)).unwrap();
    return result;
}

fn descriptions<'a>(t: &'a Task) -> Vec<&'a String> {
    let mut result: Vec<&'a String> = Vec::new();

    result.push(&t.description);
    if let Some(ref ans) = t.annotations {
        for a in ans {
            result.push(&a.description);
        }
    }

    result
}

fn main() {
    let args = parse_args();

    let tasks = load_tasks(&args.filter);
    for task in tasks {
        println!("{:?}", task);
    }
}

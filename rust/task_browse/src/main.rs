extern crate clap;
extern crate rustc_serialize;
extern crate regex;
#[macro_use]
extern crate lazy_static;

use std::process::Command;
use rustc_serialize::json;
use clap::{Arg, App, AppSettings};
use regex::Regex;

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

fn find_just_tickets(s: &String) -> Vec<String> {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"JUST-\d+").unwrap();
    }

    RE.captures_iter(s)
        .map(|c| format!("https://jira.just.social/{}", c.at(0).unwrap()))
        .collect()
}

fn main() {
    let args = parse_args();

    let tasks = load_tasks(&args.filter);
    for task in tasks {
        println!("{:?}", descriptions(&task));
    }
}

#[test]
fn descriptions_extracts_description() {
    assert_eq!(
        vec![&"desc".to_string()],
        descriptions(&Task {
            id: 1,
            description: "desc".to_string(),
            uuid: "asdf".to_string(),
            annotations: None}));
}

#[test]
fn descriptions_extracts_annotations() {
    assert_eq!(
        vec![&"d".to_string(), &"a1".to_string(), &"a2".to_string()],
        descriptions(&Task {
            id: 1,
            description: "d".to_string(),
            uuid: "asdf".to_string(),
            annotations: Some(vec![
                Annotation {description: "a1".to_string()},
                Annotation {description: "a2".to_string()}])}));
}

#[test]
fn find_just_tickets_finds_no_ticket() {
    assert_eq!(
        Vec::<String>::new(),
        find_just_tickets(&"Hallo Welt!".to_string())
    );
}

#[test]
fn find_just_tickets_finds_tickets() {
    assert_eq!(
        vec![
            "https://jira.just.social/JUST-1".to_string(),
            "https://jira.just.social/JUST-1234".to_string()],
        find_just_tickets(&"Hallo JUST-1 Welt! JUST-1234".to_string())
    );
}

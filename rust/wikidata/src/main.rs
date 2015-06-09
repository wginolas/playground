extern crate rustc_serialize;

use std::io;
use std::thread;
use std::sync::mpsc::sync_channel;
use std::sync::mpsc::Receiver;
use rustc_serialize::json::Parser;

fn clean_line(s: &str) -> Option<String> {
    if s.len() < 5 {
        return None
    }

    return Some(s.replace(",\n", ""));
}

fn parse_thread(rx : Receiver<String>) {
    loop {
        let r = rx.recv();
        if r.is_err() {
            break
        }
        let s = r.unwrap();
        let mut p = Parser::new(s.chars());
        loop {
            let e = p.next();
            if e.is_none() {
                break;
            }
            let e = e.unwrap();

            println!("{:?} {:?}", p.stack().top(), e);
        }
    }
}

fn main() {
    let (tx, rx) = sync_channel(100);
    let pt = thread::spawn(move || parse_thread(rx));

    let mut line = String::new();
    loop {
        line.clear();
        let read = io::stdin().read_line(&mut line).unwrap();
        if read == 0 {
            break;
        }
        match clean_line(&line) {
            Some(l) => {tx.send(l).unwrap(); ()},
            None => ()
        }
    }
    drop(tx);
    pt.join().unwrap();
}

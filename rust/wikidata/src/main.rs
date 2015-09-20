extern crate rustc_serialize;
extern crate rusqlite;

use std::io;
use std::thread;
use std::sync::mpsc::sync_channel;
use std::sync::mpsc::Receiver;
use std::sync::mpsc::SyncSender;
use std::path::Path;
use std::str::FromStr;
use rustc_serialize::json::Json;

use rusqlite::SqliteConnection;

#[derive(Debug)]
struct WikidataItem {
    id: i64,
    alias_en: String,
}

fn clean_line(s: &str) -> Option<String> {
    if s.len() < 5 {
        return None
    }
    return Some(s.replace(",\n", ""));
}

fn parse_json(j: Json) -> Option<WikidataItem> {
    if j.find("type").unwrap().as_string().unwrap() != "item" {
        return None;
    }
    let alias = j.find_path(&["labels", "en", "value"]);
    return Some(WikidataItem {
        id: i64::from_str(&j.find("id").unwrap().as_string().unwrap()[1..]).unwrap(),
        alias_en: match alias {
            Some(a) => a.as_string().unwrap().to_string(),
            None => "unknown".to_string()
        }
    });
}

fn parse_thread(_thread_num : usize, line_rx : Receiver<String>, item_tx: SyncSender<WikidataItem>) {
    loop {
        let r = line_rx.recv();
        if r.is_err() {
            break
        }
        //println!("{} working", thread_num);
        let s = r.unwrap();
        let j = Json::from_str(&*s).unwrap();
        let item = parse_json(j);
        match item {
            None => (),
            Some(i) => {
                item_tx.send(i).unwrap();
            }
        }
    }
}

fn dump_thread(rx : Receiver<WikidataItem>) {
    let conn = SqliteConnection::open(&Path::new("wikidata.sqlite")).unwrap();

    conn.execute("create table item (
                  id        integer primary key,
                  alias_en  text not null)", &[]).unwrap();

    let mut insert = conn.prepare("insert into item(id, alias_en) values($1, $2)").unwrap();

    let tx = conn.transaction().unwrap();

    let mut count: i32 = 0;
    loop {
        let r = rx.recv();
        if r.is_err() {
            break
        }
        let i = r.unwrap();
        insert.execute(&[&i.id, &i.alias_en]).unwrap();
        count += 1;
        if count % 100 == 0 {
            println!("{} documents written", count);
        }
    }
    println!("{} documents written", count);

    tx.commit().unwrap();
}

fn main() {
    let worker_cnt = 1;

    let (item_tx, item_rx) = sync_channel(100);
    let dt = thread::spawn(move || dump_thread(item_rx));

    let mut line_tx_vec = Vec::new();
    for i in 0..worker_cnt {
        let (line_tx, line_rx) = sync_channel(100);
        let item_tx_clone = item_tx.clone();
        thread::spawn(move || parse_thread(i, line_rx, item_tx_clone));
        line_tx_vec.push(line_tx);
    }

    drop(item_tx);

    let mut tx_i = 0;
    let mut line = String::new();
    loop {
        line.clear();
        let read = io::stdin().read_line(&mut line).unwrap();
        if read == 0 {
            break;
        }
        match clean_line(&line) {
            Some(l) => {
                line_tx_vec[tx_i].send(l).unwrap();
                tx_i += 1;
                if tx_i >= worker_cnt {
                    tx_i = 0;
                }
                ()
            },
            None => ()
        }
    }
    drop(line_tx_vec);
    dt.join().unwrap();
}

extern crate serial;

use std::io;
use std::io::{BufReader, BufRead, Write};
use std::process::Command;
use std::process::Stdio;

use serial::prelude::*;
use serial::SerialDevice;

fn open_sar_stream() -> io::Result<Box<BufRead>> {
    let child = Command::new("sar").arg("-r")
        .arg("-u")
        .arg("1")
        .stdout(Stdio::piped())
        .spawn()?;

    Ok(Box::new(BufReader::new(child.stdout.unwrap())))
}

fn parse_and_scale(s: &str, old_min: f64, old_max: f64, new_min: f64, new_max: f64) -> u8 {
    let mut f = s.replace(",", ".").parse::<f64>().unwrap_or(0.0);
    f = (f - old_min) * (new_max - new_min) / (old_max - old_min) + new_min;
    f = f.min(new_max).max(new_min);

    f as u8
}

fn send_info(port: &mut serial::SystemPort, idle_str: &str, mem_used_str: &str) -> serial::Result<()> {
    let cpu_used = parse_and_scale(idle_str, 100.0, 0.0, 0.0, 235.0);
    let mem_used = parse_and_scale(mem_used_str, 0.0, 100.0, 0.0, 235.0);
    println!("idle_str: {}  mem_used_str: {}  cpu used: {}  mem used: {}",
             idle_str,
             mem_used_str,
             cpu_used,
             mem_used);

    port.write_all(&[33, mem_used, cpu_used])?;
    port.flush()?;

    Ok(())
}

fn open_serial_port() -> serial::Result<serial::SystemPort> {
    let mut port = serial::open("/dev/ttyUSB0")?;
    let mut settings = port.read_settings()?;
    settings.set_baud_rate(serial::Baud9600)?;
    settings.set_parity(serial::ParityNone);
    settings.set_stop_bits(serial::Stop1);
    port.write_settings(&settings)?;

    Ok(port)
}

fn main() {
    let input = open_sar_stream().unwrap();
    let mut port = open_serial_port().unwrap();
    let mut idle = String::new();
    let mut mem_used = String::new();

    let mut last_line = String::new();
    for line in input.lines().map(|l| l.unwrap()) {

        if !line.is_empty() && !last_line.is_empty() {
            for (k, v) in last_line.split_whitespace().zip(line.split_whitespace()) {
                if k == "%idle" {
                    idle = v.to_string();
                }
                if k == "%commit" {
                    mem_used = v.to_string();
                }
            }
            send_info(&mut port, &idle, &mem_used).unwrap();
        }

        last_line = line;
    }
}

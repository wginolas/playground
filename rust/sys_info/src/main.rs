extern crate num_cpus;

use std::io;
use std::io::{Read, BufReader, BufRead};
use std::fs::File;
use std::str::FromStr;
use std::num::ParseFloatError;
use std::thread::sleep;
use std::time::Duration;
use std::process::Command;
use std::process::Stdio;

#[derive(Debug)]
enum SysInfoError {
    Io(io::Error),
    ParseFloat(ParseFloatError),
    Format(String),
}

impl From<io::Error> for SysInfoError {
    fn from(e: io::Error) -> SysInfoError {
        SysInfoError::Io(e)
    }
}

impl From<ParseFloatError> for SysInfoError {
    fn from(e: ParseFloatError) -> SysInfoError {
        SysInfoError::ParseFloat(e)
    }
}

#[derive(Debug)]
struct Uptime {
    uptime: f64,
    idle: f64,
}

struct CpuMeasureState {
    cpus: usize,
    last_uptime: Uptime,
}

fn uptime() -> Result<Uptime, SysInfoError> {
    let mut f = File::open("/proc/uptime")?;
    let mut content = String::new();
    f.read_to_string(&mut content)?;
    let mut iter = content.split_whitespace();
    let uptime_str = iter.next().ok_or(SysInfoError::Format("Missing uptime".to_string()))?;
    let idle_str = iter.next().ok_or(SysInfoError::Format("Missing idle time".to_string()))?;

    Ok(Uptime {
        uptime: f64::from_str(uptime_str)?,
        idle: f64::from_str(idle_str)?,
    })
}

fn init_cpu_measurement() -> Result<CpuMeasureState, SysInfoError> {
    Ok(CpuMeasureState {
        cpus: num_cpus::get(),
        last_uptime: uptime()?,
    })
}

fn cpu_usage(s: &mut CpuMeasureState) -> Result<f64, SysInfoError> {
    let next_uptime = uptime()?;

    let du = next_uptime.uptime - s.last_uptime.uptime;
    if du < 0.001 {
        return Ok(0.0);
    }

    let cpus = s.cpus as f64;
    let di = (next_uptime.idle - s.last_uptime.idle);
    println!("{} {} {:?} {:?}", di, du, s.last_uptime, next_uptime);

    s.last_uptime = next_uptime;

    return Ok(di / du);
}

fn main2() {
    let mut cm = init_cpu_measurement().unwrap();
    let delay = Duration::from_millis(10000);
    loop {
        sleep(delay);
        let usage = cpu_usage(&mut cm).unwrap();

        println!("{}", usage);
    }
}

fn open_sar_stream() -> io::Result<Box<BufRead>> {
    let child = Command::new("sar").arg("-r")
        .arg("-u")
        .arg("1")
        .stdout(Stdio::piped())
        .spawn()?;

    Ok(Box::new(BufReader::new(child.stdout.unwrap())))
}

fn main() {
    let input = open_sar_stream().unwrap();

    let mut last_line = String::new();
    for line in input.lines().map(|l| l.unwrap()) {

        if !line.is_empty() && !last_line.is_empty() {

            for (k, v) in last_line.split_whitespace().zip(line.split_whitespace()) {
                if k == "%idle" {
                    println!("idle: {}", v);
                }
                if k == "%commit" {
                    println!("mem used: {}", v);
                }
            }
        }

        last_line = line;
    }
}

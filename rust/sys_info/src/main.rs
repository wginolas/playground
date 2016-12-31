extern crate serial;
extern crate num_cpus;

use std::io;
use std::io::{Read, BufReader, BufRead, Write};
use std::fs::File;
use std::str::FromStr;
use std::thread::sleep;
use std::time::Duration;
use std::num::ParseFloatError;
use std::collections::VecDeque;

use serial::prelude::*;
use serial::SerialDevice;

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

const WINDOW: usize = 10;


struct CpuMeasureState {
    cpus: usize,
    uptimes: VecDeque<Uptime>,
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
    let mut v = VecDeque::new();
    v.push_back(uptime()?);

    Ok(CpuMeasureState {
        cpus: num_cpus::get(),
        uptimes: v,
    })
}

fn cpu_usage(s: &mut CpuMeasureState) -> Result<f64, SysInfoError> {
    let last_uptime = uptime()?;

    if s.uptimes.len() > WINDOW {
        s.uptimes.pop_front();
    }
    s.uptimes.push_back(last_uptime);

    let du = s.uptimes.back().unwrap().uptime - s.uptimes.front().unwrap().uptime;
    if du < 0.001 {
        return Ok(0.0);
    }

    let cpus = s.cpus as f64;
    let di = (s.uptimes.back().unwrap().idle - s.uptimes.front().unwrap().idle) / cpus;

    return Ok(1.0 - (di / du));
}

fn scale(v: f64, old_min: f64, old_max: f64, new_min: f64, new_max: f64) -> u8 {
    let mut f = (v - old_min) * (new_max - new_min) / (old_max - old_min) + new_min;
    f = f.min(new_max).max(new_min);

    f as u8
}

fn send_info(port: &mut serial::SystemPort, cpu_used: f64, mem_used: f64) -> serial::Result<()> {
    let cpu_used_scaled = scale(cpu_used, 0.0, 1.0, 0.0, 235.0);
    let mem_used_scaled = scale(mem_used, 0.0, 1.0, 0.0, 235.0);

    port.write_all(&[33, mem_used_scaled, cpu_used_scaled])?;
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

fn two_words(s: String) -> Option<(String, String)> {
    let mut iter = s.split_whitespace();

    if let Some(first) = iter.next() {
        if let Some(second) = iter.next() {
            return Some((first.to_string(), second.to_string()));
        }
    }

    None
}

fn get_mem_usage() -> io::Result<f64> {
    let f = BufReader::new(File::open("/proc/meminfo")?);
    let (total, avail) = f.lines()
        .map(|l| l.unwrap())
        .map(two_words)
        .filter_map(|x| x)
        .scan((None, None), |state, item| {
            let (key, val) = item;
            if key == "MemTotal:" {
                state.0 = Some(val.parse::<f64>().unwrap_or(1.0));
                return Some(*state);
            }
            if key == "MemAvailable:" {
                state.1 = Some(val.parse::<f64>().unwrap_or(0.0));
                return Some(*state);
            }
            Some(*state)
        })
        .filter_map(|state| {
            let (total_option, avail_option) = state;
            if let Some(total) = total_option {
                if let Some(avail) = avail_option {
                    return Some((total, avail));
                }
            }

            None
        })
        .next()
        .unwrap();

    Ok(1.0 - avail / total)
}

fn main() {
    let mut port = open_serial_port().unwrap();
    let mut cm = init_cpu_measurement().unwrap();
    let delay = Duration::from_millis(100);

    loop {
        sleep(delay);
        let cpu_usage = cpu_usage(&mut cm).unwrap();
        let mem_usage = get_mem_usage().unwrap();
        send_info(&mut port, cpu_usage, mem_usage).unwrap();
    }
}

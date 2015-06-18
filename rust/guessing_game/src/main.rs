extern crate rand;

use std::io;
use rand::Rng;

fn main() {
    println!("Guess a number.");

    let secret_number = rand::thread_rng().gen_range(1, 10);
    println!("The secret number is: {}", secret_number);

    println!("Please input your guess.");

    let mut guess = String::new();

    io::stdin().read_line(&mut guess)
        .ok()
        .expect("Failed to read line");

    println!("You guessed: {}", guess);
}

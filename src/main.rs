use std::{time::Duration, thread::sleep};

mod web;
mod state;

use state::{Ledger, State};
use web::{Dest, build_client, status};

#[tokio::main]
async fn main() {
    // init
    let mut websites = Vec::<Dest>::new();
    websites.push(Dest::new("https://chocorp.net", "https://192.168.0.104", "chocorp.net"));
    websites.push(Dest::new("https://print.chocorp.net", "https://192.168.0.106", "print.chocorp.net"));
    let client = build_client();

    // filling ledger
    let mut ledger = Ledger::new();
    for website in &websites {
        ledger.add(website.url.clone());
    }

    loop {
        for website in &websites {
            let status = status(&client, website.clone()).await;
            let state = match status {
                Ok(status) => State::from_status(status),
                Err(e) => {
                    println!("unknown error: {:?}", e);
                    State::Error(e.to_string())
                }
            };
            ledger.update(website.url, state);
        }
        sleep(Duration::from_secs(60));
    }
}
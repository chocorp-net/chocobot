use std::{time::Duration, thread::sleep};

mod web;
mod state;

use state::{Ledger, State};
use web::{Dest, build_client, status};

#[tokio::main]
async fn main() {
    // init
    let mut websites = Vec::<Dest>::new();
    websites.push(Dest::new("https://chocorp.net", "chocorp.net"));
    websites.push(Dest::new("https://print.chocorp.net", "print.chocorp.net"));
    let client = build_client();

    // filling ledger
    let mut ledger = Ledger::new();
    for website in &websites {
        ledger.add(website.url.clone());
    }

    loop {
        for website in &websites {
            let status = status(&client, website.clone()).await.unwrap();
            let state = State::from_status(status);
            ledger.update(website.url, state);
        }
        sleep(Duration::from_secs(6));
    }
}
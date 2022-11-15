use std::{env, thread::sleep, time::Duration};

mod state;
mod web;

use discord::{model::UserId, Discord};
use state::{Ledger, State};
use web::{build_client, status, Dest};

#[tokio::main]
async fn main() {
    // init
    let websites = vec![
        Dest::new(
            "https://chocorp.net",
            "https://192.168.0.104",
            "chocorp.net",
        ),
        Dest::new(
            "https://print.chocorp.net",
            "http://192.168.0.106",
            "print.chocorp.net",
        ),
    ];
    let web_client = build_client();

    // discord
    let discord = Discord::from_bot_token(&env::var("DISCORD_TOKEN").expect("expected token"))
        .expect("login failed");
    let user_id_str = &env::var("DISCORD_OWNER_ID").unwrap();
    let user_id: u64 = user_id_str.parse().unwrap();
    let channel = discord.create_dm(UserId(user_id)).unwrap();

    // filling ledger
    let mut ledger = Ledger::new();
    for website in &websites {
        ledger.add(website.url.clone());
    }

    // main loop
    loop {
        for website in &websites {
            let status = status(&web_client, website.clone()).await;
            let state = match status {
                Ok(status) => State::from_status(status),
                Err(e) => {
                    println!("unknown error: {:?}", e);
                    State::Error(e.to_string())
                }
            };
            if ledger.update_and_trigger(website.url, state) {
                discord
                    .send_message(
                        channel.id,
                        &format!("Detected issue with `{}`", website.url),
                        "",
                        false,
                    )
                    .expect("Unable to send message");
            }
        }
        sleep(Duration::from_secs(60));
    }
}

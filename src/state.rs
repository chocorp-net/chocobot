use std::collections::HashMap;

use reqwest::StatusCode;

#[derive(PartialEq, Clone, Debug)]
pub enum State {
    Down,  // status.unwrap() panics
    Ok,  // 200
    BadGateway,  // 502
    Unknown,  // other status code
    Error(String),  // an issue happened
}

impl State {
    pub fn from_status(status: StatusCode) -> State {
        match status.as_u16() {
            200 => State::Ok,
            502 => State::BadGateway,
            _ => State::Unknown
        }
    }
}

/// Keep track of all websites state
pub struct Ledger<'l> {
    list: HashMap<&'l str, State>
}

impl<'l> Ledger<'l> {
    pub fn new() -> Ledger<'l> {
        Ledger { list: HashMap::<&'l str, State>::new() }
    }

    pub fn add(&mut self, key: &'l str) {
        self.list.insert(key, State::Down);  // init all at Down state
    }

    pub fn update(&mut self, key: &'l str, new_state: State) {
        let old_state = self.list.get(key.clone()).unwrap().clone();
        self.list.insert(key, new_state.clone());
        if old_state == State::Ok && old_state != new_state {
            println!("something bad happened for {key}!");
        }
    }
}
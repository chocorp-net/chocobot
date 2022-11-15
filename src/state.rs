use std::collections::HashMap;

use reqwest::StatusCode;

#[derive(PartialEq, Eq, Clone, Debug)]
pub enum State {
    Down,          // status.unwrap() panics
    Ok,            // 200 or 302
    BadGateway,    // 502
    Unknown,       // other status code
    Error(String), // an issue happened
}

impl State {
    pub fn from_status(status: StatusCode) -> State {
        match status.as_u16() {
            200 => State::Ok,
            // TODO follow redirects and read the 200 from /login
            302 => State::Ok,  // Octoprint redirects to the login pqge
            502 => State::BadGateway,
            _ => State::Unknown,
        }
    }
}

/// Keep track of all websites state
pub struct Ledger<'l> {
    list: HashMap<&'l str, State>,
}

impl<'l> Ledger<'l> {
    pub fn new() -> Ledger<'l> {
        Ledger {
            list: HashMap::<&'l str, State>::new(),
        }
    }

    pub fn add(&mut self, key: &'l str) {
        self.list.insert(key, State::Down); // init all at Down state
    }

    /// Returns true if it needs an alert
    pub fn update_and_trigger(&mut self, key: &'l str, new_state: State) -> bool {
        let old_state = self.list.get(key.clone()).unwrap().clone();
        self.list.insert(key, new_state.clone());
        old_state == State::Ok && old_state != new_state
    }
}

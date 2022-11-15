use gethostname::gethostname;
use reqwest::{self, Client, ClientBuilder, StatusCode};
use std::time::Duration;

#[derive(Clone)]
pub struct Dest<'d> {
    pub url: &'d str,
    pub fallback: &'d str,
    pub host: &'d str,
}

impl<'d> Dest<'d> {
    pub fn new(url: &'d str, fallback: &'d str, host: &'d str) -> Dest<'d> {
        Dest {
            url,
            fallback,
            host,
        }
    }
}

/// Return true if run on a raspberry
fn is_local() -> bool {
    let result = gethostname().into_string();
    match result {
        Ok(hostname) => hostname.contains("rasp"),
        Err(_) => false,
    }
}

/// Build reqwest HTTP client
pub fn build_client() -> Client {
    let local = is_local();
    let timeout = Duration::from_secs(1);

    let mut builder = ClientBuilder::new().timeout(timeout);

    if local {
        builder = builder.danger_accept_invalid_hostnames(true);
    }

    builder.build().unwrap()
}

pub async fn status<'d>(
    client: &Client,
    dest: Dest<'d>,
) -> Result<StatusCode, Box<dyn std::error::Error>> {
    let url = if is_local() {
        dest.clone().fallback
    } else {
        dest.clone().url
    };
    let resp = client.get(url).header("Host", dest.host).send().await?;
    let status = resp.status();

    Ok(status)
}

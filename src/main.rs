use reqwest::{self, header, StatusCode, ClientBuilder, Client};
use gethostname::gethostname;
use std::time::Duration;

#[derive(Clone)]
struct Dest<'d> {
    pub url: &'d str,
    pub host: &'d str,
}

impl<'d> Dest<'d> {
    pub fn new(url: &'d str, host: &'d str) -> Dest<'d> {
        Dest{ url, host }
    }
}

#[tokio::main]
async fn main() {
    let local = is_local();
    let chocorp_dest = Dest::new(if local { "https://192.168.0.104" } else { "https://chocorp.net" }, "chocorp.net");
    let chocoprint_dest = Dest::new(if local { "https://192.168.0.106" } else { "https://print.chocorp.net" }, "print.chocorp.net");
    let client = build_client(local);
    let result = query(&client, chocorp_dest).await;
    println!("{:?}", result.unwrap());
    let result = query(&client, chocoprint_dest).await;
    println!("{:?}", result.unwrap());
}

fn is_local() -> bool {
    let result = gethostname().into_string();
    match result {
        Ok(hostname) => hostname.contains("rasp"),
        Err(_) => false
    }
}

fn build_client(local: bool) -> Client {
    let mut headers = header::HeaderMap::new();
    headers.insert(header::HOST, header::HeaderValue::from_static("chocorp.net"));
    let timeout = Duration::from_secs(1);

    let mut builder = ClientBuilder::new()
        .default_headers(headers)
        .timeout(timeout);

    if local {
        builder = builder.danger_accept_invalid_hostnames(true);
    }

    builder.build().unwrap()
}

async fn query<'d>(client: &Client, dest: Dest<'d>) -> Result<StatusCode, Box<dyn std::error::Error>> {
    let resp = client
        .get(dest.clone().url)
        .header("Host", dest.host)
        .send()
        .await?;
    let code = resp.status();

    Ok(code)
}
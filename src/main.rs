use reqwest::{self, header, StatusCode, ClientBuilder, Client};
use gethostname::gethostname;
use std::time::Duration;

#[tokio::main]
async fn main() {
    let local = is_local();
    let chocorp_url = if local { "https://192.168.0.104" } else { "https://chocorp.net" };
    let chocoprint_url = if local { "https://192.168.0.106" } else { "https://print.chocorp.net" };
    let client = build_client(local);
    let mut result = query(&client, chocorp_url).await;
    println!("{:?}", result.unwrap());
    result = query(&client, chocoprint_url).await;
    println!("{:?}", result.unwrap());
}

fn is_local() -> bool {
    let result = gethostname().into_string();
    match result {
        Ok(hostname) => hostname.contains("rasp"),
        Err(_) => false
    }
}

fn build_client(_local: bool) -> Client {
    let mut headers = header::HeaderMap::new();
    headers.insert(header::HOST, header::HeaderValue::from_static("chocorp.net"));
    let timeout = Duration::from_secs(1);

    ClientBuilder::new()
        .default_headers(headers)
        .timeout(timeout)
        .danger_accept_invalid_hostnames(true)
        .build().unwrap()
}

async fn query(client: &Client, url: &str) -> Result<StatusCode, Box<dyn std::error::Error>> {
    let code = client
        .get(url)
        .header("Host", "chocorp.net")
        .send()
        .await?
        .status();

    Ok(code)
}
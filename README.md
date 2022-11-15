# Chocobot

Small piece of Rust code which sends a Discord dm whenever one of my service crashes.

## Config

This code uses three environment variables to work, `DISCORD_OWNER_ID`, `DISCORD_TOKEN` and `LOCAL`.

- `DISCORD_OWNER_ID` is the UUID of the one who will receive DMs.
- `DISCORD_TOKEN` is the bot Discord token. See [Discord developers doc](https://discord.com/developers/docs/intro).

My services are running on Raspberry PIs, and if the code is running inside the same network, I would rather use their local IP address.
If `LOCAL` is set, the local IP addresses will be used instead of domain names.
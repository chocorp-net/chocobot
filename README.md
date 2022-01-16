# Chocobot

Small discord entity who DM status messages of my local services.
Runs on a Raspberry Pi Zero W.

## Install

A `.ruby-version` is included. Whenever you are done with your version manager, run:

```bash
bundle install
```

## Run

Before running the bot, you need to create a few environment variables:

```bash
cat << STOP
ENV['CHOCOBOT_ENV']='dev'  # case insensitive; if other than 'production', considered as development
ENV['DISCORD_OWNER_ID']='1234567890'  # Discord ID of the user you want to receive the DMs
ENV['DISCORD_TOKEN']='abcdef45'  # Discord authorization token
STOP > config.rb
ruby chocobot.rb
```

And... It's probably gonna fail somehow. Plugins need their configuration as well.

## Plugins

I decided to split functionalities into plugins. Each plugin receives as cosntructor parameters the scheduler (from [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) gem) and a [Chocobot](lib/chocobot.rb#L8) instance.

Each plugin loads its configuration from the environment. A good practise is to prefix environment variable by the plugin name to avoid conflicts.

### Nagios

The Nagios plugin runs a TCP server which listens to Chocorp's Nagios alerts, and formats then and sends them to the Discord bot.

Example config:

```bash
cat << STOP
ENV['NAGIOS_SERVER_HOSTNAME']='127.0.0.1'
ENV['NAGIOS_SERVER_PORT']='12345'
STOP >> config.rb
```

### Octoprint

The [OctoPrint](https://github.com/OctoPrint/OctoPrint) plugins queries an OctoPrint API and sends various information to the bot, such as when the printer starts and stops printing for instance.

Example config:

```bash
cat << STOP
ENV['OCTOPRINT_URL']='https://octoprint.example/api'
ENV['OCTOPRINT_APIKEY']='API_KEY'
STOP >> config.rb
```

### Root-Me

The [Root-Me](https://www.root-me.org) plugin queries the Root-Me API and notifies the owner when one of his friends flags a challenge.

Example config:

```bash
cat << STOP
ENV['ROOTME_URL']='https://api.www.root-me.org'
ENV['ROOTME_APIKEY']='API_KEY'
STOP >> config.rb
```


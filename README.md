# Meet

Start a [Jitsi](https://meet.jit.si) meeting quickly with `meet`. It creates a
meeting with a secure ID and prints the meeting URL to `stdout`. It can style,
open, copy, and send the URL for your convenience. No registration required, no
data collected.

### Dependencies

`meet` has no required runtime dependencies.

Jitsi requires a browser like Firefox, the [Jitsi Desktop
app](https://desktop.jitsi.org/), or a telephone to join a meeting.

*Optional* dependencies add more features:
- `xsel` to copy URL to clipboard
- `xdg-open` to open the URL in your browser
- `keybase` to send the URL to a friend

## Usage

```sh-session
$ meet
https://meet.jit.si/A8ul9DAc/Meeting
$ meet -c hack on meet
https://meet.jit.si/iN9SYLvP/HackOnMeet
🚀 copied to clipboard!
```

### Options

| feature  |   short   |        long        |                 description                  |
|----------|-----------|--------------------|----------------------------------------------|
| settings |           | `--init`           | initialize meet settings                     |
|          | `-u URL`  | `--use URL`        | use URL for this meeting                     |
| style    | `-s`      | `--snake`          | use snake_case for meeting title             |
|          | `-d`      | `--dash`           | use dashes for meeting title                 |
|          | `-t`      | `--title`          | use TitleCase for meeting title (default)    |
|          | `-S`      | `--shout`          | use SHOUT👏️CASE🗯️ for meeting title        |
|          | `-3`      | `--heart`          | use ❣️heart❤️style❣️ for meeting title       |
|          | `-j TEXT` | `--emoji=TEXT`     | put `TEXT` between words of meeting title    |
| open     | `-o`      | `--open`           | open url in your browser after a short pause |
|          | `-O`      | `--open-immediate` | open url in your browser immediately         |
| copy     | `-c`      | `--copy`           | copy url to clipboard using `xsel`           |
| send     | `-k USER` | `--send-kb=USER`   | send url to `USER` on Keybase                |

## Installation

Go to [releases](https://github.com/ryanprior/meet/releases) and download the
latest archive. Then unpack it somewhere on your PATH, such as:

```sh-session
$ cd ~/Downloads
$ tar xzf meet-1.1.0.tgz
$ sudo install meet /usr/local/bin/meet
```

### Installation from source

To install `meet` from source, you will need these dependencies:
- git
- make
- [crystal](https://crystal-lang.org/)
- coreutils
- readline

Crystal has these transitive dependencies: `gcc`, `pkg-config`, `libpcre3-dev`,
`libevent-dev`.


Follow these steps to install:
```sh-session
$ git clone https://github.com/ryanprior/meet.git
$ cd meet
$ make
$ sudo make install
```

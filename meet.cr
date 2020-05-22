# meet -- start a meeting quickly.
# Copyright © 2020 Yana Chen <yana@thefloating.cloud>
# Copyright © 2020 Ryan Prior <rprior@protonmail.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.

require "option_parser"
require "colorize"

open_link = false
open_immediate = false
send_to_keybase = false
keybase_recipient = ""
xclip = false
meeting_name = ["meeting"]
enum TitleStyle
  SnakeCase
  Dash
  TitleCase
  ScreamCase
  Heart
  Custom
end
name_style = TitleStyle::TitleCase
custom_text = ""

def title(style, words, custom_text="")
  case style
  when TitleStyle::SnakeCase
    words.join "_"
  when TitleStyle::Dash
    words.join "-"
  when TitleStyle::TitleCase
    words.map(&.capitalize).join
  when TitleStyle::ScreamCase
    words.map(&.upcase).join("👏️") + "🗯️"
  when TitleStyle::Heart
    "❣️" + words.join("❤️") + "❣️"
  when TitleStyle::Custom
    words.join(custom_text)
  else raise "unknown title style"
  end
end

OptionParser.parse do |parser|

  parser.banner = "Usage: meet [arguments] [meeting name]"
  parser.on("-s", "--snake", "use snake_case for meeting title") {
    name_style = TitleStyle::SnakeCase
  }
  parser.on("-d", "--dash", "use dashes for meeting title") {
    name_style = TitleStyle::Dash
  }
  parser.on("-t", "--title", "use TitleCase for meeting title") {
    name_style = TitleStyle::TitleCase
  }
  parser.on("-S", "--shout", "use SHOUT👏️CASE🗯️ for meeting title") {
    name_style = TitleStyle::ScreamCase
  }
  parser.on("-3", "--heart", "use ❣️heart❤️style❣️ for meeting title") {
    name_style = TitleStyle::Heart
  }
  parser.on("-j TEXT", "--emoji=TEXT", "put TEXT between words of meeting title") do |text|
    name_style = TitleStyle::Custom
    custom_text = text
  end
  parser.on("-o", "--open", "open URL in your browser after a short pause") {
    open_link = true
  }
  parser.on("-O", "--open-immediate", "open URL in your browser immediately") {
    open_link = true
    open_immediate = true
  }
  parser.on("-c", "--copy", "copy URL to clipboard using xsel") {
    xclip = true
  }
  parser.on("-k USER", "--send-kb=USER", "send URL to USER on Keybase") do |user|
    send_to_keybase = true
    keybase_recipient = user
  end
  parser.on("-v", "--version", "show version information") do
    version = {{read_file("./shard.yml")
                 .lines
                 .select(&.starts_with? "version")
                 .first
               }}.split(/: */).last
    git = {{"#{`git rev-parse HEAD`}".strip}}
    puts "meet version #{version} (#{git})"
    exit
  end
  parser.on("-h", "--help", "show this help") do
    puts parser
    exit
  end


  parser.unknown_args do |args|
    meeting_name = args unless args.empty?
  end
end

def super_secure_string
  Random::Secure.base64(6)
end

title_text = title(name_style, meeting_name, custom_text)
link = "https://meet.jit.si/#{super_secure_string}/#{title_text}"
puts link.colorize :blue
if xclip
  `echo -n "#{link}" | xsel -bi`
  c = "c".colorize.mode :underline
  puts "🚀️ #{c}opied to clipboard!"
end
if send_to_keybase
  `keybase chat send --private "#{keybase_recipient}" "#{link}"`
  k = "k".colorize.mode :underline
  whom = keybase_recipient.colorize :light_yellow
  puts "📨️ sent lin#{k} to #{whom} on Keybase!"
end
if open_link
  o = "o".colorize.mode :underline
  puts "🌍️ #{o}pening in your browser…"
  sleep(0.5.seconds) unless open_immediate
  `xdg-open #{link}`
end

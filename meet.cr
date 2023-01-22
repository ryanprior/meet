# meet -- start a meeting quickly.
# Copyright © 2020 Yana Chen <yana@thefloating.cloud>
# Copyright © 2020 - 2022 Ryan Prior <rprior@protonmail.com>
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
require "yaml"
require "readline"
require "./base58"

config_home = ENV.fetch("XDG_CONFIG_HOME", %Q[#{ENV["HOME"]}/.config])
meet_dir = "#{config_home}/meet"
settings_file = "#{meet_dir}/settings.yml"
settings = if File.exists?(settings_file)
             YAML.parse(File.read(settings_file)).as_h
           else Hash(String, YAML::Any).new end
base_url = settings.fetch("base_url", YAML::Any.new "meet.jit.si").as_s
secure_name = settings.fetch("secure_name", YAML::Any.new true).as_bool

open_link = false
open_immediate = false
keybase_recipient : String? = nil
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
  omit_chars = "/#?"
  words = words.map &.tr(omit_chars, ".")

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
    keybase_recipient = user
  end
  parser.on("-u URL", "--use=URL", "url to use") do |url|
    base_url = url
  end
  parser.on("-i", "--insecure", "omit secure-random portion of meeting URL") {
    secure_name = false
  }
  parser.on("", "--secure", "include secure-random portion of meeting URL") {
    secure_name = true
  }
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
  parser.on("", "--init", "⚙️ initialize meet settings") do
    Dir.mkdir_p(meet_dir)
    new_settings = Hash(String, String | Bool).new
    input = Readline.readline("Base url (#{base_url}): ")
    new_settings["base_url"] = case input
                               when Nil
                                 base_url
                               when String
                                 input.empty? ? base_url : input.strip
                               else raise "unexpected input"
                               end
    input = Readline.readline("Add random letters to URL for security? (Y/n): ")
    new_settings["secure_name"] = case input
                                  when Nil
                                    true
                                  when String
                                    case input
                                    when ""
                                      true
                                    when /^(([yY](es)?)|([tT](rue)?))$/
                                      true
                                    when /^(([nN]o?)|([fF](alse)?))$/
                                      false
                                    else
                                      STDERR.puts "meet: fatal: expected y/n, got: #{input}"
                                      exit 1
                                    end
                                  else raise "unexpected input"
                                  end
    File.open("#{settings_file}", "w") do |f|
      f.puts(new_settings.to_yaml)
    end
    STDERR.puts "📝 wrote config to #{settings_file}"
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
   Base58.random(6)
end

title_text = title(name_style, meeting_name, custom_text)
link = ["https:/", base_url, secure_name ? super_secure_string : nil, title_text].compact.join '/'
puts link.colorize :blue

if xclip
  `echo -n "#{link}" | xsel -bi`
  c = "c".colorize.mode :underline
  puts "🚀️ #{c}opied to clipboard!"
end

if keybase_recipient
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

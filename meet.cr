require "option_parser"

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
  parser.on("-h", "--heart", "use ❣️heart❤️style❣️ for meeting title") {
    name_style = TitleStyle::Heart
  }
  parser.on("-j TEXT", "--emoji=TEXT", "put TEXT between words of meeting title") do |text|
      name_style = TitleStyle::Custom
      custom_text = text
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
puts link

require "option_parser"

meeting_name = ["meeting"]

def title(words)
  words.join("-")
end

OptionParser.parse do |parser|

  parser.banner = "Usage: meet [meeting name]"

  parser.unknown_args do |args|
    meeting_name = args unless args.empty?
  end
end

def super_secure_string
  Random::Secure.base64(6)
end

title_text = title(meeting_name)
link = "https://meet.jit.si/#{super_secure_string}/#{title_text}"
puts link

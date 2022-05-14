module Base58
  ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".chars

  def self.random(n, generator = Random::Secure)
    String.build(n) do |result|
      n.times { result << ALPHABET.sample(generator) }
    end
  end
end

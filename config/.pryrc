require 'pry-doc'

class Integer
  def to_bin_s; self.to_s(2); end
  def to_hex_s; self.to_s(16); end
end

class String
  def from_bin_s; self.to_i(2); end
  def from_hex_s; self.to_i(16); end
end

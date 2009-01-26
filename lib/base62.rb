class Base62 < BaseAnything

  B62_CHRS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  
  def self.encode(val)
    encode_with_chars(val,B62_CHRS)
  end

  def self.validate(key)
    validate_with_chars(key,B62_CHRS)
  end

  def self.decode(key)
    decode_with_chars(key,B62_CHRS)
  end
  
end
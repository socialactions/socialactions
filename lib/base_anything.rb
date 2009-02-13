class BaseAnything
  
  DEFAULT_CHRS = "01"
  
  def self.encode(val)
    encode_with_chars(val,DEFAULT_CHRS)
  end

  def self.validate(key)
    validate_with_chars(key,DEFAULT_CHRS)
  end

  def self.decode(key)
    decode_with_chars(key,DEFAULT_CHRS)
  end
  
  def self.encode_with_chars(val,base_chrs)
    base = base_chrs.size
    return nil if val.nil? or val < 0
    return val.to_s if val == 0
    r = ""
    until val == 0
      r << base_chrs[val % base]
      val = val / base
    end
    r.reverse
  end

  def self.validate_with_chars(key,base_chrs)
    return false if key.nil? or !key.class.eql?(String)
    key = key.strip
    return false if key.length <= 0
    (0...key.size).each do |i|
      return false unless base_chrs.include?(key[i])
    end
    true
  end

  def self.decode_with_chars(key,base_chrs)
    key = key.to_s.reverse
    return nil unless self.validate_with_chars(key,base_chrs)
    base = base_chrs.size
    val = 0
    (0...key.size).each do |i|
      norm = base_chrs.rindex(key[i])
      val = val + (norm * (base ** i))
    end
    val
  end
  
end
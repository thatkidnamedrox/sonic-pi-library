# Namespace for String methods.
module StringMethods

  # Formats hexadecimal into list of numbers.
  #
  # @param time_scale [Numeric]
  # @example Turn hexadecimal string into times
  #   "8892".byte => (ring 0.0, 1.0, 2.0, 2.75, 3.5)
  # @return [SonicPi::Core::RingVector<Numeric>]
  def byte(time_scale=1)
    pattern = self
    pattern.gsub(/\s/, "").split(//).flat_map.with_index{ |character, j|
      bits = character.to_i(16).to_s(2)
      bits = bits.rjust(4,'0') # padding, leading zeros or truncating
      bits = bits[bits.size-4..bits.size-1]
      bits.split(//).filter_map.with_index {|bit, i| j + i*0.25 if bit == '1' }
    }.ring.scale(time_scale)
  end
  alias hex byte

  # Parse string into pattern utilizing eudicean algorithm
  #
  # @example Switch on indicies 3 and 6 for <1,8>
  #   "1-8-<(3,6)".euc => (ring true, false, false, true, false, false, true, false)
  # @return <SonicPi::Core::RingVector<TrueClass>>
  def euc
    res = [].ring
    op = nil
    string = self
    string = string.split(" ")
    string.each do |ep|
      if "+^-&".include?(ep)
        op = ep
        next
      end
      ep = ep.split("-")
      pattern = spread(ep[0].to_i, ep[1].to_i)
      i = 2
      while i < ep.size
        g = ep[i][0]
        h = ep[i][1..].to_i
        case g
        when '>'
          j = ep[i][2..-2].split(",")
          pattern = pattern.map.with_index {|x,i| j.include?(i.to_s) ? false : x }.ring
        when '<'
          j = ep[i][2..-2].split(",")
          pattern = pattern.map.with_index {|x,i| j.include?(i.to_s) ? true : x }.ring
        when 't'
          pattern = pattern.take(h)
        when 'n'
          pattern = pattern.repeat(h)
        when 'r'
          pattern = pattern.rotate(h)
        when 'm'
          pattern = pattern.mirror
        when 's'
          pattern = pattern.stretch(h)
        when 'R'
          pattern = pattern.reverse
        when 'd'
          pattern = pattern.drop(h)
        when '!'
          pattern = pattern.map {|x| !x }.ring
        else
        end
        i+=1
      end
      case op
      when "++"
        res += pattern
      when "+"
        res = res.map.with_index {|x,i| pattern.to_a[i] != nil ? pattern[i] || x : x }.ring
      when "-"
        res = res.map.with_index {|x,i| pattern.to_a[i] != nil ? !pattern[i] && x : x }.ring
      when "^"
        res = res.map.with_index {|x,i| pattern.to_a[i] != nil ? pattern[i] ^ x : x }.ring
      when "&"
        res = res.map.with_index {|x,i| pattern.to_a[i] != nil ? pattern[i] && x : x }.ring
      else
        res += pattern
      end
      op = nil
    end
    res
  end
  alias e euc

end
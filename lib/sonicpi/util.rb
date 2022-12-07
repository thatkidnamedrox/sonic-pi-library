# Namespace for Util methods.
module UtilMethods

  # Parse string into pattern utilizing eudicean algorithm
  #
  # @param args [Array<String>,String]
  # @example Switch on indicies 3 and 6 for <1,8>
  #   euc("1-8-<(3,6)") => (ring true, false, false, true, false, false, true, false)
  # @return <SonicPi::Core::RingVector<TrueClass>>
  def euc(*args)
    res = [].ring
    op = nil
    args.each do |string|
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
    end
    res
  end
  alias e euc

  # Trigger given block based on tick/look value system.
  #
  # @param times [Array<Numeric>]
  # @param duration [Numeric]
  # @param step [Numeric]
  # @param blk [Proc]
  # @example An implementation.
  #   live_loop :foo do
  #     use_bpm 120
  #     loop_duration = 0.25
  #     tick step: loop_duration
  #     duration = 16
  #     times = range(0, duration)
  #     arrange times, duration do |*args|
  #       i,d,g,t = *args # index, duration, sustain, time
  #       sample :bd_haus, lpf: 70
  #     end
  #     sleep loop_duration
  #   end
  # @return [void]
  def arrange (times, duration, step=0.25, &blk)
    times = times.to_a.sort.uniq
    off = times.filter {|x| x % step != 0 }
    offbeats = off.map{|x| x.to_i}.uniq
    index = look % duration
    if times.include?(index)
      t = index
      i = times.find_index(t)
      d = i == times.size - 1 ? duration : times[i+1]
      d -= times[i]
      g = d * 60.0/current_bpm
      args = i,d,t,g
      blk.(*args)
    end
    if offbeats.include?(index)
      a = off.filter_map {|x| x % 1 if x.to_i == index }
      at a, a do |x|
        t = x+index
        i = times.find_index(t)
        d = (i == times.size - 1) ? duration : times[i+1]
        d -= times[i]
        g = d * 60.0/current_bpm
        args = i,d,t,g
        blk.(*args)
      end
    end
  end
  
  # Stack intervals into list.
  #
  # @param intervals [Array<Numeric>]
  # @param length [Numeric]
  # @param args [Array<String>] optional args
  # @example Generate list of times
  #   stack([0.75], 4) => (ring 0, 0.75, 1.5, 2.25)
  # @example Generate maj7 chord, alternating major and minor thirds
  #   stack([4,3], 7) => (ring 0, 4, 7, 11)
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def stack (intervals, length=nil, *args)
    dist = intervals
    n = 0
    res = [n]
    dist = [dist].ring if !dist.is_a?(Array)
    dist = dist.ring if !dist[dist.length]
    length = dist.size + 1 if !length
    (length-1).times do |i|
      n += dist[i]
      res.push(n)
    end
    res = res.reverse if args.include?(:reverse)
    res.ring
  end
  
  # Generate an expontential range from the given base.
  #
  # @param start [Numeric]
  # @param finish [Numeric]
  # @param step [Numeric]
  # @param base [Numeric]
  # @return [SonicPi::Core::RingVector<Numeric>]
  def exprange(start, finish, step, base)
    res = range(start, finish, step)
    res = res.map{ |x| base**x }.ring
  end
  
  # Return list of random numbers within given range.
  #
  # @param size [Numeric]
  # @param rand_type [Symbol]
  # @param opts [Hash] optional args
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def rrange (size, rand_type=nil, **opts)
    seed = opts.fetch(:seed, nil)
    rand_types = [:white, :pink, :light_pink, :dark_pink, :perlin]
    rand_type = nil unless rand_types.include?(rand_type)
    use_random_seed seed if seed
    use_random_source rand_type if rand_type
    res = size.times.collect { rand }.ring
  end

end


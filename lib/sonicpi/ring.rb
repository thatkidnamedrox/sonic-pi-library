# Namespace for RingVector methods.
module RingVectorMethods

  # Return intervals between each element in the list.
  # 
  # @param length [Numeric]
  # @return [SonicPi::Core::RingVector<Numeric>]
  def between(length)
    list = self
    list.sort.map.with_index do |x,i|
      if i < list.size - 1
        finish =  list[i+1]
      else
        finish = length
      end
      finish - x
    end.ring
  end

  # Returns onsets derived from intervals between consecutive elements.
  #
  # @return [SonicPi::Core::RinVector<Hash>] 
  def onset
    list = self
    list.sort.map.with_index do |x,i|
      if i < list.size - 1
        finish =  list[i+1]
      else
        finish = 1
      end
      {start: x, finish: finish}
    end.ring
  end

  # Quantifies elements in list based on step.
  #
  # @param step [Numeric] should be positive number.
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def quant(step)
    list = self
    list.map {|x| (x/step).to_i * step }.ring
  end

  # Convert list into dash notation using truthy values.
  #
  # @return [String]
  def dash
    self.map {|x| x ? "x" : "-" }.join
  end

  # Stack intervals into list.
  #
  # @param intervals [Array<Numeric>]
  # @param length [Numeric]
  # @param args [Array<String>]
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def stack (intervals, length=nil,*args)
    dist = intervals
    list = self
    dist = [dist].ring if !is_list_like?(dist)
    dist = dist.ring if !dist[dist.length]
    length = dist.size + 1 if !length
    list.flat_map do |el|
      n = el
      res = [n]
      (length-1).times do |i|
        n += dist[i]
        res.push(n)
      end
      res = res.reverse if args.include?(:reverse)
      res
    end
  end

  # Clip the maximum value of the array.
  #
  # @param max [Numeric]
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def clip(max)
    list = self
    list = list.filter {|x| x < max }
  end

  # Normalize values in list. Can be used on boolean lists.
  #
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def norm
    size = self.size.to_f
    self.to_a.filter_map.with_index {|x,i| i/size if x }.ring
  end

  # Transform using drop-2 voicing.
  #
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def drop2
    list = self.sort.to_a
    list[1] = list[1] - 12
    list.ring.sort
  end

  # Transform using drop-4 voicing.
  #
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def drop4
    list = self.sort.to_a
    list[3] = list[3] - 12 if list.size >= 4
    list[1] = list[1] - 12
    list.ring.sort
  end

  # Convert list into an array of pitch classes.
  #
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def pitch
    pitch_class = [:C, :Cs, :D, :Eb, :E, :F, :Fs, :G, :Ab, :A, :Bb, :B]
    list = self
    list.map {|x| pitch_class[x % 12] }.ring
  end

  # Change the root of the list.
  #
  # @param pitch [Numeric, Symbol, String]
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def root(pitch)
    pitch_class = [:C, :Cs, :D, :Eb, :E, :F, :Fs, :G, :Ab, :A, :Bb, :B]
    list = self
    pitch = pitch_class[pitch % 12] if pitch.is_a?(Numeric)
    rotate = list.index {|x| pitch_class[x % 12] == pitch }
    rotate = 0 if !rotate
    list.rotate(rotate)
  end

  # Moves notes above the first.
  #
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def upscale
    list = self
    c = list.first
    list.map {|x|
      y = x
      while y < c
        y += 12
      end
      y
    }.ring
  end

  # Increase the octave range of the list.
  #
  # @param num_octaves [Numeric]
  # @return [SonicPi::Core::RingVector<Numeric>] 
  def octs(num_octaves)
    list = self.to_a
    (num_octaves-1).times do |x|
      list += list.map{ |y| y+ 12*(x+1) }
    end
    list.ring
  end

end
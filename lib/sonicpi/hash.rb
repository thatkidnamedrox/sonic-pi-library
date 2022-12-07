# Namespace for Hash methods.
module HashMethods

  # Swaps keys and values, aggregates keys into array under shared values.
  #
  # @example Transform key-time dictionary into time-key
  #   h = {b: [0,2], s: [1,3], h: [0,1,2,3]}
  #   h.aggregate => {0=>[:b, :h], 2=>[:b, :h], 1=>[:s, :h], 3=>[:s, :h]}
  # @return [Hash{Numeric => Array<Symbol,String>}]
  def aggregate
    r = self
    r = r.to_a.map {|x| x[1].to_a.zip([x[0]]*x[1].size).to_h }
    w = {}
    r.each do |x|
      w.merge!(x) { |k,v1,v2| ([v1] + [v2]).flatten }
    end
    w
  end

end
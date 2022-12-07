# Namespace for Numeric methods.
module NumericMethods

  # Calculates the nearest number.
  #
  # @param args [Array<Numeric>]
  # @example Find the closest note to A# in the C major scale
  #   note = note(:As)
  #   available_notes = scale(:c, :major)
  #   nearest_note = note.nearest?(available_notes) => 69 (A)
  # @return [Numeric]
  def nearest?(*args)
    [args].flatten.min_by {|x| (self-x).abs }
  end

  # Return pitch class.
  #
  # @example Find the closest note to A# in the C major scale
  #   69.pitch => :A
  # @return [Symbol]
  def pitch
    pitch_class = [:C, :Cs, :D, :Eb, :E, :F, :Fs, :G, :Ab, :A, :Bb, :B]
    pitch_class[self % 12]
  end
  
end
# Namespace for Chord methods.
module ChordMethods

  # Maps chord symbols using measure division into two-dimensional array.
  #
  # @param chord_symbols [String]
  # @example Parse bebop blues progression by measure
  #   chord_symbols = "Dm7 G7 (Em7 A7) (Dm7 G7)"
  #   chord_parser(chord_symbols) => [["Dm7"], ["G7"], ["Em7", "A7"], ["Dm7", "G7"]]
  # @return [Array<Array<String>>] chords mapped using measure division
  def chord_parser (chord_symbols)
    chord_symbols = chord_symbols.gsub(/\s/, " ")
    current_chord = ""
    index = 0
    chords = []
    size = chord_symbols.size
    while (index < size)
      chord_symbol = chord_symbols[index]
      case chord_symbol
      when "("
        current_chord = ""
        index += 1
        while (index < size)
          chord_symbol = chord_symbols[index]
          break if chord_symbol == ")"
          current_chord += chord_symbol
          index += 1
        end
        chords.push(current_chord)
        current_chord = ""
      when " "
        chords.push(current_chord) if current_chord != ""
        current_chord = ""
      else
        current_chord += chord_symbols[index]
        if index == size - 1
          chords.push(current_chord)
        end
      end
      index += 1
    end
    res = chords.map{|chrd| chrd.split(" ")}
    return res
  end

  # Parses chord information from given chord symbol.
  #
  # @param chord_symbol [String]
  # @example Parse chord symbol into root and chord quality
  #   chord_info("Cdim7") => ["C", "dim7"]
  # @return [Array<String>] chord name, chord quality
  def chord_info(chord_symbol)
    white_keys = "CDEFGAB"
    roman_numerals = ["I", "i", "V", "v"]
    accidentals = ["b", "#"]
    chord_name = ""
    chord_quality = ""
    cs = chord_symbol
    i = 0
    # check first for accidental, i.e. bVII
    if accidentals.include?(cs[i])
      a = "d" if cs[i] == "b"
      a = "a" if cs[i] == "#"
      chord_name += a
      i+=1
      while roman_numerals.include?(cs[i])
        chord_name += cs[i]
        i+=1
      end
    elsif roman_numerals.include?(cs[i])
      while roman_numerals.include?(cs[i])
        chord_name += cs[i]
        i+=1
      end
    elsif white_keys.include?(cs[i])
      chord_name += cs[i]
      i+=1
      if accidentals.include?(cs[i])
        a = cs[i]
        a = "s" if cs[i] == "#"
        chord_name += a
        i+=1
      end
    end
    chord_quality = cs[i..]
    alternative_chord_names = {
      "maj7" => "M7",
      "min7" => "m7",
      "" => "M",
      "-" => "m",
      "-7" => "m7",
    }
    if !chord_names.to_a.include?(chord_quality)
      chord_quality = alternative_chord_names[chord_quality]
    end
    ##| chord_quality = "maj" if chord_quality == ""
    return chord_name, chord_quality
  end

  # Calculates function of approach chord in relation to target chord.
  #
  # @param chord_symbol [String]
  # @param target_chord_symbol [String]
  # @example Find the functional relationship between A7 and Cmaj7
  #   chord_function("A7", "Cmaj7") => "D"
  # @return [String]
  def chord_function (chord_symbol, target_chord_symbol)
    pitch_class = [:C, :Cs, :D, :Eb, :E, :F, :Fs, :G, :Ab, :A, :Bb, :B]
    target_chord_name, target_chord_quality = chord_info(target_chord_symbol)
    target_chord = chord(target_chord_name, target_chord_quality).map {|x| pitch_class[x % 12] }.ring.uniq
    chord_name, chord_quality = chord_info(chord_symbol)
    chord_name = degree(chord_name, target_chord_name, :diatonic) if chord_name.match(/[da]{0,2}[viVI]{1,3}/i)
    approach_chord = chord(chord_name, chord_quality).map {|x| pitch_class[x % 12] }.ring.uniq
    common_tones = target_chord & approach_chord
    tritone_present = approach_chord.flat_map {|x| approach_chord.map {|y| (y - x).abs }}.to_a.find_index(6)
    if tritone_present
      f = "D"
    elsif common_tones.size >= 2
      f = "T"
    else
      f = "S"
    end
    return f
  end

  # Manages chord changes.
  #
  # @param chord_symbols [String]
  # @param time_scale [Integer]
  # @example Generate schedule for bebop blues changes
  #   chord_symbols = "Dm7 G7 (Em7 A7) (Dm7 G7)"
  #   chord_changes(chord_symbols) => {0.0=>"Dm7", 4.0=>"G7", 8.0=>"Em7", 10.0=>"A7", 12.0=>"Dm7", 14.0=>"G7"}
  # @return [Hash{Numeric => String}]
  def chord_changes (chord_symbols, time_scale=4)
    chord_structure = chord_parser chord_symbols
    chord_structure_flat = chord_structure.flatten.ring
    duration = chord_structure.size * time_scale
    times = chord_structure.map.with_index do |x,i|
      line(i*time_scale,i*time_scale+time_scale,steps: x.size)
    end
    times_flat = times.flatten
    arrange times_flat, duration, 0.25 do |*args|
      i, d, t, g = *args
      time_index = times_flat.find_index(t)
      chrd = chord_structure_flat[time_index]
      if chrd != "%"
        tonic, chord_name, bass = chord_info(chrd)
        c = chord(tonic, chord_name)
        $chrd = c
        cue :chord_change, chrd, c, d
      end
    end
    res = times_flat.zip(chord_structure_flat).to_h
    return res
  end

end
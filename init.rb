Dir[File.join(__dir__, 'lib/sonicpi', '*.rb')].each { |file| require file }

Numeric.class_eval do
  include NumericMethods
end

String.class_eval do
  include StringMethods
end

Hash.class_eval do
  include HashMethods
end

SonicPi::Core::RingVector.class_eval do
  include RingVectorMethods
end

SonicPi::Runtime.module_eval do
  include ChordMethods
  include UtilMethods
end

$dir = 'C:/Users/Roxanne Harris/Documents/Sonic Pi/samples/**'
class Square
  def initialize(number)
    @number = number.to_f
  end
  
  #Compute square root using Newton's method
  def value
    z = @number
    previous = z
    loop do
      z = z - (z*z-@number)/(2.0*z)
      break if (previous-z) < 0.000000001
      previous = z
    end
    z
  end
end
require_relative '../unicolors'

class String
  def unicolors
    Unicolors.of(self)
  end
end

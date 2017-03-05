require_relative '../unicolors'

module Kernel
  private

  def unicolors(string)
    Unicolors.of(string)
  end
end

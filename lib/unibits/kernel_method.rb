require_relative '../unibits'

module Kernel
  private

  def unibits(string)
    Unibits.of(string)
  end
end

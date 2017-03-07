require_relative '../unibits'

module Kernel
  private

  def unibits(string, **kwargs)
    Unibits.of(string, **kwargs)
  end
end

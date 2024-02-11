class Time

  def self.monotonic_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

end

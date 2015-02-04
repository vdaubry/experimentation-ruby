class BackgroundJob
  attr_accessor :work, :callback
  
  def self.async(&block)
    bj = BackgroundJob.new
    bj.work = block
    bj
  end
  
  def then(&block)
    @callback=block
    self
  end
  
  def run
    EM.defer(@work, @callback)
  end
end
require 'active_record'

class Case < ActiveRecord::Base
  class << self
  
    def to_object(data)
      self.new(
        infected: data[:jumlahKasus],
        active: data[:perawatan],
        recovered: data[:sembuh],
        death: data[:meninggal]
      )
    end
  end
end
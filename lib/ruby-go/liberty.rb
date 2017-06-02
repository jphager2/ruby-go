module RubyGo
  class Liberty
    def empty?
      true
    end

    def to_s
      Board::Colors[:empty] 
    end
  end
end

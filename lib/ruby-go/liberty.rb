module RubyGo
  class Liberty
    def empty?
      true
    end

    def to_s
      Board::COLORS[:empty] 
    end
  end
end

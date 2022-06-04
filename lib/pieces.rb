class Piece
end

class Rook < Piece
  attr_reader :string
  def initialize(pos, colour)
    @string = "\u265c"
    @colour = colour
    @position = pos
  end
end
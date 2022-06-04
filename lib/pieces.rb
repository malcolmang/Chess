require_relative "constant"

class Piece
  attr_reader :colour
  attr_reader :string
  def initialize(pos,colour)
    @colour = colour
    @position = pos
  end

  def horizontal_moves(board)
    #from position, move left until edge or occupied piece. Then, move right until edge or occupied piece.
    #returns array of positions
    moves = []
    newpos = @position
    while LETTER_TO_NUM[newpos[0]] != '1' do #MOVE LEFT
      newpos = LETTER_TO_NUM.key(((LETTER_TO_NUM[newpos[0]].to_i)-1).to_s) + @position[1]
      if board[newpos].piece
        if board[newpos].piece.colour == @colour
          break
        else
          moves << newpos
          break
        end
      else
        moves << newpos
      end
    end
    newpos = @position
    while LETTER_TO_NUM[newpos[0]] != '8' do #MOVE RIGHT
      newpos = LETTER_TO_NUM.key(((LETTER_TO_NUM[newpos[0]].to_i)+1).to_s) + @position[1]
      if board[newpos].piece
        if board[newpos].piece.colour == @colour
          break
        else
          moves << newpos
          break
        end
      else
        moves << newpos
      end
    end
    return moves
  end

  def vertical_moves(board)
    #from position, move up until edge or occupied piece. Then, move down until edge or occupied piece.
    #returns array of positions
    moves = []
    newpos = @position
    p newpos
    while newpos[1] != '1' do #MOVE UP
      newpos = @position[0] + ((newpos[1].to_i) -1).to_s
      if board[newpos].piece
        if board[newpos].piece.colour == @colour
          break
        else
          moves << newpos
          break
        end
      else
        moves << newpos
      end
    end
    newpos = @position
    while newpos[1] != '8' do #MOVE DOWN
      newpos = @position[0] + (newpos[1].to_i+1).to_s
      if board[newpos].piece
        if board[newpos].piece.colour == @colour
          break
        else
          moves << newpos
          break
        end
      else
        moves << newpos
      end
    end
    return moves
  end

  def diagonal_moves(board)
    #from position, move diagonally both ways until edge or occupied piece.
    #returns array of positions
    moves = []
    newpos = @position
    while LETTER_TO_NUM[newpos[0]] != '1' && newpos[1] != '1' do #MOVE DOWN-LEFT
      newpos = LETTER_TO_NUM.key(((LETTER_TO_NUM[newpos[0]].to_i)-1).to_s) + (newpos[1].to_i-1).to_s
      if board[newpos].piece
        if board[newpos].piece.colour == @colour
          break
        else
          moves << newpos
          break
        end
      else
        moves << newpos
      end
    end
    newpos = @position
    while LETTER_TO_NUM[newpos[0]] != '8' && newpos[1] != '8' do #MOVE UP-RIGHT
      newpos = LETTER_TO_NUM.key(((LETTER_TO_NUM[newpos[0]].to_i)+1).to_s) + (newpos[1].to_i+1).to_s
      if board[newpos].piece
        if board[newpos].piece.colour == @colour
          break
        else
          moves << newpos
          break
        end
      else
        moves << newpos
      end
    end
    newpos = @position
    while LETTER_TO_NUM[newpos[0]] != '1' && newpos[1] != '8' do #MOVE UP-LEFT
      newpos = LETTER_TO_NUM.key(((LETTER_TO_NUM[newpos[0]].to_i)-1).to_s) + (newpos[1].to_i+1).to_s
      if board[newpos].piece
        if board[newpos].piece.colour == @colour
          break
        else
          moves << newpos
          break
        end
      else
        moves << newpos
      end
    end 
    newpos = @position
    while LETTER_TO_NUM[newpos[0]] != '8' && newpos[1] != '1' do #MOVE DOWN-RIGHT
      newpos = LETTER_TO_NUM.key(((LETTER_TO_NUM[newpos[0]].to_i)+1).to_s) + (newpos[1].to_i-1).to_s
      if board[newpos].piece
        if board[newpos].piece.colour == @colour
          break
        else
          moves << newpos
          break
        end
      else
        moves << newpos
      end
    end
    return moves
  end
end

class Rook < Piece
  def initialize(pos, colour)
    @string = "\u265c"
    super
  end

  def allowed_moves(board)
    moves = []
    moves += horizontal_moves(board)
    moves += vertical_moves(board)
    return moves
  end
end

class Knight < Piece
  def initialize(pos, colour)
    @string = "\u265e"
    super
  end
end

class Pawn < Piece
  def initialize(pos, colour)
    @string = "\u265f"
    super
  end
end

class Bishop < Piece
  def initialize(pos, colour)
    @string = "\u265d"
    super
  end

  def allowed_moves(board)
    moves = []
    moves += diagonal_moves(board)
    return moves
  end
end

class Queen < Piece
  def initialize(pos, colour)
    @string = "\u265b"
    super
  end

  def allowed_moves(board)
    moves = []
    moves += horizontal_moves(board)
    moves += vertical_moves(board)
    moves += diagonal_moves(board)
    return moves
  end
end

class King < Piece
  def initialize(pos, colour)
    @string = "\u265a"
    super
  end
end
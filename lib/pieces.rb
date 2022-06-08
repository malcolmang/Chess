require_relative "constant"

def translateposition(pos, x, y)
  #pos is a letter and a number (a4, b5, etc)
  new_x = (LETTER_TO_NUM[pos[0]].to_i)+x
  new_y= (pos[1].to_i)+y
  if new_x < 1 || new_x > 8 || new_y < 1 || new_y > 8
    return nil
  else
    return LETTER_TO_NUM.key(new_x.to_s) + new_y.to_s
  end  
end 

class Piece
  attr_reader :colour
  attr_reader :string
  attr_accessor :position
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
      newpos = translateposition(newpos, -1, 0)
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
      newpos = translateposition(newpos, 1, 0)
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
    #p newpos
    while newpos[1] != '1' do #MOVE UP
      newpos = translateposition(newpos, 0, -1)
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
      newpos = translateposition(newpos, 0, 1)
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
      newpos = translateposition(newpos, -1, -1)
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
      newpos = translateposition(newpos, 1, 1)
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
      newpos = translateposition(newpos, -1, 1)
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
      newpos = translateposition(newpos, 1, -1)
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
  
  def allowed_moves(board)
    moves = []
    moves << translateposition(@position, 2, 1)
    moves << translateposition(@position, 2, -1)
    moves << translateposition(@position, -2, 1)
    moves << translateposition(@position, -2, -1)
    moves << translateposition(@position, 1, 2)
    moves << translateposition(@position, 1, -2)
    moves << translateposition(@position, -1, 2)
    moves << translateposition(@position, -1, -2)
    moves.each do |move|
      if board[move]
        if board[move].piece 
          if board[move].piece.colour == @colour
            moves.delete(move)
          end
        end
      end 
    end
    return moves
  end
end

class Pawn < Piece  #Moves up or down depending on black/white. If at original position, can move 2 steps. Can move diagonally if there are pieces there.
  attr_accessor :en_passant
  
  def initialize(pos, colour)
    @string = "\u265f"
    @en_passant = false
    super
  end

  def allowed_moves(board)
    moves = []
    if @colour == Foreground_Colour::WHITE
      if @position[1] == '2'
        moves << translateposition(@position, 0, 2)
      end
      if @position[1] != '8'
        if !board[translateposition(@position, 0, 1)].piece
          moves << translateposition(@position, 0, 1)
        end 
      end
      #left diagonal
      if @position[0] != 'a' && @position[1] != '8'
          if board[translateposition(@position, -1, 1)].piece
            if board[translateposition(@position, -1, 1)].piece.colour != @colour
              moves << translateposition(@position, -1, 1)
            end
          end
      end

      #right diagonal
      if @position[0] != 'h' && @position[1] != '8'
        if board[translateposition(@position, 1, 1)].piece
          if board[translateposition(@position, 1, 1)].piece.colour != @colour
            moves << translateposition(@position, 1, 1)
          end
        end
      end
    else
      if @position[1] == '7'
        @en_passant = true
        moves << translateposition(@position, 0, -2)
      end
      if @position[1] != '1'
        if !board[translateposition(@position, 0, -1)].piece
          moves << translateposition(@position, 0, -1)
        end 
      end
      #left diagonal
      if @position[0] != 'a' && @position[1] != '1'
          if board[translateposition(@position, -1, -1)].piece
            if board[translateposition(@position, -1, -1)].piece.colour != @colour
              moves << translateposition(@position, -1, -1)
            end
          end
      end

      #right diagonal
      if @position[0] != 'h' && @position[1] != '1'
        if board[translateposition(@position, 1, -1)].piece
          if board[translateposition(@position, 1, -1)].piece.colour != @colour
            moves << translateposition(@position, 1, -1)
          end
        end
      end
    end
      #holy hell!
      #if there is a pawn next to this one that has en_passant flag, allow capture to one vertical space behind it
      #-1 if black, 1 if white
      vertical = Foreground_Colour::BLACK == @colour ? -1 : 1
      puts "==============\nFor pawn at #{@position}\n======================="
        if @position[0] != 'a'
          if board[translateposition(@position, -1, 0)].piece
            puts "found a piece to the left of #{@position} at #{translateposition(@position, -1, 0)}"
            if board[translateposition(@position, -1, 0)].piece.string == "\u265f"
              puts "found a pawn to the left of #{@position} at #{translateposition(@position, -1, 0)}"
              if board[translateposition(@position, -1, 0)].piece.en_passant && board[translateposition(@position, -1, 0)].piece.colour != @colour
                puts "passant found?!?!"
                moves << translateposition(@position, -1, vertical)
              end
            end
          end
        end
        if @position[0] != 'h'
          if board[translateposition(@position, 1, 0)].piece
            puts "found a piece to the right of #{@position} at #{translateposition(@position, 1, 0)}"
            if board[translateposition(@position, 1, 0)].piece.string == "\u265f"
              puts "found a pawn to the right of #{@position} at #{translateposition(@position, 1, 0)}"
              if board[translateposition(@position, 1, 0)].piece.en_passant && board[translateposition(@position, 1, 0)].piece.colour != @colour
                puts "passant found?!?!"
                moves << translateposition(@position, 1, vertical)
              end
            end
          end
        end
    return moves
  end

  def threat_moves()
    moves = []
    if @colour == Foreground_Colour::WHITE
      #left diagonal
      if @position[0] != 'a' && @position[1] != '8'
        moves << translateposition(@position, -1, 1)
      end
      #right diagonal
      if @position[0] != 'h' && @position[1] != '8'
        moves << translateposition(@position, 1, 1)
      end
    else
      #left diagonal
      if @position[0] != 'a' && @position[1] != '1'
              moves << translateposition(@position, -1, -1)
      end
      #right diagonal
      if @position[0] != 'h' && @position[1] != '1'
        moves << translateposition(@position, 1, -1)
      end 
    end
    return moves
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

  def allowed_moves(board)
    moves = []
    moves << translateposition(@position, 1, 1)
    moves << translateposition(@position, 1, 0)
    moves << translateposition(@position, 1, -1)
    moves << translateposition(@position, 0, 1)
    moves << translateposition(@position, 0, -1)
    moves << translateposition(@position, -1, 1)
    moves << translateposition(@position, -1, 0)
    moves << translateposition(@position, -1, -1)
    moves.delete_if do |move|
      if board[move]
        if board[move].piece
          if board[move].piece.colour == @colour
            true
          else
            false
          end
        end
      else
        false
      end
    end
  end 
end
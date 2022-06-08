require_relative "pieces"
require_relative "constant"

module Background_Colour
  WHITE = 106
  BLACK = 100
  CAPTUREPOSSIBLE = 101 
  GREEN = 102
  PREVIOUSMOVE = 44
end

module Foreground_Colour
  WHITE = 97
  BLACK = 30
  HIGHLIGHT = 31   
end

module CellState
  DEFAULT = 0 
  POSSIBLE_PUSH = 1 #Can move
  POSSIBLE_CAPTURE = 2 #Can capture 
  SELECTION = 3 #Selected piece 
  PREVIOUSMOVE = 4 #Previous move
end

class Board
  attr_accessor :board
  def initialize(board = nil)
    if board == nil
      @board = createboard()
      @prevfrom = nil
      @prevto = nil
      placepieces()
      @realboard = true
    else 
      @board = board.dup
      @prevfrom = nil
      @prevto = nil
      @realboard = false
    end
  end

  def inbounds(pos)
    if pos[0] >= 'a' && pos[0] <= 'h' && pos[1] >= '1' && pos[1] <= '8'
      return true
    else
      return false
    end
  end

  def createboard()
    buffer_map = Hash.new()
    for number in ('1'..'8').reverse_each() do #the printing order - row first, then column, but rows are reversed
      for letter in 'a'..'h' do
        buffer_map[letter+number] = Cell.new(letter,number)
      end
    end
    return buffer_map
  end
  
  def account_for_check(originalpos ,moves, colour) #don't allow moves that would put the player in check, or moves must move king out of check
      originalcopy = self.dup
      movesnew = moves.dup
      moves.each do |newpos|
        boardcopy = Board.new(Marshal.load(Marshal.dump(originalcopy.board)))
        boardcopy.move(originalpos,newpos)
        #boardcopy.print_board()
        if check_for_check(colour,boardcopy.board)
          movesnew.delete(newpos)
        end
      end
    return movesnew
  end

  def selectpiece(position) #Selects a piece and highlights possible moves
    if @board[position].piece
      moves = @board[position].piece.allowed_moves(@board)
      #puts "moves: #{moves}"
    else
      moves = []
    end
    moves.delete_if {|pos| !@board[pos]}
    moves = account_for_check(position, moves, @board[position].piece.colour)
    if @realboard
      @board[position].state = CellState::SELECTION
      highlight_moves(moves)
    end
    return moves
  end 

  def all_allowed(position)
    if @board[position].piece
      moves = @board[position].piece.allowed_moves(@board)
    else
      moves = []
    end
    moves.delete_if {|pos| !@board[pos]}
    moves = account_for_check(position, moves, @board[position].piece.colour)
    return moves
  end

  def highlight_moves(moves)
    moves.each do |move|
      !@board[move].piece ? (@board[move].state = CellState::POSSIBLE_PUSH) : (@board[move].state = CellState::POSSIBLE_CAPTURE)
    end
  end

  def reset_highlights()
    @board.each do |key, cell|
      cell.state = CellState::DEFAULT
    end
    #highlight previous moves
    if @prevfrom && @prevto 
      @board[@prevfrom].state = CellState::PREVIOUSMOVE
      @board[@prevto].state = CellState::PREVIOUSMOVE
    end 
  end

  def move(position, newposition)
    #puts "moving from #{position} to #{newposition}"
    if @prevfrom && @prevto
      @board[@prevfrom].state = CellState::DEFAULT
      @board[@prevto].state = CellState::DEFAULT
    end
    @prevfrom = position
    @prevto = newposition
    @board[position].piece.moved = true
    if @board[position].piece.string == "\u265a" && @realboard #CASTLING
      #if king moves 2 steps, trigger castling flag
      if LETTER_TO_NUM[newposition[0]].to_i - LETTER_TO_NUM[position[0]].to_i == 2 && @realboard #castling to the right
        rookpos = 'h' + newposition[1]
        rooknewpos = 'f' + newposition[1]
        @board[rookpos].piece.position = rooknewpos
        @board[rooknewpos].piece = @board[rookpos].piece
        @board[rookpos].piece = nil
      elsif LETTER_TO_NUM[newposition[0]].to_i - LETTER_TO_NUM[position[0]].to_i == -2 && @realboard #castling to the left
        rookpos = 'a' + newposition[1]
        rooknewpos = 'd' + newposition[1]
        @board[rookpos].piece.position = rooknewpos
        @board[rooknewpos].piece = @board[rookpos].piece
        @board[rookpos].piece = nil
      end
    end
    #p @board.object_id
    #if pawn, check for promotion or en passant
    capturedpiece = @board[newposition].piece ? @board[newposition].piece.string : ""
    @board[newposition].piece = @board[position].piece
    @board[position].piece = nil
    @board[newposition].piece.position = newposition
    if @board[newposition].piece.string == "\u265f" 
      #if pawn moves 2 steps, trigger en passant flag
      if newposition[1].to_i - position[1].to_i == 2 || newposition[1].to_i - position[1].to_i == -2
        #puts "en passant for #{position} to #{newposition}"
        @board[newposition].piece.en_passant = true
      end

      #if pawn move was diagonal but there's no piece captured, en passant
      currentpiece = @board[newposition].piece
      if currentpiece.colour == Foreground_Colour::WHITE
        #holy hell!
        if position[0] != newposition[0] && capturedpiece == "" && position[1] != newposition[1]
          @board[translateposition(newposition,0,-1)].piece = nil
          capturedpiece = "\u265f"
        end
      else
        if position[0] != newposition[0] && capturedpiece == "" && position[1] != newposition[1]
          @board[translateposition(newposition,0,1)].piece = nil
          capturedpiece = "\u265f"
        end
      end
      #promotion 
      if newposition[1] == '8' || newposition[1] == '1'
        @board[newposition].piece = ask_promotion().new(newposition, @board[newposition].piece.colour)
      end
    end 

    
    return capturedpiece
  end

  def ask_promotion()
    if !@realboard
      return Pawn
    end
    puts "Promote to what? (Q/R/B/N)"
    input = gets.chomp.downcase
    while true
      if input == "q"
        return Queen
      elsif input == "r"
        return Rook
      elsif input == "b"
        return Bishop
      elsif input == "n"
        return Knight
      else
        puts "Invalid input"
      end
    end 
  end


  def placepieces() #Just for placing all pieces down in the initial position
    white = Foreground_Colour::WHITE
    black = Foreground_Colour::BLACK
    placepiece('a1', white, 'rook')
    placepiece('b1', white, 'knight')
    placepiece('c1', white, 'bishop') 
    placepiece('d1', white, 'queen') 
    placepiece('e1', white, 'king') #e1
    placepiece('f1', white, 'bishop')
    placepiece('g1', white, 'knight') 
    placepiece('h1', white, 'rook')
    placepiece('a2', white, 'pawn') 
    placepiece('b2', white, 'pawn')
    placepiece('c2', white, 'pawn')
    placepiece('d2', white, 'pawn')
    placepiece('e2', white, 'pawn')
    placepiece('f2', white, 'pawn')
    placepiece('g2', white, 'pawn')
    placepiece('h2', white, 'pawn')
    placepiece('a8', black, 'rook')
    placepiece('b8', black, 'knight')
    placepiece('c8', black, 'bishop')
    placepiece('d8', black, 'queen')
    placepiece('e8', black, 'king')
    placepiece('f8', black, 'bishop')
    placepiece('g8', black, 'knight')
    placepiece('h8', black, 'rook')
    placepiece('a7', black, 'pawn')
    placepiece('b7', black, 'pawn')
    placepiece('c7', black, 'pawn')
    placepiece('d7', black, 'pawn')
    placepiece('e7', black, 'pawn')
    placepiece('f7', black, 'pawn')
    placepiece('g7', black, 'pawn')
    placepiece('h7', black, 'pawn')
  end

  def placepiece(position, colour, piecename)
    case piecename
    when 'rook' 
      piece = Rook
    when 'queen'
      piece = Queen
    when 'knight'
      piece = Knight
    when 'bishop'
      piece = Bishop
    when 'pawn'
      piece = Pawn
    when 'king'
      piece = King
    end
    @board[position].piece = piece.new(position, colour)
  end

  def print_board()
    for number in ('1'..'8').reverse_each() do #the printing order - row first, then column, but rows are reversed
      outputstr = "#{number} "
      for letter in 'a'..'h' do
        outputstr += @board[letter+number].printcell()
      end
      puts outputstr
    end
    puts "   a  b  c  d  e  f  g  h "
  end

  def check_for_check(colour, board = @board)
    #puts "============================="
    #puts "Checking for check with board"
    #print_board()
    kingpos = nil
    #search for king
    board.each do |key, cell|
      if cell.piece && cell.piece.colour == colour && cell.piece.string == "\u265a"
        kingpos = key
      end
    end
    #puts "kingpos: #{kingpos}"
    #search for pieces that can attack king
    board.each do |key, cell|
      if cell.piece && cell.piece.colour != colour && cell.piece.string == "\u265f" && cell.piece.threat_moves().include?(kingpos) 
        #p "hello #{cell.piece.threat_moves()}"
        #puts "pawn check at #{key}"
        return true 
      else 
        if cell.piece && cell.piece.colour != colour && cell.piece.allowed_moves(board).include?(kingpos)
          #puts "check for #{cell.piece.string} at #{key}"
          return true
        end
      end 
    end
    return false
  end

  def checkmate?(colour)
    #invert colour 
    if colour == Foreground_Colour::WHITE
      colour = Foreground_Colour::BLACK
    else
      colour = Foreground_Colour::WHITE
    end
    #puts "============================="
    #puts "Checking for checkmate with board"
    #print_board()
    if check_for_check(colour)
      #print all possible moves
      board.each do |key, cell|
        if cell.piece && cell.piece.colour == colour
          #puts "=========="
          #puts "checking #{cell.piece.string} at #{key}"
          if !all_allowed(key).empty? 
            #puts "found move!"
            return false
          end
          all_allowed(key).each do |move|
            #puts "move:#{cell.piece.string} to #{move}"
          end
        end
      end
      return true
    end
  end

  def stalemate?(colour)
    #invert colour 
    if colour == Foreground_Colour::WHITE
      colour = Foreground_Colour::BLACK
    else
      colour = Foreground_Colour::WHITE
    end
    #puts "============================="
    #puts "Checking for stalemate with board"
    #print_board()
    #puts "Check"
    if @board.all? {|key, cell| cell.piece && cell.piece.colour == colour && all_allowed(key).empty?}
      return true
    end
    return false
  end

  def cleanse_en_passant(colour)
    #reverse colour 
    if colour == Foreground_Colour::WHITE
      colour = Foreground_Colour::BLACK
    else
      colour = Foreground_Colour::WHITE
    end
    #puts "cleansing en passant"
    for key in @board.keys()
      if @board[key].piece && @board[key].piece.colour == colour && @board[key].piece.string == "\u265f"
        @board[key].piece.en_passant = false
      end
    end
  end
end

class Cell
  attr_accessor :piece
  attr_accessor :state
  def initialize(letter,number)
    @position = letter+number
    @background_colour = determine_colour(@position)
    @state = CellState::DEFAULT
    @piece = nil
  end

  def printcell()
    if !@piece
      string = " "
      piece_colour = Foreground_Colour::HIGHLIGHT #Could be anything really - there's no colour
    else
      string = @piece.string
      piece_colour = @piece.colour
    end
    bg_colour = @background_colour
    if @state == CellState::POSSIBLE_PUSH
      string = "\u25CF"
    elsif @state == CellState::POSSIBLE_CAPTURE
      bg_colour = Background_Colour::CAPTUREPOSSIBLE
    elsif @state == CellState::SELECTION
      bg_colour = Background_Colour::GREEN
    elsif @state == CellState::PREVIOUSMOVE
      bg_colour = Background_Colour::PREVIOUSMOVE
    end

    return "\e[#{piece_colour};#{bg_colour}m #{string} \e[0m"
  end

  private 
  def determine_colour(pos)
    if LETTER_TO_NUM[pos[0]].to_i.even?  #a1 is black (letter not even, number not even)
      if pos[1].to_i.even?  
        return Background_Colour::BLACK
      else 
        return Background_Colour::WHITE
      end
    else 
      if pos[1].to_i.even?  
        return Background_Colour::WHITE
      else 
        return Background_Colour::BLACK
      end
    end
  end
end


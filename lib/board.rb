require_relative "pieces"
require_relative "constant"

module Background_Colour
  WHITE = 106
  BLACK = 100
  CAPTUREPOSSIBLE = 101
end

module Foreground_Colour
  WHITE = 97
  BLACK = 30
  HIGHLIGHT = 31
end

module CellState
  DEFAULT = 0
  POSSIBLE_PUSH = 1
  POSSIBLE_CAPTURE = 2
end

class Board
  def initialize
    @board = createboard()
    placepieces()
    printboard()
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

  def selectpiece(position)
    if @board[position].piece
      moves = @board[position].piece.allowed_moves(@board)
    else
      moves = []
    end
    highlight_moves(moves)
    printboard()
  end 

  def highlight_moves(moves)
    moves.each do |move|
      !@board[move].piece ? (@board[move].state = CellState::POSSIBLE_PUSH) : (@board[move].state = CellState::POSSIBLE_CAPTURE)
    end
  end


  def placepieces() #Just for placing all pieces down in the initial position
    white = Foreground_Colour::WHITE
    black = Foreground_Colour::BLACK
    placepiece('a1', white, 'rook')
    placepiece('b1', white, 'knight')
    placepiece('c1', white, 'bishop') 
    placepiece('d1', white, 'queen') 
    placepiece('e1', white, 'king')
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

  def printboard()
    puts "\n\n"
    for number in ('1'..'8').reverse_each() do #the printing order - row first, then column, but rows are reversed
      outputstr = "#{number} "
      for letter in 'a'..'h' do
        outputstr += @board[letter+number].printcell()
      end
      puts outputstr
    end
    puts "   a  b  c  d  e  f  g  h "
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


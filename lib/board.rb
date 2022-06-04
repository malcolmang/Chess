require_relative "pieces"

LETTER_TO_NUM = {'a'=> '1', 'b' => '2', 'c' => '3', 'd' => '4', 'e' => '5', 'f' => '6',
'g' => '7', 'h' => '8'}

module Colour
  WHITE = 100
  BLACK = 40
end

module CellState
  DEFAULT = 0
  POSSIBLE_PUSH = 46
end

class Board
  def initialize
    @board = createboard()
    placepieces()
    printboard()
  end

  private
  def createboard()
    buffer_map = Hash.new()
    for number in ('1'..'8').reverse_each() do #the printing order - row first, then column, but rows are reversed
      for letter in 'a'..'h' do
        buffer_map[letter+number] = Cell.new(letter,number)
      end
    end
    return buffer_map
  end

  def placepieces()
    @board['a1'].piece = Rook.new('a1', Colour::WHITE)
  end

  def printboard()
    puts "   a  b  c  d  e  f  g  h "
    for number in ('1'..'8').reverse_each() do #the printing order - row first, then column, but rows are reversed
      outputstr = "#{number} "
      for letter in 'a'..'h' do
        outputstr += @board[letter+number].printcell()
      end
      puts outputstr
    end
  end
end

class Cell
  attr_accessor :piece
  def initialize(letter,number)
    @position = letter+number
    @background_colour = determine_colour(@position)
    @state = CellState::DEFAULT
    @piece = nil
  end

  def printcell()
    if !@piece
      string = " "
    else
      string = @piece.string
    end

    if @state == CellState::DEFAULT
      bg_colour = @background_colour
    else 
      bg_colour = 100
    end
    return "\e[#{@piece_colour};#{bg_colour}m #{string} \e[0m"

  end

  private 
  def determine_colour(pos)
    if LETTER_TO_NUM[pos[0]].to_i.even?  #a1 is black (letter not even, number not even)
      if pos[1].to_i.even?  
        return Colour::BLACK
      else 
        return Colour::WHITE
      end
    else 
      if pos[1].to_i.even?  
        return Colour::WHITE
      else 
        return Colour::BLACK
      end
    end
  end
end

game = Board.new()
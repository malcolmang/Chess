require_relative "constant"
require_relative "board"
require_relative "pieces"

class Game 
  def initialize()
    @board = Board.new()
    @player = Foreground_Colour::WHITE
    @whitegains = ""
    @blackgains = ""
  end

  def print_screen()
    system("clear")
    system("cls")
    whichplayer = @player == Foreground_Colour::WHITE ? "White" : "Black"
    puts "Current Player: #{whichplayer}"
    puts "\n\n"
    puts "   " + "#{@blackgains}".chars.sort.join.reverse
    @board.print_board()
    puts "   " + "#{@whitegains}".chars.sort.join.reverse
    puts " "
  end

  def errormessagered(message)
    puts "\e[31m#{message}\e[0m"
    puts "\e[31mPress\e[0m" + " \e[1mENTER\e[22m" + "\e[31m to go back\e[0m"
    gets.chomp()
  end

  def choosepiece()
    while true #Selecting piece to move
      print_screen()
      puts "Please select the piece to move:"
      selectedpiece = gets.chomp()
      if selectedpiece.length != 2 
        errormessagered("Invalid input - please enter exactly 2 characters (a number and a letter)")
        next
      elsif !@board.inbounds(selectedpiece)
        errormessagered("Invalid input - please enter a valid position on the board")
        next
      elsif !@board.board[selectedpiece].piece
        errormessagered("Invalid input - there is no piece at that position")
        next
      elsif @board.board[selectedpiece].piece.colour != @player
        errormessagered("Invalid input - that piece is not yours")
        next
      else 
        valid_moves = @board.selectpiece(selectedpiece)
        if valid_moves.length == 0
          @board.board[selectedpiece].state = CellState::DEFAULT
          errormessagered("Invalid input - that piece cannot move")
          next
        else
          return selectedpiece, valid_moves
        end
      end
    end
  end

  def choosemove(moves)
    while true #Selecting move to make
      print_screen()
      puts "Please select the move to make (press b to go back):"
      selectedmove = gets.chomp()
      return "b" if selectedmove == "b"
      if selectedmove.length != 2
        errormessagered("Invalid input - please enter exactly 2 characters (a number and a letter)")
        next
      elsif !@board.inbounds(selectedmove)
        errormessagered("Invalid input - please enter a valid position on the board")
        next
      elsif !moves.include?(selectedmove)
        errormessagered("Invalid input - that is not a valid move")
        next
      else
        return selectedmove #MAKE MOVE
      end
    end
  end

  def update_board
  end

  def turn()
    while true
      position, moves = choosepiece()
      selectedmove = choosemove(moves)
      if selectedmove == "b"
        @board.reset_highlights()
        next
      else
        (@player == Foreground_Colour::WHITE ? @whitegains +=@board.move(position, selectedmove) : @blackgains+=@board.move(position, selectedmove)) 
        @board.reset_highlights()
        @player = @player == Foreground_Colour::WHITE ? Foreground_Colour::BLACK : Foreground_Colour::WHITE
      end
      update_board()
    end #end of turn loop
  end
end
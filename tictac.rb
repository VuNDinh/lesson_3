require 'pry'

PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
INITIAL_MARKER = ' '
USERS = ['Player', 'Computer']
WINNING_COMBOS = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                 [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                 [[1, 5, 9], [3, 5, 7]]

def prompt(msg)
  puts "=> #{msg}"
end

def blank_line
  puts "\n"
end

# rubocop: disable Metrics/AbcSize
def display_board(board)
  system 'clear'

  puts "     |     |     "
  puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}  "
  puts "     |     |     "
end
# rubocop: enable Metrics/AbcSize

def board_moves
  squares = {}

  (1..9).each { |num| squares[num] = ' ' }

  squares
end

def empty_squares(board)
  board.keys.select { |sqr| board[sqr] == INITIAL_MARKER }
end

def joinor(array, delimiter = ', ', word = 'or')
  case array.size
  when 0 then ''
  when 1 then array.first.to_s
  when 2 then array.join(" #{word} ")
  else
    array[-1] = "#{word} #{array[-1]}"
    array.join(delimiter)
  end
end

def player_turn!(board)
  player_choice = ''

  loop do
    prompt("Please select a square: #{joinor(empty_squares(board))}")
    player_choice = gets.chomp.to_i

    break if empty_squares(board).include?(player_choice)
    prompt("Please enter a valid square.")
  end

  board[player_choice] = PLAYER_MARKER
end

def computer_turn!(board)
  computer_choice = if computer_moves(board, COMPUTER_MARKER) # offense
                      computer_moves(board, COMPUTER_MARKER)
                    elsif computer_moves(board, PLAYER_MARKER) # defense
                      computer_moves(board, PLAYER_MARKER)
                    elsif board[5] == INITIAL_MARKER
                      5
                    else
                      empty_squares(board).sample
                    end

  board[computer_choice] = COMPUTER_MARKER
end

def computer_moves(board, marker)
  square = []

  WINNING_COMBOS.each do |line|
    if board.values_at(*line).count(marker) == 2
      line.each do |sqr|
        square << sqr if board[sqr] == INITIAL_MARKER
      end
    end
  end

  return nil if square.empty?
  square.first
end

def computer_decision
  USERS.sample
end

def game_flow(user, board)
  user == 'Player' ? player_first(board) : computer_first(board)
end

def player_first(board)
  loop do
    player_turn!(board)
    display_board(board)
    break if someone_won?(board) || board_full?(board)

    computer_turn!(board)
    display_board(board)
    break if someone_won?(board) || board_full?(board)
  end
end

def computer_first(board)
  loop do
    computer_turn!(board)
    display_board(board)
    break if someone_won?(board) || board_full?(board)

    player_turn!(board)
    display_board(board)
    break if someone_won?(board) || board_full?(board)
  end
end

def detect_winner(board)
  WINNING_COMBOS.each do |line|
    if board.values_at(*line).count(PLAYER_MARKER) == 3
      return USERS[0]
    elsif board.values_at(*line).count(COMPUTER_MARKER) == 3
      return USERS[1]
    end
  end
  nil
end

def someone_won?(board)
  !!detect_winner(board)
end

def board_full?(board)
  empty_squares(board).empty?
end

def update_score!(board, scoreboard)
  if detect_winner(board) == USERS[0]
    scoreboard[USERS[0]] += 1
  elsif detect_winner(board) == USERS[1]
    scoreboard[USERS[1]] += 1
  else
    scoreboard['Tie'] += 1
  end
end

def display_score(scoreboard)
  score = <<~MSG
  SCOREBOARD
  Player: #{scoreboard[USERS[0]]}
  Computer: #{scoreboard[USERS[1]]}
  Tie: #{scoreboard['Tie']}
  MSG

  puts score
end

def display_rules
  rules = <<~MSG
  Welcome to Tic-Tac-Toe!
  Here are the rules for the game:
  1) The game is played on a 3x3 board
  2) Player is 'X' and computer is 'O'
  3) First player to reach 3 marks (row, column, or diagonal) wins
  4) First player to reach 5 wins is the grand winner
  5) Enjoy the game!
  MSG

  puts rules
  sleep(6)
end

def display_who_first(user)
  prompt("Let's see who is going first...")
  sleep(2)
  prompt("#{user} will go first!")
  sleep(3)
end

def display_winner(board)
  if someone_won?(board)
    prompt("#{detect_winner(board)} won!")
  else
    prompt("It's a tie!")
  end
end

# MAIN GAME
system 'clear'
display_rules
system 'clear'

loop do
  scoreboard = {
    'Player' => 0,
    'Computer' => 0,
    'Tie' => 0
  }
  loop do
    moves = board_moves
    user_go_first = computer_decision

    display_who_first(user_go_first)
    display_board(moves)

    game_flow(user_go_first, moves)

    display_winner(moves)
    blank_line
    update_score!(moves, scoreboard)
    display_score(scoreboard)
    sleep(3)
    system 'clear'

    break if scoreboard[USERS[0]] == 5 || scoreboard[USERS[1]] == 5
  end

  system 'clear'

  display_score(scoreboard)
  blank_line
  grand_winner = scoreboard.key(5)
  prompt("#{grand_winner} is the grand winner!")

  prompt("Do you want to play again? (y/n)")
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
  system 'clear'
end

prompt("Thank you for playing Tic-Tac-Toe!")

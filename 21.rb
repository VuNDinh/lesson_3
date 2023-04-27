require 'pry'

CARDS = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
SUITS = ['Heart', 'Diamond', 'Club', 'Spade']
USERS = ['Player', 'Computer']
TARGET_NUM = 21
DEALER_NUM_TO_STAY = 17
VALID_INPUTS = ['hit', 'h', 'stay', 's']

def prompt(msg)
  puts "=> #{msg}"
end

def freeze_screen(second)
  sleep(second)
end

def clear_screen
  system 'clear'
end

def blank_line
  puts "\n"
end

def initialize_deck
  CARDS.product(SUITS).shuffle
end

def initialize_scoreboard
  {
    'Player' => 0,
    'Dealer' => 0,
    'Tie' => 0
  }
end

def deal_card!(deck)
  case deck.size
  when 49..52 then deck.pop(2)
  else deck.pop
  end
end

def display_beginning_hand(hand)
  current_cards = value_and_suit(hand)
  prompt("Dealer showing: #{current_cards.first} and unknown card")
end

# rubocop: disable Style/ConditionalAssignment
def calculate_total(hand)
  cards_to_calculate = hand.map(&:first)

  total = 0
  cards_to_calculate.each do |card|
    if CARDS[-3, 3].include?(card)
      total += 10
    elsif card[0] == 'A'
      total += 11
    else
      total += card.to_i
    end
  end

  cards_to_calculate.select { |value| value.start_with?('A') }.count.times do
    total -= 10 if total > TARGET_NUM
  end

  total
end
# rubocop: enable Style/ConditionalAssignment

def joinand(array, delimiter = ', ')
  case array.size
  when 2 then array.join(' and ')
  else
    array[-1] = 'and ' + array[-1]
    array.join(delimiter)
  end
end

def value_and_suit(hand)
  hand.map { |sub_arr| sub_arr.join(' of ') }
end

def stay?(input)
  VALID_INPUTS[-2, 2].include?(input)
end

def hit_or_stay
  answer = ''

  loop do
    prompt("Do you want to (h)it or (s)tay?")
    answer = gets.chomp
    break if VALID_INPUTS.include?(answer)
    prompt("Please input a valid choice.")
  end

  answer
end

def get_player_total(deck, hand)
  total_on_hand = calculate_total(hand)

  loop do
    current_cards = value_and_suit(hand)
    display_cards(joinand(current_cards), total_on_hand, 'Player')
    break if total_on_hand >= TARGET_NUM
    answer = hit_or_stay
    break if stay?(answer)

    card_received = deal_card!(deck)
    prompt("You received: #{card_received.join(' of ')}")
    hand << card_received

    total_on_hand = calculate_total(hand)
    freeze_screen(2)
  end

  total_on_hand
end

def display_cards(hand, total, user)
  if user == 'Player'
    prompt("You have: #{hand}")
    prompt("Your total: #{total}")
  else
    prompt("Dealer showing: #{hand}")
    prompt("Dealer total: #{total}")
  end
end

def get_dealer_total(deck, hand)
  total_on_hand = calculate_total(hand)
  beginning_hand = hand.map(&:first)
  display_cards(joinand(beginning_hand), total_on_hand, 'Dealer')

  while total_on_hand < DEALER_NUM_TO_STAY
    freeze_screen(2)
    prompt("Dealer hit")
    card_received = deal_card!(deck)
    hand << card_received
    freeze_screen(2)
    prompt("Dealer received: #{card_received.join(' of ')}")
    freeze_screen(2)
    total_on_hand = calculate_total(hand)
    prompt("Dealer total: #{total_on_hand}")
  end

  total_on_hand
end

def busted?(total)
  total > TARGET_NUM
end

def update_score!(scoreboard, user)
  scoreboard[user] += 1
end

def found_grand_winner?(scoreboard)
  !!grand_winner(scoreboard)
end

def grand_winner(scoreboard)
  scoreboard.key(2)
end

def display_score(scoreboard)
  clear_screen

  score = <<~MSG
  SCOREBOARD
  Player: #{scoreboard['Player']}
  Dealer: #{scoreboard['Dealer']}
  Tie: #{scoreboard['Tie']}
  MSG

  puts score
end

def display_deck_shuffling(msg)
  horizontal = "+#{'-' * (msg.size + 2)}+"
  veritcal = "|#{' ' * (msg.size + 2)}|"

  puts horizontal
  puts veritcal
  puts "| #{msg} |"
  puts veritcal
  puts horizontal
end

def display_bust_or_stay(total, user)
  if busted?(total)
    prompt("#{user.capitalize} busted with #{total}.")
  else
    prompt("#{user.capitalize} stayed at: #{total}")
  end
end

def display_winner(winner)
  case winner
  when 'Player' then prompt("You win!")
  when 'Dealer' then prompt("Dealer win!")
  else prompt("It's a tie!")
  end
end

def display_grand_winner(scoreboard)
  prompt("#{grand_winner(scoreboard)} is the grand winner!")
end

def detect_winner(player, dealer)
  if player > 21
    'Dealer'
  elsif dealer > 21
    'Player'
  elsif player > dealer
    'Player'
  elsif dealer > player
    'Dealer'
  else
    'Tie'
  end
end

def display_rules
  clear_screen

  rules = <<~MSG
  Welcome to Twenty-One!
  - You will be playing against a dealer
  - Two cards will be dealt in the beginning
  - You can only see one card from the dealer until your turn ended
  - The goal is to get to 21
  - If you bust (over 21), dealer win
  - If the dealer bust, you win
  - If no one bust, the player with the higher total will win
  - First player to win five rounds is the grand winner
  MSG

  puts rules
  freeze_screen(10)
  clear_screen
end

def display_degreeting
  prompt("Thank you for playing Twenty-One!")
end

def display_separator
  puts "========================="
end

def play_again?
  puts "========================="
  prompt("Do you want to play again?")
  answer = gets.chomp
  answer.downcase.start_with?('n')
end

# MAIN GAME
display_rules

loop do
  scoreboard = initialize_scoreboard

  loop do
    deck = initialize_deck
    player_hand = deal_card!(deck)
    dealer_hand = deal_card!(deck)
    player_total = 0
    dealer_total = 0

    clear_screen
    display_deck_shuffling('SHUFFLING DECK')
    freeze_screen(3)
    clear_screen
    display_beginning_hand(dealer_hand)
    freeze_screen(2)

    loop do
      player_total = get_player_total(deck, player_hand)
      display_bust_or_stay(player_total, 'player')
      display_separator
      break if busted?(player_total)

      freeze_screen(2)
      dealer_total = get_dealer_total(deck, dealer_hand)
      freeze_screen(2)
      display_bust_or_stay(dealer_total, 'dealer')
      display_separator
      freeze_screen(2)

      break
    end

    winner = detect_winner(player_total, dealer_total)
    display_winner(winner)
    update_score!(scoreboard, winner)
    freeze_screen(3)
    display_score(scoreboard)
    freeze_screen(3)

    break if found_grand_winner?(scoreboard)
  end

  display_score(scoreboard)
  blank_line
  display_grand_winner(scoreboard)

  break if play_again?
end

display_degreeting

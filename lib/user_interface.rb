class UserInterface
  def initialize(io, game)
    @io = io
    @game = game
    @player = 1
  end

  def run
    show "Welcome to the game!"
    players = prompt "1 or 2 players?"
    if players == "1"
      show "Set up your ships first."
      while @game.unplaced_ships != []
        show "You have these ships remaining: #{ships_unplaced_message}"
        prompt_for_ship_placement
      end
      choice = ""
      while choice != "exit"
        choice = decision
      end

    elsif players == "2"
      show "Player1 set up your ships"
      while @game.unplaced_ships != []
        show "You have these ships remaining: #{ships_unplaced_message}"
        prompt_for_ship_placement
      end
      show "Player2 set up your ships"
      while @game.unplaced_ships2 != []
        show "You have these ships remaining: #{ships_unplaced_message2}"
        prompt_for_ship_placement2
      end
      choice = ""
      while choice != "exit"
        choice = decision2
      end
    else
      show "1-2 players only please"
    end
  end

  private

  def show(message)
    @io.puts(message)
  end

  def prompt(message)
    @io.puts(message)
    return @io.gets.chomp
  end

  def ships_unplaced_message
    return @game.unplaced_ships.map do |ship|
      "#{ship.length}"
    end.join(", ")
  end

  def ships_unplaced_message2
    return @game.unplaced_ships2.map do |ship|
      "#{ship.length}"
    end.join(", ")
  end

  def prompt_for_ship_placement
    ship_length = prompt "Which do you wish to place?"
    ship_orientation = prompt "Vertical or horizontal? [vh]"
    ship_row = prompt "Which row?"
    ship_col = prompt "Which column?"
    show "OK."
    if ship_orientation.match?(/^v$|^h$/) == true
      okay = @game.place_ship({
      length: ship_length.to_i,
      orientation: {"v" => :vertical, "h" => :horizontal}.fetch(ship_orientation),
      row: ship_row.to_i,
      col: ship_col.to_i
      }
      )
    else
      okay = 0
    end

    
    if okay == nil
      show "Please enter a valid position"
    elsif okay == 0
      show "Please enter a valid orientation"
    elsif okay == 1
      show "Please enter a valid ship"
    else
      show "This is your board now:"
      show format_board
    end
  end

  def prompt_for_ship_placement2
    ship_length = prompt "Which do you wish to place?"
    ship_orientation = prompt "Vertical or horizontal? [vh]"
    ship_row = prompt "Which row?"
    ship_col = prompt "Which column?"
    show "OK."
    if ship_orientation.match?(/^v$|^h$/) == true
      okay = @game.place_ship2({
      length: ship_length.to_i,
      orientation: {"v" => :vertical, "h" => :horizontal}.fetch(ship_orientation),
      row: ship_row.to_i,
      col: ship_col.to_i
      }
      )
    else
      okay = 0
    end

    
    if okay == nil
      show "Please enter a valid position"
    elsif okay == 0
      show "Please enter a valid orientation"
    elsif okay == 1
      show "Please enter a valid ship"
    else
      show "This is your board now:"
      show format_enemy
    end
  end

  def decision
    choice = prompt "Would you like to shoot, see the board, see the enemy board or exit?"
    if choice == "exit"
      return exit
    elsif choice == "see the board"
      show "Here is the board:"
      show format_board
    elsif choice == "shoot"
      check = prompt_for_shooting_ship
      if check != "please enter valid co-ordinates"
        show format_firing
        enemy_fire
      end
    elsif choice == "see the enemy board"
      show "Here is the enemy board:"
      show format_firing
    elsif choice == "enemy"
      show format_enemy
    elsif choice == "hitme"
      enemy_hit
    end
  end

  def decision2
    if @player == 1
      choice = prompt "Player1, would you like to shoot, see the board, see the enemy board or exit?"
      if choice == "exit"
        return exit
      elsif choice == "see the board"
        show "Here is the board:"
        show format_board
      elsif choice == "shoot"
        check = prompt_for_shooting_ship
        if check != "please enter valid co-ordinates"
          show format_firing
          @player = 2
        end
      elsif choice == "see the enemy board"
        show "Here is the enemy board:"
        show format_firing
      end

    elsif @player == 2
      choice = prompt "Player2, would you like to shoot, see the board, see the enemy board or exit?"
      if choice == "exit"
        return exit
      elsif choice == "see the board"
        show "Here is the board:"
        show format_enemy
      elsif choice == "shoot"
        check = prompt_for_shooting_ship2
        if check != "please enter valid co-ordinates"
          show format_firing2
          @player = 1
        end
      elsif choice == "see the enemy board"
        show "Here is the enemy board:"
        show format_firing2
      end
    end
  end

  def prompt_for_shooting_ship
    ship_row = prompt "Which row?"
    ship_col = prompt "Which column?"
    show "OK."
    if ship_row.to_i > 0 && ship_row.to_i < 11 && ship_col.to_i > 0 && ship_col.to_i < 11
      outcome = @game.shoot_ship(ship_row.to_i, ship_col.to_i)
      show outcome
    else
      show "please enter valid co-ordinates"
      return "please enter valid co-ordinates"
    end
  end

  def prompt_for_shooting_ship2
    ship_row = prompt "Which row?"
    ship_col = prompt "Which column?"
    show "OK."
    if ship_row.to_i > 0 && ship_row.to_i < 11 && ship_col.to_i > 0 && ship_col.to_i < 11
      outcome = @game.shoot_ship2(ship_row.to_i, ship_col.to_i)
      show outcome
    else
      show "please enter valid co-ordinates"
      return "please enter valid co-ordinates"
    end
  end

  def enemy_fire
    outcome = @game.enemy_fire
    if outcome[2] == 1
      show "The enemy has fired at row #{outcome[0]} column #{outcome[1]} and hit"
      show format_board
    elsif outcome[2] == 2
      show "The enemy has fired at row #{outcome[0]} column #{outcome[1]} and sunk your ship"
      show format_board
    else
      show "The enemy has fired at row #{outcome[0]} column #{outcome[1]} and missed"
    end
  end

  def enemy_hit
    outcome = @game.enemy_fire(1)
    if outcome[2] == 1
      show "The enemy has fired at row #{outcome[0]} column #{outcome[1]} and hit"
      show format_board
    elsif outcome[2] == 2
      show "The enemy has fired at row #{outcome[0]} column #{outcome[1]} and sunk your ship"
      show format_board
    else
      show "The enemy has fired at row #{outcome[0]} column #{outcome[1]} and missed"
    end
  end

  def format_board
    return (1..@game.rows).map do |y|
      (1..@game.cols).map do |x|
        next "S" if @game.ship_at?(x, y)
        next "X" if @game.shot_at?(x, y)
        next "."
      end.join
    end.join("\n")
  end

  def format_enemy
    return (1..@game.rows).map do |y|
      (1..@game.cols).map do |x|
        next "S" if @game.enemy_ship_at?(x, y)
        next "X" if @game.enemy_shot_at?(x, y)
        next "."
      end.join
    end.join("\n")
  end

  def format_firing
    return (1..@game.rows).map do |y|
      (1..@game.cols).map do |x|
        next "X" if @game.firing_hit_at?(x, y)
        next "O" if @game.firing_miss_at?(x, y)
        next "."
      end.join
    end.join("\n")
  end

  def format_firing2
    return (1..@game.rows).map do |y|
      (1..@game.cols).map do |x|
        next "X" if @game.firing_hit_at2?(x, y)
        next "O" if @game.firing_miss_at2?(x, y)
        next "."
      end.join
    end.join("\n")
  end
end
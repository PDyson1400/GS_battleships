require "ship"

class Game
  def initialize(rows, col, shiparr, enemyarr)
    @rows = rows
    @col = col
    @shiparr = shiparr.clone
    @enemyarr = enemyarr.clone
    @enemyships = @enemyarr.clone
    @playerships = @shiparr.clone
    @board = ""
    col.times{@board += "." * rows + "\n"}
    @enemy = ""
    col.times{@enemy += "." * rows + "\n"}
    @firingboard = ""
    col.times{@firingboard += "." * rows + "\n"}
    @firingboard2 = ""
    col.times{@firingboard2 += "." * rows + "\n"}
    @tag = 0
    @enemyshoot = []
    @enemyai = 0
    @lasthit = []
    @cardinalhit = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    @cardinalcurrent = @cardinalhit.clone
    @return = 1
    while @enemyarr != []
      hash = {
        length: @enemyarr[0].length,
        orientation: [:vertical, :horizontal].sample,
        row: rand(1..@rows),
        col: rand(1..@col)
      }
      enemy_place(hash)
    end
  end

  def unplaced_ships
    return @shiparr
  end

  def unplaced_ships2
    if @tag == 0
      @enemy = ""
      @col.times{@enemy += "." * rows + "\n"}
      @enemyarr = @enemyships.clone

      @enemyarr.map{|ship| ship.coclear}

      @tag = 1
    end
    return @enemyarr
  end

  def rows
    return @rows
  end

  def cols
    return @col
  end

  def marray_sub(arr1, arr2)
    arr = []
    arr.push(arr1[0] - arr2[0])
    arr.push(arr1[1] - arr2[1])
    return arr
  end

  def place_ship(shiphash)
    ships = []
    @shiparr.each{|ship| ships.push(ship.length)}
    if !ships.include?(shiphash[:length])
      return 1
    end

    clear = clear_line(shiphash[:col], shiphash[:row], shiphash[:orientation], shiphash[:length])
    if shiphash[:row] <= 0 || shiphash[:col] <= 0 || clear == false
      return nil
    end

    arr = @board.split("\n")
    i = 0
    if shiphash[:orientation] == :vertical && (shiphash[:row] + shiphash[:length] <= @rows) && 
      shiphash[:length].times{
        arr[shiphash[:row] - 1 + i][shiphash[:col] - 1] = "S"

        currentsh = @shiparr.filter{|ship| ship.length == shiphash[:length]}[0]
        currentsh.coadd([shiphash[:row] + i, shiphash[:col]])
        i += 1
      }
    elsif shiphash[:orientation] == :horizontal && (shiphash[:col] + shiphash[:length] <= @col)
      shiphash[:length].times{
        arr[shiphash[:row] - 1][shiphash[:col] - 1 + i] = "S"

        currentsh = @shiparr.filter{|ship| ship.length == shiphash[:length]}[0]
        currentsh.coadd([shiphash[:row], shiphash[:col] + i])
        i += 1
      }
    else
      return nil
    end
    
    @shiparr.filter!{|ship| ship.length != shiphash[:length]}

    return @board = arr.join("\n")
  end

  def place_ship2(shiphash)

    ships = []
    @enemyarr.each{|ship| ships.push(ship.length)}
    if !ships.include?(shiphash[:length])
      return 1
    end

    clear = enemy_clear_line(shiphash[:col], shiphash[:row], shiphash[:orientation], shiphash[:length])
    if shiphash[:row] <= 0 || shiphash[:col] <= 0 || clear == false
      return nil
    end

    arr = @enemy.split("\n")
    i = 0
    if shiphash[:orientation] == :vertical && (shiphash[:row] + shiphash[:length] <= @rows) && 
      shiphash[:length].times{
        arr[shiphash[:row] - 1 + i][shiphash[:col] - 1] = "S"

        currentsh = @enemyarr.filter{|ship| ship.length == shiphash[:length]}[0]
        currentsh.coadd([shiphash[:row] + i, shiphash[:col]])
        i += 1
      }
    elsif shiphash[:orientation] == :horizontal && (shiphash[:col] + shiphash[:length] <= @col)
      shiphash[:length].times{
        arr[shiphash[:row] - 1][shiphash[:col] - 1 + i] = "S"

        currentsh = @enemyarr.filter{|ship| ship.length == shiphash[:length]}[0]
        currentsh.coadd([shiphash[:row], shiphash[:col] + i])
        i += 1
      }
    else
      return nil
    end
    
    @enemyarr.filter!{|ship| ship.length != shiphash[:length]}

    return @enemy = arr.join("\n")
  end

  def enemy_place(shiphash)
    clear = enemy_clear_line(shiphash[:col], shiphash[:row], shiphash[:orientation], shiphash[:length])
    if clear == false
      return nil
    end

    arr = @enemy.split("\n")
    i = 0
    if shiphash[:orientation] == :vertical && (shiphash[:row] + shiphash[:length] <= @rows)
      shiphash[:length].times{
        arr[shiphash[:row] - 1 + i][shiphash[:col] - 1] = "S"

        currentsh = @enemyarr.filter{|ship| ship.length == shiphash[:length]}[0]
        currentsh.coadd([shiphash[:row] + i, shiphash[:col]])
        i += 1
      }
    elsif shiphash[:orientation] == :horizontal && (shiphash[:col] + shiphash[:length] <= @col)
      shiphash[:length].times{
        arr[shiphash[:row] - 1][shiphash[:col] - 1 + i] = "S"
        
        currentsh = @enemyarr.filter{|ship| ship.length == shiphash[:length]}[0]
        currentsh.coadd([shiphash[:row], shiphash[:col] + i])
        i += 1
      }
    else
      return nil
    end
    
    @enemyarr.filter!{|ship| ship.length != shiphash[:length]}

    return @enemy = arr.join("\n")
  end

  def enemy_fire(hit=0)
    if hit == 0
      firerow = -1
      firecol = -1

      if @enemyai == 0
        loop do
          firerow = rand(1..@rows)
          firecol = rand(1..@col)
    
          break if !@enemyshoot.include?([firerow, firecol])
        end
      elsif @enemyai == 1
        loop do
          origin = @lasthit[0]
          append = @cardinalcurrent.sample
          @cardinalcurrent.filter!{|arr| arr != append}

          firerow = origin[0] + append[0]
          firecol = origin[1] + append[1]

          break if firerow > 0 && firecol > 0 && firerow < 11 && firecol < 11
        end
      elsif @enemyai == 2
        origin = @lasthit[0]
        append = marray_sub(@lasthit.last, @lasthit[0])
        pos = append.index{|num| num != 0}

        if (pos == 0 && (origin[0] + @return <= 0 || origin[0] + @return >= 11)) || (pos == 1 && (origin[1] + @return <= 0 && origin[1] + @return >= 11))
          @return *= -1
        end

        loop do
          if @return > 0 && pos == 0
            firerow = origin[0] + @return
            firecol = origin[1]
            @return += 1
          elsif @return > 0 && pos == 1
            firerow = origin[0]
            firecol = origin[1] + @return
            @return += 1
          elsif @return < 0 && pos == 0
            firerow = origin[0] + @return
            firecol = origin[1]
            @return -= 1
          elsif @return < 0 && pos == 1
            firerow = origin[0]
            firecol = origin[1] + @return
            @return -= 1
          end

          break if shot_at?(firecol, firerow) == false
        end
      end
    else
      ship = @playerships.sample
      coord = ship.coord.sample
      firerow = coord[0]
      firecol = coord[1]
    end

    @enemyshoot.push([firerow, firecol])
    status = 0

    if ship_at?(firecol, firerow)
      arr = @board.split("\n")
      arr[firerow - 1][firecol - 1] = "X"
      @board = arr.join("\n")
      status = 1

      target = @playerships.filter{|ship| ship.coord.include?([firerow, firecol])}[0]
      target.coord.filter!{|arr| arr != [firerow, firecol]}

      if @lasthit == []
        @enemyai = 1
      else
        @enemyai = 2
      end

      @lasthit.push([firerow, firecol])

      if target.coord == []
        @playerships.filter!{|ship| ship != target}
        @lasthit = []
        @enemyai = 0
        @cardinalcurrent = @cardinalhit.clone
        @return = 1
        if @playerships == []
          abort("you have lost the game")
        else
          status = 2
        end
      end
    else
      if @enemyai == 2
        @return = -1
      end
    end

    return [firerow, firecol, status]
  end

  def shoot_ship(row, col)
    if enemy_ship_at?(col, row)
      arr = @enemy.split("\n")
      arr[row - 1][col - 1] = "X"
      @enemy = arr.join("\n")

      firing = @firingboard.split("\n")
      firing[row - 1][col - 1] = "X"
      @firingboard = firing.join("\n")

      target = @enemyships.filter{|ship| ship.coord.include?([row, col])}[0]
      target.coord.filter!{|arr| arr != [row, col]}
      if target.coord == []
        @enemyships.filter!{|ship| ship != target}
        if @enemyships == []
          abort("you have won the game")
        else
          return "hit, ship sunk"
        end
      else
        return "hit"
      end
    else
      firing = @firingboard.split("\n")
      firing[row - 1][col - 1] = "O"
      @firingboard = firing.join("\n")
      return "miss"
    end
  end

  def shoot_ship2(row, col)
    if ship_at?(col, row)
      arr = @board.split("\n")
      arr[row - 1][col - 1] = "X"
      @board = arr.join("\n")

      firing = @firingboard2.split("\n")
      firing[row - 1][col - 1] = "X"
      @firingboard2 = firing.join("\n")

      target = @playerships.filter{|ship| ship.coord.include?([row, col])}[0]
      target.coord.filter!{|arr| arr != [row, col]}
      if target.coord == []
        @playerships.filter!{|ship| ship != target}
        if @playerships == []
          abort("you have won the game")
        else
          return "hit, ship sunk"
        end
      else
        return "hit"
      end
    else
      firing = @firingboard2.split("\n")
      firing[row - 1][col - 1] = "O"
      @firingboard2 = firing.join("\n")
      return "miss"
    end
  end

  def ship_at?(x, y)
    arr = @board.split("\n")
    arr[y - 1][x - 1] == "S" ? true : false
  end

  def shot_at?(x, y)
    arr = @board.split("\n")
    arr[y - 1][x - 1] == "X" ? true : false
  end

  def enemy_ship_at?(x, y)
    arr = @enemy.split("\n")
    arr[y - 1][x - 1] == "S" ? true : false
  end

  def enemy_shot_at?(x, y)
    arr = @enemy.split("\n")
    arr[y - 1][x - 1] == "X" ? true : false
  end

  def firing_hit_at?(x, y)
    arr = @firingboard.split("\n")
    arr[y - 1][x - 1] == "X" ? true : false
  end

  def firing_hit_at2?(x, y)
    arr = @firingboard2.split("\n")
    arr[y - 1][x - 1] == "X" ? true : false
  end

  def firing_miss_at?(x, y)
    arr = @firingboard.split("\n")
    arr[y - 1][x - 1] == "O" ? true : false
  end

  def firing_miss_at2?(x, y)
    arr = @firingboard2.split("\n")
    arr[y - 1][x - 1] == "O" ? true : false
  end

  def clear_line(col, row, dir, length)
    if (col + length > @col && dir == :horizontal) || (row + length > @rows && dir == :vertical)
      return false
    end

    i = 0
    count = 0
    if dir == :vertical
      length.times {if ship_at?(col, row + i) == false
                      count += 1
                    end
                    i += 1
                    }
    elsif dir == :horizontal
      length.times {if ship_at?(col + i, row) == false
                      count += 1
                    end
                    i += 1
                    }
    end

    if count == length
      return true
    else
      return false
    end
  end
  
  def enemy_clear_line(col, row, dir, length)
    if (col + length > @col) || (row + length > @rows)
      return false
    end

    i = 0
    count = 0
    if dir == :vertical
      length.times {if enemy_ship_at?(col, row + i) == false
                      count += 1
                    end
                    i += 1
                    }
    elsif dir == :horizontal
      length.times {if enemy_ship_at?(col + i, row) == false
                      count += 1
                    end
                    i += 1
                    }
    end

    if count == length
      return true
    else
      return false
    end
  end
end

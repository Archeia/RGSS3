#===============================================================================
# TheoAllen - Conway's Game of Life
# Version : 1.0
# Language : English
#===============================================================================
# *) Introduction :
#-------------------------------------------------------------------------------
# This is an implementation of Conway's Game of Life in RGSS3 due to my boredom
# lol. Here are the following rules
#
# 1. Any live cell with fewer than two live neighbours dies, as if caused by 
#    under-population.
# 2. Any live cell with two or three live neighbours lives on to the next 
#    generation.
# 3. Any live cell with more than three live neighbours dies, as if by 
#    overcrowding.
# 4. Any dead cell with exactly three live neighbours becomes a live cell, as 
#    if by reproduction.
#
# How to use :
# Just put it in script editor, playtest, and watch
# Press A to reset the seed
#
#===============================================================================
# *) Terms of Use :
#-------------------------------------------------------------------------------
# - Feel free to use
# - Feel free to modify
# - Dont forget to credit me if used / modified
#
#-------------------------------------------------------------------------------
# Special thanks :
# - Conway for the rules, obviously
#===============================================================================

# Size of the grid. Smaller number, more lag
  GridSize = 8
  
# Line border between each grid
  Spacing = 2
  
# Update timing. Larger number, slower update
  Timing = 5

# Sound effect for start
  ConfirmSE = RPG::SE.new('Decision2',76,145)
  
# Background Music
  BackMusic = RPG::BGM.new('Dungeon1',100,155)
  
#===============================================================================
# End of config
#===============================================================================
class ConwayGrid < Table
  attr_accessor :need_update
  
  def initialize
    super(Graphics.width / GridSize, Graphics.height / GridSize)
    xsize.times do |xpos|
      ysize.times do |ypos|
        self[xpos, ypos] = rand(2)
      end
    end
    @timing = Timing
  end
  
  def neighbor(dir, x, y)
    case dir
    when 1
      x -= 1
      y += 1
    when 2
      y += 1
    when 3
      y += 1
      x += 1
    when 4
      x -= 1
    when 6
      x += 1
    when 7
      x -= 1
      y -= 1
    when 8
      y -= 1
    when 9
      y -= 1
      x += 1
    end
    return self[x,y].to_i
  end
  
  def update
    @timing -= 1
    return unless @timing <= 0
    @timing = Timing
    prior = self.clone
    xsize.times do |xpos|
      ysize.times do |ypos|
        check_living(xpos, ypos, prior)
      end
    end
    @need_update = true
  end
  
  def check_living(xpos, ypos, prior)
    living_neighbor = [1,2,3,4,6,7,8,9].inject(0) do |r, dir|
      prior.neighbor(dir, xpos, ypos) + r
    end
    if self[xpos, ypos] == 0 && living_neighbor == 3
      self[xpos, ypos] = 1
    elsif !living_neighbor.between?(2,3)
      self[xpos, ypos] = 0
    end
  end
  
end

class Sprite_Conway < Sprite
  
  def initialize
    super
    self.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    update
  end
  
  def update
    super
    return unless $conwaygrid.need_update
    bitmap.clear
    $conwaygrid.xsize.times do |x|
      $conwaygrid.ysize.times do |y|
        next unless $conwaygrid[x,y] == 1
        a = [x * GridSize, y * GridSize, GridSize - Spacing, GridSize - Spacing]
        rect = Rect.new(*a)
        bitmap.fill_rect(rect, Color.new(255,255,255))
      end
    end
    $conwaygrid.need_update = false
  end
  
end

class Scene_Conway < Scene_Base
  
  def start
    super
    $conwaygrid = ConwayGrid.new
    @sprite = Sprite_Conway.new
    @sprite.bitmap.font.size = 42
    @sprite.bitmap.draw_text(@sprite.bitmap.rect, "Press Start to Continue",1)
    until Input.trigger?(:C)
      Graphics.update
      Input.update
    end
    @sprite.bitmap.clear
    ConfirmSE.play
    BackMusic.play
  end
  
  def update
    super
    $conwaygrid.update
    @sprite.update
    if Input.trigger?(:X)
      Graphics.update
      Input.update
      $conwaygrid = ConwayGrid.new
      $conwaygrid.need_update = true
      @sprite.update
    end
  end
  
end

rgss_main do
  scene = Scene_Conway.new
  scene.start
  scene.post_start
  scene.update while true
end

#==============================================================================
# TheoAllen - Animation Over Pictures
# Version: 1.0
# Contact: Discord @ Theo#3034
#==============================================================================
($imported ||= {})[:Theo_AnimationOverPic] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2018.03.03 - Translated to eng
# 2013.10.27 - Finished
#==============================================================================
%Q{

  =================
  || Introduction ||
  -----------------
  Don't you hate it when the animation is played behind the picture? Why not
  play the animation over the picture?
  
  ======================
  || How to use ||
  ----------------------
  Put the script below material and above main
  To use animation, use a script call
  
  anim_pic(pic_number, animation_id)
  
  ===================
  || Terms of use ||
  -------------------
  > Free to edit / Repost of edit
  > Free for commercial / non-commercial / contest with prize
  > Credit is not required, but don't claim it's yours
  
}
#==============================================================================
# Tidak ada konfigurasi
#==============================================================================
#==============================================================================
# * Game_Interpreter
#==============================================================================
class Game_Interpreter
  
  def anim_pic(pic_num, anim_id, mirror = false)
    if $game_party.in_battle
      pic = $game_troop.screen.pictures[pic_num]
    else
      pic = $game_map.screen.pictures[pic_num]
    end
    pic.anim_id = anim_id
    pic.anim_mirror = mirror
  end
  
end

#==============================================================================
# * Game_Picture
#==============================================================================

class Game_Picture
  attr_accessor :anim_id
  attr_accessor :anim_mirror
  
  alias theo_animpic_init initialize
  def initialize(number)
    theo_animpic_init(number)
    @anim_id = 0
    @anim_mirror = false
  end
  
end

#==============================================================================
# * Sprite_Picture
#==============================================================================

class Sprite_Picture
  
  @@ani_checker = []
  @@ani_spr_checker = []
  @@_reference_count = {}
  
  alias theo_animpic_dispose dispose
  def dispose
    theo_animpic_dispose
    dispose_animation
  end
  
  alias theo_animpic_update update
  def update
    theo_animpic_update
    update_animation
    @@ani_checker.clear
    @@ani_spr_checker.clear
    update_anim_flag
  end
  
  def update_anim_flag
    if @picture.anim_id > 0
      start_animation($data_animations[@picture.anim_id], @picture.anim_mirror)
      @picture.anim_id = 0
    end
  end
  
  def animation?
    @animation != nil
  end
  
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    if @animation
      @ani_mirror = mirror
      set_animation_rate
      @ani_duration = @animation.frame_max * @ani_rate + 1
      load_animation_bitmap
      make_animation_sprites
      set_animation_origin
    end
  end
  
  def set_animation_rate
    @ani_rate = 4     # Fixed value by default
    @ani_rate = YEA::CORE::ANIMATION_RATE if $imported["YEA-CoreEngine"]
  end
  
  def load_animation_bitmap
    animation1_name = @animation.animation1_name
    animation1_hue = @animation.animation1_hue
    animation2_name = @animation.animation2_name
    animation2_hue = @animation.animation2_hue
    @ani_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    @ani_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    if @@_reference_count.include?(@ani_bitmap1)
      @@_reference_count[@ani_bitmap1] += 1
    else
      @@_reference_count[@ani_bitmap1] = 1
    end
    if @@_reference_count.include?(@ani_bitmap2)
      @@_reference_count[@ani_bitmap2] += 1
    else
      @@_reference_count[@ani_bitmap2] = 1
    end
    Graphics.frame_reset
  end
  
  def make_animation_sprites
    @ani_sprites = []
    if !@@ani_spr_checker.include?(@animation)
      16.times do
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        @ani_sprites.push(sprite)
      end
      if @animation.position == 3
        @@ani_spr_checker.push(@animation)
      end
    end
    @ani_duplicated = @@ani_checker.include?(@animation)
    if !@ani_duplicated && @animation.position == 3
      @@ani_checker.push(@animation)
    end
  end
  
  def set_animation_origin
    if @animation.position == 3
      if viewport == nil
        @ani_ox = Graphics.width / 2
        @ani_oy = Graphics.height / 2
      else
        @ani_ox = viewport.rect.width / 2
        @ani_oy = viewport.rect.height / 2
      end
    else
      @ani_ox = x - ox + width / 2
      @ani_oy = y - oy + height / 2
      if @animation.position == 0
        @ani_oy -= height / 2
      elsif @animation.position == 2
        @ani_oy += height / 2
      end
    end
  end
  
  def dispose_animation
    if @ani_bitmap1
      @@_reference_count[@ani_bitmap1] -= 1
      if @@_reference_count[@ani_bitmap1] == 0
        @ani_bitmap1.dispose
      end
    end
    if @ani_bitmap2
      @@_reference_count[@ani_bitmap2] -= 1
      if @@_reference_count[@ani_bitmap2] == 0
        @ani_bitmap2.dispose
      end
    end
    if @ani_sprites
      @ani_sprites.each {|sprite| sprite.dispose }
      @ani_sprites = nil
      @animation = nil
    end
    @ani_bitmap1 = nil
    @ani_bitmap2 = nil
  end
  
  def update_animation
    return unless animation?
    @ani_duration -= 1
    if @ani_duration % @ani_rate == 0
      if @ani_duration > 0
        frame_index = @animation.frame_max
        frame_index -= (@ani_duration + @ani_rate - 1) / @ani_rate
        animation_set_sprites(@animation.frames[frame_index])
        @animation.timings.each do |timing|
          animation_process_timing(timing) if timing.frame == frame_index
        end
      else
        end_animation
      end
    end
  end
  
  def end_animation
    dispose_animation
  end
  
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? @ani_bitmap1 : @ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @ani_mirror
        sprite.x = @ani_ox - cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @ani_ox + cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  
  def animation_process_timing(timing)
    timing.se.play unless @ani_duplicated
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * @ani_rate)
    when 2
      if viewport && !@ani_duplicated
        viewport.flash(timing.flash_color, timing.flash_duration * @ani_rate)
      end
    when 3
      self.flash(nil, timing.flash_duration * @ani_rate)
    end
  end
end

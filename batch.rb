#gems/clock/lib/clock.rb
class Clock
  CHECK = 10 #frames 
  MAX_ALLOWED_MH = 0.5 #sec
  TICK_IN_SCENES = [Scene_Map, Scene_Battle]#, Scene_Menu]

  attr_accessor :started_at, :mh, :last_ticked_at

  class << self
    def start!
      @current = new
    end

    def flush!
      @current = nil
    end

    def load(arr)
      if arr.to_a.any?
        start!
        @current.started_at = arr[0]
        @current.mh = arr[1]
        @current.last_ticked_at = arr[2]
      end
    end

    def to_save
      return [] unless @current
      [@current.started_at, @current.mh, @current.last_ticked_at]
    end

    def seconds_in_game
      @current && @current.seconds_in_game
    end

    def tick 
      @current && @current.tick 
    end
  end

  def initialize
    @started_at = Time.now.to_f 
    @mh, @ticked = 0, 0
  end

  def tick 
    if @ticked % CHECK == 0 
      @mh += mh_seconds if mh_seconds > MAX_ALLOWED_MH 
      @last_ticked_at = Time.now.to_f
    end

    @ticked += 1
  end

  def mh_seconds
    return 0 unless @last_ticked_at
    Time.now.to_f - @last_ticked_at
  end

  def seconds_in_game
    (Time.now.to_f - @started_at - @mh).to_i
  end
end

#gems/clock/lib/clock/patch.rb
module Clock::Patch
end

#gems/clock/lib/clock/patch/scenes_patch.rb
Clock::TICK_IN_SCENES.each do |scene_klass|
  scene_klass.class_eval do 
    alias update_for_clock update 
    def update
      update_for_clock 
      Clock.tick
    end
  end
end
#gems/clock/lib/clock/patch/data_manager_patch.rb
module DataManager
  instance_eval do
    alias make_save_contents_for_clock make_save_contents
    def make_save_contents
      make_save_contents_for_clock.tap do |contents|
        contents[:clock] = Clock.to_save
      end
    end

    alias extract_save_contents_for_clock extract_save_contents
    def extract_save_contents(contents)
      extract_save_contents_for_clock contents
      Clock.load contents[:clock]
    end
  end
end
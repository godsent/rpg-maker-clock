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

require 'clock/patch'
Clock::TICK_IN_SCENES.each do |scene_klass|
  scene_klass.class_eval do 
    alias update_for_clock update 
    def update
      update_for_clock 
      Clock.tick
    end
  end
end
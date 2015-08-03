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
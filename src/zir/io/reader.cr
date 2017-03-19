module Zir
  module Reader
    def read_target(target : String) : String
      begin
        File.read(target)
      rescue
        Logger.e "Failed to read a target: #{target}"
        exit 1
      end
    end
  end
end

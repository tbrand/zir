module Zir
  module Writer

    def write_target(target : String, code : String) : String
      filepath = zir_filepath(target)
      
      begin
        File.write(filepath, code)
        filepath
      rescue
        Logger.e "Failed to write a target into: #{filepath}"
        exit 1
      end
    end

    def zir_filepath(target : String) : String

      if m = /^(.*)\.(.*)\.z$/.match(target)
        return "#{m[1]}.#{m[2]}"
      else
        return "#{target}"
      end
    end
  end
end

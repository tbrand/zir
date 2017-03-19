module Zir
  # Parsing zir.yaml and serving information from it
  module Parser
    TARGETS = "targets"
    IDS     = "ids"
    FINALLY = "finally"

    @yaml : YAML::Any?

    def yaml_path : String
      "#{Dir.current}/zir.yaml"
    end

    # Read zir.yaml from current directory
    def yaml : YAML::Any
      @yaml = YAML.parse(File.read(yaml_path)) if @yaml.nil?
      @yaml.not_nil!
    end

    # Parse zir.yaml and return command
    def get_cmd(id : String) : String
      begin
        yaml[IDS][id].to_s
      rescue
        Logger.e "Failed to find command for id in #{yaml_path}: #{id}"
        exit 1
      end
    end

    # Returned targets are absolute file pathes
    def get_targets : Array(String)
      begin
        res = Array(String).new
        yaml[TARGETS].each do |t|
          # Adding all matched pathes by `Dir.glob` but directories or not .z files are removed from them
          # Pathes are converted to absolute path
          res.concat(Dir.glob(File.expand_path(t.to_s)).reject{ |path| File.directory?(path) || !path.match(/^.*\.z$/) })
        end
        res
      rescue
        Logger.e "Failed to find targets in #{yaml_path}"
        exit 1
      end
    end

    def get_finally : String
      begin
        yaml[FINALLY].to_s
      rescue
        Logger.e "Failed to find a `finally` command in #{yaml_path}"
        exit 1
      end
    end
  end
end

require "./zir/*"
require "file_utils"
require "option_parser"

module Zir

  # Client for zir command
  class Cli
    @clean_depth : Int32 = 1

    # Parsing options for zir command
    def parse_option
      option_parser = OptionParser.new do |parser|

        parser.banner = "Usage: zir [arguments] [run, init, clean]"

        parser.on "-v", "--version", "Show the version" do
          Logger.i "version: #{Zir::VERSION}"
          exit
        end

        parser.on "-q", "--quiet", "Disable all logs (Default is not quiet)" do
          Logger.set_quiet(true)
        end

        parser.on "-h", "--help", "Show the helps" do
          puts parser
          puts <<-CMD

              run                              Execute zir command
              init                             Create sample zir.yaml into current directory
              clean                            Clean all temporary files created by zir
          CMD
          exit
        end

        # 0: Cleaning nothing, keep every temporary files that zir created.
        # 1: Clean temp files to execute macro.
        # 2: Clean every files created by zir
        parser.on "-c DEPTH", "--clean=DEPTH", "Set the depth of the cleaning. DEPTH can be 0 to 2. Default is 1." do |depth|
          if depth != "0" && depth != "1" && depth != "2"
            Logger.w "Invalid depth: \"#{depth}\", depth can be 0 to 2 (clean depth will be 2)"
          else
            @clean_depth = depth.to_i
          end
        end

        parser.unknown_args do |args|
          args.each do |arg|
            case arg
            when "run"
              main
            when "init"
              init
            when "clean"
              clean
            end
          end
        end
      end

      begin
        option_parser.parse(ARGV.clone)
      rescue e
        Logger.e "Oops..."
        if message = e.message
          Logger.e message
        end
      end
    end

    # Create sample zir.yaml into a current library
    def init
      # Checking an existance of zir.yaml in the current directory
      if File.exists?("zir.yaml")
        Logger.w "zir.yaml already eixsts in the current directory"
      else
        File.write "zir.yaml", <<-SAMPLE
        targets: # Targets to be expandedd by zir
          - src/main.c
          - src/libs/*.c

        ids: # identifiers for each script
          ruby: ruby @file
          python: python @file

        finally: # command to be executed at last
          gcc -o main main.c.z
        SAMPLE
      end
    end

    # Main function
    def main
      Logger.i "Starting zir [#{Zir::VERSION}]"

      # file pathes that zir created
      zir_files = Array(String).new

      # Get codes which include zir macro
      targets = get_targets
      targets.each do |target|
        
        # Code to be expanded by zir
        code = read_target(target)

        # Initialize and running zir engine
        engine = Zir::Engine.new(code)
        engine.run
        engine.clean if @clean_depth >= 1

        # Dump expanded code into zir file
        zir_file = write_target(target, engine.code)

        # Add the file to the list
        zir_files.push(zir_file)

        Logger.i "zir file create at #{zir_file}"
      end

      Logger.i "#{zir_files.size} files are expanded in total"

      # Execute finally command
      cmd_exec(get_finally)

      # clean: depth is 2
      zir_files.each do |zir_file|
        Logger.i "Delete #{zir_file}"
        FileUtils.rm(zir_file)
      end if @clean_depth == 2

      clean if @clean_depth >= 1
    end

    def clean
      Logger.i "Delete .zir directory"
      FileUtils.rm_rf("#{Dir.current}/.zir") if File.directory?("#{Dir.current}/.zir")
    end

    include Parser
    include Reader
    include Writer
    include Executor
  end
end

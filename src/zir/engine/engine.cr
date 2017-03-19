module Zir
  class Engine
    # Template of macro
    # For example, this will match with
    # ```
    # <-%ruby a = a + 1 ->
    # <-@ruby print a   ->
    # ```
    M_TEMPLATE = /<-(@|%)(.*?)[\s|\n]([\s|\S]*?)->/

    # Collected macros
    getter macros : Array(Macro)
    getter code   : String
    getter hex    : String

    def initialize(@code : String)
      @macros = Array(Macro).new
      @hex    = SecureRandom.hex
    end

    def run
      # Scan the code to
      # 1. Collect macros
      # 2. Replace the macros to a unique mark
      scan_code

      # Scanning and grouping each ids
      # id is `abc` of <-%abc code here ->
      scan_id_group

      # Execute macros and set result
      exec_macro

      # Expand macros into code
      expand_macro
    end

    def scan_code
      # Index of each macro
      idx = 0

      # Replace each macro to a unique mark
      @code = @code.gsub(M_TEMPLATE) do |m|

        # A unique mark
        mark = "__#{@hex}_#{idx}__"

        # Scanning the macro again to create a Macro object
        m.scan(M_TEMPLATE) do |match|

          tp = match[1] # type of the macro
          id = match[2] # identifier of the macro
          code = match[3] # code itself

          # Pushing the object to the array
          @macros.push(Macro.new(idx, tp, id, code, mark))
        end

        idx += 1

        # Replace the match to the mark
        mark
      end
    end

    # Scan id groups to create executable files
    def scan_id_group
      
      # Grouping macros with their id(such as `crystal` or `ruby`)
      # The id can be an arbitrary value
      grouped_macros = @macros.group_by{ |m| m.id }
      
      # For each group, create a temporary file to be executed
      grouped_macros.each_key do |id|
        
        # Pick one of the group
        id_group = grouped_macros[id]
        
        # Grouping the macros with their types(@ or %)
        tp_group = id_group.group_by{ |m| m.tp }
        
        # If the group doesn't contain a macro of type of `@`,
        # it means that the macros in the group print out nothing
        # So zir ignores them
        return unless tp_group.has_key?("@")
        
        # For each macro of type of `@`, create a temporary file to be executed
        # All logic types of macros(type of `%`) will be added into the file to keep a logic concurrency
        tp_group["@"].each do |tp_print|

          # Create an executable and set it to the print macro
          tp_print.filepath = create_executable(tp_print, tp_group)
        end
      end
    end

    # Create executables for `@` type macros
    # All logic macros will be added into the executables to keep a concurrency
    def create_executable(tp_print, tp_group) : String

      # The file name
      filepath = "#{tmp_for_executable}/#{tp_print.mark}"

      File.open(filepath, "w") do |file|

        printed = false

        # For each logic macros
        tp_group["%"].each do |tp_logic|

          # Insert the print macro if it's in between some logics
          if tp_logic.idx > tp_print.idx
            file.puts tp_print.code
            printed = true
          end

          file.puts tp_logic.code

        end if tp_group.has_key?("%") # The macros in the group has logics

        file.puts tp_print.code unless printed
      end

      filepath
    end

    # Execute macros by using temp executables
    # Set the result to Macro object
    def exec_macro
      @macros.each do |m|

        if filepath = m.filepath

          # Execute a temp file and get result
          if cmd = get_cmd(m.id)
            # todo: check an existance of @file
            if cmd.includes?("@file")
              m.result = cmd_exec(cmd.gsub("@file", filepath))
            else
              Logger.e "The command line of '#{m.id}' doesn't include '@file'."
              Logger.e "Please tell me how to execute temp executables."
            end
          end
        end if m.tp == "@"
      end
    end

    # Expand macros into the code
    def expand_macro
      @macros.each do |m|
        @code = @code.sub(m.mark, m.result)
      end
    end

    def clean
      @macros.each do |m|
        if filepath = m.filepath
          # Delete the temp file
          FileUtils.rm(filepath)
        end if m.tp == "@"
      end
    end

    def tmp_for_executable : String
      path = "#{Dir.current}/.zir"
      Dir.mkdir(path) unless Dir.exists?(path)
      path
    end

    include Parser
    include Executor
  end
end

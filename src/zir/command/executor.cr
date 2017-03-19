module Zir
  module Executor
    def cmd_exec(cmd : String) : String
      output = IO::Memory.new
      error  = IO::Memory.new

      p = Process.run(cmd, shell: true, input: nil, output: output, error: error)

      if p.exit_status != 0
        Logger.e "Error is happen while expanding macros"
        Logger.e error.to_s
        exit 1
      end

      output.to_s.chomp
    end
  end
end

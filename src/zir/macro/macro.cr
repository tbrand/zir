module Zir
  # should be struct?
  class Macro
    getter idx  : Int32
    getter tp   : String
    getter id   : String
    getter code : String
    getter mark : String

    property filepath : String?
    property result   : String?

    def initialize(@idx  : Int32,  # index
                   @tp   : String, # type of the macro, @(Print) or %(Logic)
                   @id   : String, # identifier of the macro
                   @code : String, # code itself
                   @mark : String) # marking string
    end
  end
end

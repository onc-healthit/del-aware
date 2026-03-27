# frozen_string_literal: true

def temp_file(filename, contents)
  file = Tempfile.new(filename)
  file.write(contents)
  file.flush
  file.rewind
  file
end

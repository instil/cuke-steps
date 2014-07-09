# Class that parses step definitions from Ruby files

class StepParser

  attr_reader :steps
  def initialize
    @steps = []
  end

  def read(file)
    @current_file = file
    @line_number = 0
    @lines = IO.read(file).split(/\r?\n/)
    parse_lines
  end


  private

  def next_line
    @line_number += 1
    @lines.shift
  end

  def unread(line)
    @line_number -= 1
    @lines.unshift(line)
  end

  def parse_lines
    @comments = []
    while not @lines.empty?

      line = next_line
      case line
      when /^\s*#/
        @comments << line
      when /^(Given|When|Then|Before|After|AfterStep|Transform)\s*/
        unread(line)
        parse_step
        @comments = []
      when /^\s+(Given|When|Then|Before|After|AfterStep|Transform)\s*/
        abort "WARNING:  Indented step definition in file #{@current_file}:  #{line}"
      else
        @comments = []
      end

    end
  end

  def parse_step
    type = parse_step_type(@lines.first)
    name = parse_step_name(@lines.first)
    line_number = @line_number + 1
    code = @comments
    line = ""
    while !@lines.empty? && !(line =~ /^end\s*$/)
      line = next_line
      code << line
    end
    @steps << { :type => type, :name => name, :filename => @current_file, :code => code, :line_number => line_number }
  end

  def parse_step_type(line)
    line.sub(/^([A-Za-z]+).*/, '\1')
  end

  def parse_step_name(line)
    line = line.sub(/^(Given|When|Then|Transform)\s*\/\^?(.*?)\$?\/.*/, '\1 \2')
    line = line.gsub('\ ', ' ')
    line
  end

end

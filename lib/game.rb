# frozen_string_literal: true

require 'io/console'
require_relative './helpers/game_helpers'
require_relative './map'

# Responsible of managing UI, score and snake.
class Game
  include GameHelpers

  def initialize(map, snake)
    @map = map
    @snake = snake
  end

  def start
    clear_screen
    spawn_snake
    @map.render
    loop do
      next unless DIRECTIONS.value? arrow_key = input

      @snake.direction = arrow_key
      clear_screen # Needs to be cleared because of broken output.
      @map.clear!
      @snake.move
      set_snake_on_map
      @map.render
    end
  end

  private

  def set_snake_on_map
    @map[@snake.head_row][@snake.head_col] = @snake.head_symbol
    @snake.length.times do |t|
      @map[@snake.head_row][@snake.head_col - t - 1] = @snake.tail_symbol
    end
  end

  def spawn_snake
    @snake.set_random_position_on_map(@map.width, @map.height)
    set_snake_on_map
  end

  def input
    input_text = $stdin.getch
    exit(0) if input_text == "\u0003" # CONTROL + C
    arrow_key = read_arrow_keys(input_text)
    amend_broken_output
    arrow_key
  end

  def read_arrow_keys(input_text)
    return unless input_text == "\e"

    # rubocop:disable Style/RescueModifier
    input_text << $stdin.read_nonblock(3) rescue nil
    input_text << $stdin.read_nonblock(2) rescue nil
    # rubocop:enable Style/RescueModifier
    input_text
  end

  def amend_broken_output
    $stdin.cooked!
  end

  def clear_screen
    if Gem.win_platform?
      system 'cls'
    else
      system 'clear'
    end
  end
end

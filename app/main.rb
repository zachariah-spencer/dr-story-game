def boot args
  args.state = {}
end

$FONT = "fonts/merriweather.ttf"

def tick args
  defaults args
  calc_particles args
  play_message_queue args

  args.outputs.background_color = [15,15,15]
  args.state.particles.each do |particle|
    args.outputs.solids << particle
  end
end

def defaults args
  if Kernel.tick_count == 0
    Speeds ||= {
      TURTLE: 0.5.seconds,
      SLOW: 0.25.seconds,
      MEDIUM: 0.06.seconds,
      FAST: 0.01.seconds,
      HYPER: 0.002.seconds
    }

    Expressions ||= {
      NORMAL: 1,
      QUIET: 2,
      LOUD: 3
    }

    Sizes ||= {
      SMALL: 3,
      MEDIUM: 10,
      LARGE: 20,
      HUGE: 30
    }

    args.state.messages ||= []
    args.state.particles ||= []
    args.state.space_bar_debounce ||= false
    args.state.message_data ||= GTK.parse_json_file "data/messages.json"

    args.state.current_message ||= nil
    args.state.displayed_message ||= ""
    args.state.new_character_tick ||= 0
    args.state.message_character_offset ||= 0

    default_messages args
    default_particles args
  end
end

def default_messages args
  args.state.message_data["welcome"].each_with_index do |data, i|

      puts data

      message = {
        id: "welcome#{i}",
        text: data["text"],
        speed: data["speed"].seconds,
        expression: data["expression"],
        size: data["size"],
      }
      queue_message message, args
  end
end

def default_particles args
  50.times_with_index do |i|
    scale = Numeric.rand(0.5..3.0)
    args.state.particles << { 
      id: "particle_#{i}", 
      x: Numeric.rand(0..1280),
      y: Numeric.rand(0..720),
      dx: Numeric.rand(-0.25..0.25),
      dy: Numeric.rand(-0.25..0.25),
      w: scale,
      h: scale,
      r: 210,
      g: 210,
      b: 210
    }
  end
end

def calc_particles args
  args.state.particles.each do |particle|
    particle.x += particle.dx
    particle.y += particle.dy

    particle.x = 0 if particle.x > 1280
    particle.x = 1280 if particle.x < 0

    particle.y = 0 if particle.y > 720
    particle.y = 720 if particle.y < 0
  end
end

def text_box
  w = 1280
  h = 256
  color = { r: 30, g: 30, b: 30}

  {
    x: 0,
    y: Grid.h - h,
    w: w,
    h: h,
  }.merge(color)
end

# msg should be a hash with message string and metadata
def queue_message message, args
  args.state.messages.unshift message
end

def clear_message_queue args
  args.state.messages.clear
end

def play_message_queue args
  args.outputs.labels << {
    x: (Grid.w / 2) - 9 * args.state.message_character_offset, 
    y: Grid.h - 32, 
    text: args.state.displayed_message,
    alignment_enum: 0,
    size_px: 48,
    font: $FONT,
    r: 210,
    g: 210,
    b: 210
  }

  if args.state.current_message

    playback_speed = args.state.current_message.speed
    playback_speed = 0.02 if args.inputs.keyboard.key_held.space unless args.state.space_bar_debounce
    args.state.space_bar_debounce = false if args.inputs.keyboard.key_up.space

    if args.state.new_character_tick.elapsed_time >= playback_speed
      args.state.new_character_tick = Kernel.tick_count
      args.state.displayed_message += args.state.current_message.text[args.state.displayed_message.size]
    end

    args.state.current_message = nil if args.state.displayed_message.size >= args.state.current_message.text.size

  elsif args.state.messages.size > 0 && args.inputs.keyboard.key_down.space

    args.state.space_bar_debounce = true
    args.state.displayed_message = ""
    args.state.current_message = args.state.messages.pop
    args.state.message_character_offset = args.state.current_message.text.size if args.state.current_message
    
  end
end
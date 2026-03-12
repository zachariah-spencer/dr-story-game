def boot args
  args.state = {}
end

$FONT = "fonts/merriweather.ttf"

def tick args
  args.outputs.background_color = [15,15,15]

  args.state.particles ||= []
  
  if args.state.particles.empty?
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


  args.state.current_message ||= nil
  args.state.displayed_message ||= ""
  args.state.new_character_tick ||= 0
  args.state.message_character_offset ||= 0
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

  
  args.state.message_test ||= {
    text: "ONE: This is a test message.",
    speed: Speeds.SLOW,
    expression: Expressions.NORMAL,
    size: Sizes.MEDIUM,
  }

  args.state.message_test_two ||= {
    text: "TWO: Just another one of my silly little messages",
    speed: Speeds.MEDIUM,
    expression: Expressions.NORMAL,
    size: Sizes.MEDIUM,
  }

  args.state.message_test_three ||= {
    text: "12345678901234567890123456789012345678901234567890123456789012345678",
    speed: Speeds.FAST,
    expression: Expressions.NORMAL,
    size: Sizes.MEDIUM,
  }

  args.state.messages ||= []

  queue_message args.state.message_test, args if args.inputs.keyboard.key_down.a
  queue_message args.state.message_test_two, args if args.inputs.keyboard.key_down.b
  queue_message args.state.message_test_three, args if args.inputs.keyboard.key_down.c

  calc_particles args
  args.state.particles.each do |particle|
    args.outputs.solids << particle
  end

  play_message_queue args
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
    x: (Grid.w / 2) - 8.6 * args.state.message_character_offset, 
    y: Grid.h - 32, 
    text: args.state.displayed_message,
    alignment_enum: 0,
    size_enum: 8,
    font: $FONT,
    r: 210,
    g: 210,
    b: 210
  }

  if args.state.current_message

    if args.state.new_character_tick.elapsed_time >= args.state.current_message.speed
      args.state.new_character_tick = Kernel.tick_count
      args.state.displayed_message += args.state.current_message.text[args.state.displayed_message.size]
    end

    if args.inputs.keyboard.key_down.space && args.state.displayed_message.size < args.state.current_message.text.size
      args.state.displayed_message = args.state.current_message.text
    end

    args.state.current_message = nil if args.state.displayed_message.size >= args.state.current_message.text.size
  elsif args.state.messages.size > 0 && args.inputs.keyboard.key_down.space
    args.state.displayed_message = ""
    args.state.current_message = args.state.messages.pop
    args.state.message_character_offset = args.state.current_message.text.size if args.state.current_message
    
  end
end
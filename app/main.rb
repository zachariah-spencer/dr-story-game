def boot args
  args.state = {}
  
end

def tick args
  args.outputs.background_color = [20,20,20]
  args.outputs.solids << text_box

  args.state.current_message ||= nil
  args.state.displayed_message ||= ""
  args.state.new_character_tick ||= 0
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

  
  args.state.message_test ||= {
    text: "ONE: This is a test message.",
    speed: Speeds.SLOW,
    expression: Expressions.NORMAL
  }

  args.state.message_test_two ||= {
    text: "TWO: Just another one of my silly little messages",
    speed: Speeds.MEDIUM,
    expression: Expressions.NORMAL
  }

  args.state.message_test_three ||= {
    text: "THREE: A third message that is extremely fast.",
    speed: Speeds.FAST,
    expression: Expressions.NORMAL
  }

  args.state.messages ||= []

  queue_message args.state.message_test, args if args.inputs.keyboard.key_down.a
  queue_message args.state.message_test_two, args if args.inputs.keyboard.key_down.b
  queue_message args.state.message_test_three, args if args.inputs.keyboard.key_down.c

  puts args.state.messages

  play_message_queue args
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
    x: 200, 
    y: 500, 
    text: args.state.displayed_message,
    size_enum: 10,
    r: 255
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
    
  end
end
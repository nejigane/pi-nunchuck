require 'em-websocket'
require 'i2c/i2c'
require 'json'

EM.run do
  status = {
    :stick => {:x => 0, :y => 0},
    :acc => {:x => 0, :y => 0, :z => 0},
    :button => {:z => false, :c => false}
  }

  nunchuck = ::I2C.create("/dev/i2c-1")
  nunchuck.write(0x52, 0xf0, 0x55)
  nunchuck.write(0x52, 0xfb, 0x00)
  nunchuck_id = nunchuck.read(0x52, 6, 0xfa).unpack('H6')

  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen { |handshake|
      puts "WebSocket connection open"
      ws.send "Hello Client, you connected to #{handshake.path}"
    }
    ws.onclose { puts "Connection closed" }
    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"
      ws.send status.to_json
    }
  end

  EM.add_periodic_timer(0.03) do
    nunchuck.write(0x52, 0x00)
    data = nunchuck.read(0x52, 6).unpack('C6')
    status[:stick][:x] = data[0]
    status[:stick][:y] = data[1]
    status[:acc][:x] = data[2] << 2 | (data[5] & 0x0c) >> 2
    status[:acc][:y] = data[3] << 2 | (data[5] & 0x30) >> 4
    status[:acc][:z] = data[4] << 2 | (data[5] & 0xc0) >> 6
    status[:button][:z] = data[5] & 1 == 0
    status[:button][:c] = (data[5] >> 1) & 1 == 0
  end
end

<div align="center">
  <img src="image.png" width="300"/>
  
  # Signal
  
  A fast, lightweight signal library for Luau.

  ⚡ Fast. Simple. Reliable.
</div>

---

## About

Signal is a fast and lightweight signal library for Luau. Simple to use and built with performance in mind.

Benchmarked against SignalPlus:

| Operation | Signal | SignalPlus |
|-----------|--------|------------|
| create | 173ns | 224ns |
| connect | 396ns | 648ns |
| fire (1 listener) | 1051ns | 1135ns |
| fire (10 listeners) | 9511ns | 9111ns |
| disconnect | 169ns | 147ns |

## Installation

Copy `Signal.luau` into your project and require it.

## API

### `Signal.new()`
Creates a new signal.
```lua
local signal = Signal.new()
```

### `signal:connect(callback)`
Connects a callback to the signal. Returns a `Connection`.
```lua
local connection = signal:connect(function(value)
    print(value)
end)
```

### `signal:once(callback)`
Connects a callback that automatically disconnects after the first fire.
```lua
signal:once(function(value)
    print(value)
end)
```

### `signal:fire(...)`
Fires the signal, calling all connected callbacks.
```lua
signal:fire("hello")
```

### `signal:wait()`
Yields the calling thread until the signal is fired. Returns the fired arguments.
```lua
local value = signal:wait()
```

### `signal:disconnectAll()`
Disconnects all connections from the signal.
```lua
signal:disconnectAll()
```

### `signal:destroy()`
Disconnects all connections and destroys the signal.
```lua
signal:destroy()
```

### `connection:disconnect()`
Disconnects a specific connection.
```lua
connection:disconnect()
```

### `connection.connected`
Boolean indicating whether the connection is still active.
```lua
print(connection.connected) -- true or false
```

## Example
```lua
local Signal = require(path.to.Signal)

local onDataReceived = Signal.new()

onDataReceived:connect(function(data)
    print("Received:", data)
end)

onDataReceived:fire("Hello, world!")
```

## License
MIT
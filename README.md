<div align="center">
  <img src="image.png" width="350"/>
  
  # createSignal
  
  A fast, lightweight signal library for Luau.

  ⚡ Fast. Simple. Reliable.
</div>

---

## About

createSignal is a fast and lightweight signal library for Luau. Simple to use and built with performance in mind.

Benchmarked against SignalPlus:

| Operation | createSignal | SignalPlus |
|-----------|--------|------------|
| create | 128ns | 141ns |
| connect | 444ns | 678ns |
| fire (1 listener) | 769ns | 823ns |
| fire (10 listeners) | 7884ns | 7800ns |
| disconnect | 156ns | 233ns |

## Installation

Copy `createSignal.luau` into your project and require it.

## API

### `createSignal()`
Creates a new signal.
```lua
local signal = createSignal<<(string, number)>>()
```

### `signal:connect(callback)`
Connects a callback to the signal. Returns a `Connection`.
```lua
local connection: createSignal.Connection = signal:connect(function(name, age)
    print(value)
end)
```

### `signal:once(callback)`
Connects a callback that automatically disconnects after the first fire.
```lua
signal:once(function(name, age)
    print(value)
end)
```

### `signal:fire(...)`
Fires the signal, calling all connected callbacks.
```lua
signal:fire("John", 23)
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
local createSignal = require(path.to.createSignal)

type PlayerData = {
    currency: number,
    gems: number,
}

local onDataReceived = createSignal<<(PlayerData)>>()

onDataReceived:connect(function(data)
    print("Received:", data)
end)

onDataReceived:fire({ curreny = 3000, gems = 30})
```

## License
MIT
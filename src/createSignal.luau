--!strict
--!optimize 2
--[[

--]]
export type Connection = {
	connected: boolean,
	disconnect: (self: Connection) -> (),
}

export type Signal<T... = ...any> = {
	connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	disconnectAll: (self: Signal<T...>) -> (),

	fire: (self: Signal<T...>, T...) -> (),
	wait: (self: Signal<T...>) -> T...,
}

type InternalConnection = {
	_signal: InternalSignal,
	_previous: InternalConnection?,
	_next: InternalConnection?,
	_callback: (...any) -> (),

	connected: boolean,
	disconnect: (self: InternalConnection) -> (),
}

type InternalSignal = {
	_head: InternalConnection?,
	_tail: InternalConnection?,

	connect: (self: InternalSignal, callback: (...any) -> ()) -> InternalConnection,
	once: (self: InternalSignal, callback: (...any) -> ()) -> InternalConnection,
	disconnectAll: (self: InternalSignal) -> (),

	fire: (self: InternalSignal, ...any) -> (),
	wait: (self: InternalSignal) -> ...any,
}

local freeThreads: { thread } = {}

-- ** lib ** --
local coroutineRuning = coroutine.running
local coroutineCreate = coroutine.create
local coroutineResume = coroutine.resume
local coroutineYield = coroutine.yield
local taskSpawn = task.spawn
local tableInsert = table.insert

local function run(callbackAsync: (...any) -> (), thread: thread, ...: any)
	callbackAsync(...)
	tableInsert(freeThreads, thread)
end

local function yielder()
	while true do
		run(coroutineYield())
	end
end

-- ** connection impl ** --
local function disconnect(self: InternalConnection)
	if not self.connected then
		return
	end

	self.connected = false

	local signal = self._signal
	local previous = self._previous
	local _next = self._next

	if previous then
		previous._next = _next
	else
		signal._tail = _next
	end

	if _next then
		_next._previous = previous
	else
		signal._head = previous
	end
end

local function disconnectAll(self: InternalSignal)
	local connection = self._tail

	while connection do
		local _next = connection._next

		connection.connected = false
		connection._next = nil
		connection._previous = nil

		connection = _next
	end

	self._head = nil
	self._tail = nil
end

local function destroy(self: InternalSignal)
	disconnectAll(self)
	setmetatable(self, nil)
end

-- ** signal impl ** --
local function connect(self: InternalSignal, callback: (...any) -> ())
	local head = self._head

	local connection: InternalConnection = {
		_signal = self,
		_previous = head,
		_callback = callback,

		connected = true,
		disconnect = disconnect,
	}

	if head then
		head._next = connection
	else
		self._tail = connection
	end

	self._head = connection

	return connection
end

local function once(self: InternalSignal, callback: (...any) -> ())
	local connection: InternalConnection
	connection = connect(self, function(...: any)
		disconnect(connection)
		callback(...)
	end)

	return connection
end

local function _wait(self: InternalSignal): ...any
	local runningThread = coroutineRuning()

	once(self, function(...: any)
		taskSpawn(runningThread, ...)
	end)

	return coroutineYield()
end

local function fire(self: InternalSignal, ...: any)
	local connection = self._tail

	while connection do
		local threadLength = #freeThreads

		if threadLength == 0 then
			local thread: thread = coroutineCreate(yielder)
			coroutineResume(thread)

			taskSpawn(thread, connection._callback, thread, ...)
		else
			local thread: thread = freeThreads[threadLength]
			freeThreads[threadLength] = nil

			taskSpawn(thread, connection._callback, thread, ...)
		end

		connection = connection._next
	end
end

local Signal = {
	connect = connect,
	once = once,
	fire = fire,
	wait = _wait,

	disconnectAll = disconnectAll,
	destroy = destroy,
}

Signal.__index = Signal

local function createSignal<T...>(): Signal<T...>
	return setmetatable({}, Signal) :: any
end

return createSignal

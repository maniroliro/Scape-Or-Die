--[[--!optimize 2
--!strict
--!native

local freeThreads: { thread } = {}

local function runCallback(callback, thread, ...)
	callback(...)
	table.insert(freeThreads, thread)
end

local function yielder()
	while true do
		runCallback(coroutine.yield())
	end
end

local Connection = {}
Connection.__index = Connection
type self = {
	Connected: boolean,
	_signal: any,
	_next: any,
	_prev: any,
}
export type SignalConnection = typeof(setmetatable({} :: self, Connection))

local function disconnect(self: SignalConnection)
	if not self.Connected then
		return
	end
	self.Connected = false

	local next = self._next
	local prev = self._prev

	if next then
		next._prev = prev
	end
	if prev then
		prev._next = next
	end

	local signal = self._signal
	if signal._head == self then
		signal._head = next
	end
end

local function reconnect(self: SignalConnection)
	if self.Connected then
		return
	end
	self.Connected = true

	local signal = self._signal
	local head = signal._head
	if head then
		head._prev = self
	end
	signal._head = self

	self._next = head
	self._prev = false
end

Connection.Disconnect = disconnect
Connection.Reconnect = reconnect

--\\ Signal //--
local Signal = {} --:: SignalTable
Signal.__index = Signal

export type Signal<T...> = {
	RBXScriptConnection: RBXScriptConnection?,

	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> SignalConnection,
	Once: (self: Signal<T...>, fn: (T...) -> ()) -> SignalConnection,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	FireDefer: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

export type SignalType<Func, T...> = {
	RBXScriptConnection: RBXScriptConnection?,

	Fire: (self: SignalType<Func, T...>, T...) -> (),
	FireDefer: (self: SignalType<Func, T...>, T...) -> (),
	Connect: (self: SignalType<Func, T...>, fn: Func) -> SignalConnection,
	Once: (self: SignalType<Func, T...>, fn: Func) -> SignalConnection,
	Wait: (self: SignalType<Func, T...>) -> T...,
	DisconnectAll: (self: SignalType<Func, T...>) -> (),
	Destroy: (self: SignalType<Func, T...>) -> ()
}

export type GenericSignal = Signal<>

-- stylua: ignore
local rbxConnect, rbxDisconnect do
	if task then
		local bindable = Instance.new("BindableEvent")
		rbxConnect = bindable.Event.Connect
		rbxDisconnect = bindable.Event:Connect(function() end).Disconnect
		bindable:Destroy()
	end
end

local function connect(self: any, fn: any, ...: any)
	local head = self._head
	local cn = setmetatable({
		Connected = true,
		_signal = self,
		_fn = fn,
		_varargs = if not ... then false else { ... },
		_next = head,
		_prev = false,
	}, Connection)

	if head then
		head._prev = cn
	end
	self._head = cn

	return cn
end

local function once(self, fn, ...)
	local cn
	cn = connect(self :: any, function(...)
		disconnect(cn)
		fn(...)
	end, ...)
	return cn
end

local function wait(self)
	local thread = coroutine.running()
	local cn
	cn = connect(self :: any, function(...)
		disconnect(cn)
		self._waiting[thread] = nil
		if coroutine.status(thread) == "suspended" then
			task.spawn(thread, ...)
		end
	end)
	self._waiting[thread] = true
	return coroutine.yield()
end

-- Fires the signal and resumes connections immediately via <code>task.spawn()</code>.
-- Please transition to <code>:FireDefer()</code> instead to continue adopting the new deferred signaling model.
local function fire<Func, T...>(self: any, ...: any)
	local cn = self._head
	while cn do
		local thread
		if #freeThreads > 0 then
			thread = freeThreads[#freeThreads]
			freeThreads[#freeThreads] = nil
		else
			thread = coroutine.create(yielder)
			coroutine.resume(thread)
		end

		if not cn._varargs then
			task.spawn(thread, cn._fn, thread, ...)
		else
			local args = cn._varargs
			local len = #args
			local count = len
			local newArgs = table.pack(...) -- Use table.pack to pack the variadic arguments (resolves type error)
			for i = 1, newArgs.n do
				count += 1
				args[count] = newArgs[i]
			end

			task.spawn(thread, cn._fn, thread, table.unpack(args))

			for i = count, len + 1, -1 do
				args[i] = nil
			end
		end

		cn = cn._next
	end
end

-- Fires the signal and resumes connections via <code>task.defer()</code>.
local function fireDefer<Func, T...>(self: any, ...: any)
	local newArgs = table.pack(...) -- Use table.pack to pack the variadic arguments (resolves type error)
	-- cannot task.defer the threads themselves due to the thread recycling
	task.defer(function()
		local cn = self._head
		while cn do
			local thread
			if #freeThreads > 0 then
				thread = freeThreads[#freeThreads]
				freeThreads[#freeThreads] = nil
			else
				thread = coroutine.create(yielder)
				coroutine.resume(thread)
			end

			if not cn._varargs then
				task.spawn(thread, cn._fn, thread, table.unpack(newArgs))
			else
				local args = cn._varargs
				local len = #args
				local count = len
				for i = 1, newArgs.n do
					count += 1
					args[count] = newArgs[i]
				end

				task.spawn(thread, cn._fn, thread, table.unpack(args))

				for i = count, len + 1, -1 do
					args[i] = nil
				end
			end

			cn = cn._next
		end
	end)
end

local function disconnectAll(self: any)
	local cn = self._head
	while cn do
		disconnect(cn)
		cn = cn._next
	end
end

local function destroy(self: any)
	disconnectAll(self :: any)
	for thread, _ in pairs(self._waiting) do
		if coroutine.status(thread) == "suspended" then
			task.cancel(thread)
		end
		self._waiting[thread] = nil
	end
	local cn = self.RBXScriptConnection
	if cn then
		rbxDisconnect(cn)
		self.RBXScriptConnection = nil
	end
end

--\\ Constructors
function Signal.new(): any
	local self = { _head = false, _waiting = {} }
	setmetatable(self, Signal)

	return self :: any
end

function Signal.wrap(signal: RBXScriptSignal): any
	local wrapper = setmetatable({ _head = false, _waiting = {} }, Signal)

	wrapper.RBXScriptConnection = rbxConnect(signal :: any, function(...)
		fire(wrapper :: any, ...)
	end)

	return wrapper :: any
end

--\\ Methods
Signal.Connect = connect
Signal.Once = once
Signal.Wait = wait
Signal.Fire = fire
Signal.FireDefer = fireDefer
Signal.DisconnectAll = disconnectAll
Signal.Destroy = destroy

return { new = Signal.new, wrap = Signal.wrap }]]

-- -----------------------------------------------------------------------------
--               Batched Yield-Safe Signal Implementation                     --
-- This is a Signal class which has effectively identical behavior to a       --
-- normal RBXScriptSignal, with the only difference being a couple extra      --
-- stack frames at the bottom of the stack trace when an error is thrown.     --
-- This implementation caches runner coroutines, so the ability to yield in   --
-- the signal handlers comes at minimal extra cost over a naive signal        --
-- implementation that either always or never spawns a thread.                --
--                                                                            --
-- API:                                                                       --
--   local Signal = require(THIS MODULE)                                      --
--   local sig = Signal.new()                                                 --
--   local connection = sig:Connect(function(arg1, arg2, ...) ... end)        --
--   sig:Fire(arg1, arg2, ...)                                                --
--   connection:Disconnect()                                                  --
--   sig:DisconnectAll()                                                      --
--   local arg1, arg2, ... = sig:Wait()                                       --
--                                                                            --
-- License:                                                                   --
--   Licensed under the MIT license.                                          --
--                                                                            --
-- Authors:                                                                   --
--   stravant - July 31st, 2021 - Created the file.                           --
--   sleitnick - August 3rd, 2021 - Modified for Knit.                        --
-- -----------------------------------------------------------------------------

-- Signal types
export type Connection = {
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
	Connected: boolean,
}

export type Signal<Func = () -> (), T... = ...any> = {
	Fire: (self: Signal<Func, T...>, T...) -> (),
	FireDeferred: (self: Signal<Func, T...>, T...) -> (),
	Connect: (self: Signal<Func, T...>, fn: Func) -> Connection,
	Once: (self: Signal<Func, T...>, fn: Func) -> Connection,
	DisconnectAll: (self: Signal<Func, T...>) -> (),
	GetConnections: (self: Signal<Func, T...>) -> { Connection },
	Destroy: (self: Signal<Func, T...>) -> (),
	Wait: (self: Signal<Func, T...>) -> T...,
}

-- The currently idle thread to run the next handler on
local freeRunnerThread = nil

-- Function which acquires the currently idle handler runner thread, runs the
-- function fn on it, and then releases the thread, returning it to being the
-- currently idle one.
-- If there was a currently idle runner thread already, that's okay, that old
-- one will just get thrown and eventually GCed.
local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	freeRunnerThread = acquiredRunnerThread
end

-- Coroutine runner that we create coroutines of. The coroutine can be
-- repeatedly resumed with functions to run followed by the argument to run
-- them with.
local function runEventHandlerInFreeThread(...)
	acquireRunnerThreadAndCallEventHandler(...)
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

--[[
	@within Signal
	@interface SignalConnection
	.Connected boolean
	.Disconnect (SignalConnection) -> ()
	Represents a connection to a signal.
	```lua
	local connection = signal:Connect(function() end)
	print(connection.Connected) --> true
	connection:Disconnect()
	print(connection.Connected) --> false
	```
]]

-- Connection class
local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn)
	return setmetatable({
		Connected = true,
		_signal = signal,
		_fn = fn,
		_next = false,
	}, Connection)
end

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false

	-- Unhook the node, but DON'T clear it. That way any fire calls that are
	-- currently sitting on this node will be able to iterate forwards off of
	-- it, but any subsequent fire calls will not hit it, and it will be GCed
	-- when no more fire calls are sitting on it.
	if self._signal._handlerListHead == self then
		self._signal._handlerListHead = self._next
	else
		local prev = self._signal._handlerListHead
		while prev and prev._next ~= self do
			prev = prev._next
		end
		if prev then
			prev._next = self._next
		end
	end

	if self._signal.connectionsChanged then
		self._signal.totalConnections -= 1
		self._signal.connectionsChanged:Fire(-1)
	end
end

Connection.Destroy = Connection.Disconnect

-- Make Connection strict
setmetatable(Connection, {
	__index = function(_tb, key)
		error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_tb, key, _value)
		error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
})

--[[
	@within Signal
	@type ConnectionFn (...any) -> ()
	A function connected to a signal.
]]

--[[
	@class Signal
	Signals allow events to be dispatched and handled.
	For example:
	```lua
	local signal = Signal.new()
	signal:Connect(function(msg)
		print("Got message:", msg)
	end)
	signal:Fire("Hello world!")
	```
]]
local Signal = {}
Signal.__index = Signal

--[[
	Constructs a new Signal
	@return Signal
]]
function Signal.new<Func, T...>(createConnectionsChangedSignal: boolean?): Signal<Func, T...>
	local self = setmetatable({
		_handlerListHead = false,
		_proxyHandler = nil,
	}, Signal)
	if createConnectionsChangedSignal then
		self.totalConnections = 0
		self.connectionsChanged = Signal.new()
	end
	return self
end

--[[
	Constructs a new Signal that wraps around an RBXScriptSignal.
	@param rbxScriptSignal RBXScriptSignal -- Existing RBXScriptSignal to wrap
	@return Signal
	For example:
	```lua
	local signal = Signal.Wrap(workspace.ChildAdded)
	signal:Connect(function(part) print(part.Name .. " added") end)
	Instance.new("Part").Parent = workspace
	```
]]
function Signal.Wrap<func, T...>(rbxScriptSignal: RBXScriptSignal): Signal<func, T...>
	assert(
		typeof(rbxScriptSignal) == "RBXScriptSignal",
		"Argument #1 to Signal.Wrap must be a RBXScriptSignal; got " .. typeof(rbxScriptSignal)
	)
	local signal = Signal.new()
	signal._proxyHandler = rbxScriptSignal:Connect(function(...)
		signal:Fire(...)
	end)
	return signal
end

--[[
	Checks if the given object is a Signal.
	@param obj any -- Object to check
	@return boolean -- `true` if the object is a Signal.
]]
function Signal.Is(obj: any): boolean
	return type(obj) == "table" and getmetatable(obj) == Signal
end

--[[
	@param fn ConnectionFn
	@return SignalConnection
	Connects a function to the signal, which will be called anytime the signal is fired.
	```lua
	signal:Connect(function(msg, num)
		print(msg, num)
	end)
	signal:Fire("Hello", 25)
	```
]]
function Signal:Connect(fn)
	local connection = Connection.new(self, fn)
	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end

	if self.connectionsChanged then
		self.totalConnections += 1
		self.connectionsChanged:Fire(1)
	end
	return connection
end

--[[
	@deprecated v1.3.0 -- Use `Signal:Once` instead.
	@param fn ConnectionFn
	@return SignalConnection
]]
function Signal:ConnectOnce(fn)
	return self:Once(fn)
end

--[[
	@param fn ConnectionFn
	@return SignalConnection
	Connects a function to the signal, which will be called the next time the signal fires. Once
	the connection is triggered, it will disconnect itself.
	```lua
	signal:Once(function(msg, num)
		print(msg, num)
	end)
	signal:Fire("Hello", 25)
	signal:Fire("This message will not go through", 10)
	```
]]
function Signal:Once(fn)
	local connection
	local done = false
	connection = self:Connect(function(...)
		if done then
			return
		end
		done = true
		connection:Disconnect()
		fn(...)
	end)
	return connection
end

function Signal:GetConnections()
	local items = {}
	local item = self._handlerListHead
	while item do
		table.insert(items, item)
		item = item._next
	end
	return items
end

-- Disconnect all handlers. Since we use a linked list it suffices to clear the
-- reference to the head handler.
--[[
	Disconnects all connections from the signal.
	```lua
	signal:DisconnectAll()
	```
]]
function Signal:DisconnectAll()
	local item = self._handlerListHead
	while item do
		item.Connected = false
		item = item._next
	end
	self._handlerListHead = false

	if self.connectionsChanged then
		self.connectionsChanged:Fire(-self.totalConnections)
		self.connectionsChanged:Destroy()
		self.connectionsChanged = nil
		self.totalConnections = 0
	end
end

-- Signal:Fire(...) implemented by running the handler functions on the
-- coRunnerThread, and any time the resulting thread yielded without returning
-- to us, that means that it yielded to the Roblox scheduler and has been taken
-- over by Roblox scheduling, meaning we have to make a new coroutine runner.
--[[
	@param ... any
	Fire the signal, which will call all of the connected functions with the given arguments.
	```lua
	signal:Fire("Hello")
	-- Any number of arguments can be fired:
	signal:Fire("Hello", 32, {Test = "Test"}, true)
	```
]]
function Signal:Fire(...)
	local item = self._handlerListHead
	while item do
		if item.Connected then
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
			end
			task.spawn(freeRunnerThread, item._fn, ...)
		end
		item = item._next
	end
end

--[[
	@param ... any
	Same as `Fire`, but uses `task.defer` internally & doesn't take advantage of thread reuse.
	```lua
	signal:FireDeferred("Hello")
	```
]]
function Signal:FireDeferred(...)
	local item = self._handlerListHead
	while item do
		task.defer(item._fn, ...)
		item = item._next
	end
end

--[[
	@return ... any
	@yields
	Yields the current thread until the signal is fired, and returns the arguments fired from the signal.
	Yielding the current thread is not always desirable. If the desire is to only capture the next event
	fired, using `Once` might be a better solution.
	```lua
	task.spawn(function()
		local msg, num = signal:Wait()
		print(msg, num) --> "Hello", 32
	end)
	signal:Fire("Hello", 32)
	```
]]
function Signal:Wait()
	local waitingCoroutine = coroutine.running()
	local connection
	local done = false
	connection = self:Connect(function(...)
		if done then
			return
		end
		done = true
		connection:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end

--[[
	Cleans up the signal.
	Technically, this is only necessary if the signal is created using
	`Signal.Wrap`. Connections should be properly GC'd once the signal
	is no longer referenced anywhere. However, it is still good practice
	to include ways to strictly clean up resources. Calling `Destroy`
	on a signal will also disconnect all connections immediately.
	```lua
	signal:Destroy()
	```
]]
function Signal:Destroy()
	self:DisconnectAll()
	local proxyHandler = rawget(self, "_proxyHandler")
	if proxyHandler then
		proxyHandler:Disconnect()
	end
end

-- Make signal strict
setmetatable(Signal, {
	__index = function(_tb, key)
		return rawget(_tb, key)
	end,
	__newindex = function(_tb, key, _value)
		error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end,
})

return {
	new = Signal.new,
	Wrap = Signal.Wrap,
	Is = Signal.Is,
}

local SignalPlus = require("./SignalPlus")
local createSignal = require("./createSignal")

local ITERATIONS = 100_000

local function bench(label: string, fn: () -> ()): number
	local start = os.clock()
	for _ = 1, ITERATIONS do
		fn()
	end
	local elapsed = os.clock() - start
	print(string.format("[%-12s] %.2fms | %.0fns/call", label, elapsed * 1000, elapsed / ITERATIONS * 1_000_000_000))
	return elapsed
end

local function diff(tA: number, lA: string, tB: number, lB: string)
	local faster, slower = if tA < tB then lA else lB, if tA < tB then lB else lA
	print(string.format("  → %s is %.2fx faster than %s\n", faster, math.max(tA, tB) / math.min(tA, tB), slower))
end

for _ = 1, 1_000 do
	SignalPlus()
end
for _ = 1, 1_000 do
	createSignal()
end

print("==[ create ]==")
diff(
	bench("SignalPlus", function()
		SignalPlus()
	end),
	"SignalPlus",
	bench("createSignal", function()
		createSignal()
	end),
	"createSignal"
)

print("==[ connect ]==")
local sp, cs = SignalPlus(), createSignal()
diff(
	bench("SignalPlus", function()
		sp:Connect(function() end)
	end),
	"SignalPlus",
	bench("createSignal", function()
		cs:connect(function() end)
	end),
	"createSignal"
)

print("==[ fire 1 listener ]==")
local spF, csF = SignalPlus(), createSignal()
spF:Connect(function() end)
csF:connect(function() end)
diff(
	bench("SignalPlus", function()
		spF:Fire()
	end),
	"SignalPlus",
	bench("createSignal", function()
		csF:fire()
	end),
	"createSignal"
)

print("==[ fire 10 listeners ]==")
local spF10, csF10 = SignalPlus(), createSignal()
for _ = 1, 10 do
	spF10:Connect(function() end)
end
for _ = 1, 10 do
	csF10:connect(function() end)
end
diff(
	bench("SignalPlus", function()
		spF10:Fire()
	end),
	"SignalPlus",
	bench("createSignal", function()
		csF10:fire()
	end),
	"createSignal"
)

print("==[ disconnect ]==")
local spD, csD = SignalPlus(), createSignal()
local spConns, csConns = {}, {}
for i = 1, ITERATIONS do
	spConns[i] = spD:Connect(function() end)
end
for i = 1, ITERATIONS do
	csConns[i] = csD:connect(function() end)
end
local idx = 0
diff(
	bench("SignalPlus", function()
		idx = (idx % ITERATIONS) + 1
		if spConns[idx].Connected then
			spConns[idx]:Disconnect()
		end
	end),
	"SignalPlus",
	bench("createSignal", function()
		idx = (idx % ITERATIONS) + 1
		if csConns[idx].connected then
			csConns[idx]:disconnect()
		end
	end),
	"createSignal"
)

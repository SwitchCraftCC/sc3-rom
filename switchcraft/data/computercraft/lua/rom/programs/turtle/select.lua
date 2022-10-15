local slot = ...

slot = tonumber(slot)
assert(slot, "slot must be a number")
assert(slot >= 1 and slot <= 16, "slot must be between 1 and 16")

turtle.select(slot)

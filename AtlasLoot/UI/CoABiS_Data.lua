-- AtlasLoot-CoA phase-specific item lists.
-- Structure: AL.CoABiS[phase][class][specialization] = {
--   {slot="Head", id=12345, name="Item name", source="Boss / vendor"},
-- }
-- Intentionally empty until the website's actual exported lists can be verified.
-- This avoids presenting incorrect weapon categories or invented BiS gear.
local AL = LibStub("AceAddon-3.0"):GetAddon("AtlasLoot")
AL.CoABiS = { [1] = {}, [2] = {} }

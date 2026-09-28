---@meta

-- ***<u>(BACK COMPAT, explicit args also annotated)</u>***\
-- Get all highlighted cards in the specified list of card areas.
---@param areas table A list of card areas to search.
---@param ignore? Card A card to exclude from the highlighted list.
---@param min? number
---@param max? number If the count of highlighted cards exceeds this value, returned table will be a max-sized lsit of randomly selected highlighted cards.
---@param blacklist? string[] | (fun(card: Card): boolean) If function returns true, card is included into the highlighted list. Table entries are keys of centers to exclude.
---@param seed? string|any Can be used alongside the `max` parameter.
---@return Card[]
function Spectrallib.get_highlighted_cards(areas, ignore, min, max, blacklist, seed)
end
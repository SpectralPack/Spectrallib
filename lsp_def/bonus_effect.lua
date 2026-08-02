---@meta

---@class Spectrallib.BonusEffect: SMODS.GameObject
---@field obj_table? table<string, Spectrallib.BonusEffect|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field __call? fun(self: Spectrallib.BonusEffect|table, o: Spectrallib.BonusEffect|table): nil|table|Spectrallib.BonusEffect
---@field extend? fun(self: Spectrallib.BonusEffect|table, o: Spectrallib.BonusEffect|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: Spectrallib.BonusEffect|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: Spectrallib.BonusEffect|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: Spectrallib.BonusEffect|table) Registers the object. 
---@field check_dependencies? fun(self: Spectrallib.BonusEffect|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: Spectrallib.BonusEffect|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: Spectrallib.BonusEffect|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: Spectrallib.BonusEffect|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: Spectrallib.BonusEffect|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: Spectrallib.BonusEffect|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: Spectrallib.BonusEffect|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: Spectrallib.BonusEffect|table, key: string, obj: Spectrallib.BonusEffect|table, silent?: boolean): nil|table|Spectrallib.BonusEffect Takes control of existing objects. Child class must have get_obj for this to function. 
---@field apply? fun(self: Spectrallib.BonusEffect|table, card: Card|table, config: table, index?: integer) Handles adding this BonusEffect to the given `card`. 
---@field remove? fun(self: Spectrallib.BonusEffect|table, card: Card|table, eff_table: table, index: integer) Handles removing this BonusEffect from the given `card`. 
---@field on_apply? fun(self: Spectrallib.BonusEffect|table, card: Card|table, eff_table: table) Handles running effects that should happen after the effect is applied, such as setting default values. Runs before add_to_deck. 
---@field on_remove? fun(self: Spectrallib.BonusEffect|table, card: Card|table, eff_table: table) Handles running effects that should happen before the effect is removed. Runs before remove_from_deck. 
---@field add_to_deck? fun(self: Spectrallib.BonusEffect|table, card: Card|table, eff_table: table) Handles running effects that should happen when a card with this effect is obtained, or when it is added to an already owned card. 
---@field remove_from_deck? fun(self: Spectrallib.BonusEffect|table, card: Card|table, eff_table: table) Handles running effects that should happen when a card with this effect is removed, or when it is removed from an already owned card. 
---@field calculate? (fun(self: Spectrallib.BonusEffect|table, card: Card|table, eff_table: table, context: CalcContext|table): table?, boolean?) Calculates effects based on parameters in `context`. See [SMODS calculation](https://github.com/Steamodded/smods/wiki/calculate_functions) docs for details. 
---@field loc_vars? (fun(self: Spectrallib.BonusEffect|table, info_queue: table, card: table|{ability: table}, eff_table: table): table?) Provides simple control over displaying descriptions and tooltips of the card. See [`loc_vars`](https://github.com/Steamodded/smods/wiki/Localization#loc_vars) documentation for return value details.<br>Note that `card` is often not a `Card` object. 
---@field has_attribute? (fun(self: Spectrallib.BonusEffect|table, card: Card|table, eff_table: table, attribute: string): boolean|nil) Return `true` if the card should be considered to have the given `attribute`. Allows for dynamic attributes based on config values. 
---@overload fun(self: Spectrallib.BonusEffect): Spectrallib.BonusEffect
Spectrallib.BonusEffect = setmetatable({}, {
    __call = function (self)
        return self
    end
})

---@type table<string, Spectrallib.BonusEffect|table>
Spectrallib.BonusEffects = {}
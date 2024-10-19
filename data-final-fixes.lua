---@param recipe data.RecipePrototype
local function add_virtual_signal(recipe)
  local name = recipe.name

  -- Recipe is hidden; skip
  if recipe.hidden then return end
  -- Recipe has no icon; skip
  if not recipe.icon and not recipe.icons then return end
  -- Recipe already exists as an item or fluid, so its icon is already available; skip
  if data.raw.item[name] or data.raw.fluid[name] then return end

  -- Some recipes don't have defined localized names, so need several fallbacks.
  local localised_name = { "?", { "recipe-name." .. name } }
  if recipe.localised_name ~= nil and recipe.localised_name ~= "" then
    table.insert(localised_name, recipe.localised_name)
  end
  if type(recipe.main_product) == "string" and recipe.main_product ~= "" then
    table.insert(localised_name, { recipe.main_product })
  end
  if type(recipe.results) == "table" and table_size(recipe.results) > 0 then
    local result = recipe.results[1]
    -- `results` is malformed for several recipes, so do some defensive programming...
    if type(recipe.results) == "table" then
      local result_type = "item"
      if type(result.type) == "string" then
        result_type = result.type
      end

      local result_name = result.name
      if type(result_name) ~= "string" then
        result_name = result[1]
      end

      if type(result_type) == "string" and type(result_name) == "string" then
        table.insert(localised_name, { result_type .. "-name." .. result_name })
      end
    end
  end
  table.insert(localised_name, { "item-name." .. name })
  table.insert(localised_name, "Unknown recipe")

  ---@class data.VirtualSignalPrototype
  local virtual_signal = {
    type = "virtual-signal",
    name = name,
    order = recipe.order,
    localised_name = localised_name,

    icons = recipe.icons,
    icon = recipe.icon,
    icon_size = recipe.icon_size,
    icon_mipmaps = recipe.icon_mipmaps,
    subgroup = recipe.subgroup,
  }

  data:extend { virtual_signal }
end

for _, recipe in pairs(data.raw.recipe) do
  add_virtual_signal(recipe)
end

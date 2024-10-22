-- control.lua

-- Table to keep track of the toggle state per player
local ghost_builder_enabled = {}

-- Event for handling the shortcut press directly
script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "ghost-builder-toggle" then
        local player = game.get_player(event.player_index)
        if not player then return end

        -- Toggle the state for this player
        ghost_builder_enabled[player.index] = not ghost_builder_enabled[player.index]

        -- Update the shortcut's toggle state
        player.set_shortcut_toggled("ghost-builder-toggle", ghost_builder_enabled[player.index])

        -- Provide feedback to the player
        if ghost_builder_enabled[player.index] then
            player.print("Auto Ghost Builder enabled")
        else
            player.print("Auto Ghost Builder disabled")
        end
    end
end)

-- Event for checking and building ghosts
script.on_event({defines.events.on_selected_entity_changed}, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    -- If the toggle state is not defined, check the button state
    if ghost_builder_enabled[player.index] == nil then
        ghost_builder_enabled[player.index] = player.is_shortcut_toggled("ghost-builder-toggle")
    end

    -- Proceed if the toggle is enabled
    if not ghost_builder_enabled[player.index] then return end

    -- Check if the player is hovering over a ghost entity
    local hovered_entity = player.selected
    if hovered_entity and hovered_entity.name == "entity-ghost" then
        -- Get the ghost's real entity name
        local entity_name = hovered_entity.ghost_name

        -- Map legacy items to new equivalents
        local legacy_item_replacements = {
            ["legacy-straight-rail"] = "straight-rail",
            ["legacy-curved-rail"] = "curved-rail"
        }

        -- Use the replacement if it exists
        local actual_item_name = legacy_item_replacements[entity_name] or entity_name

        -- Calculate the distance between the player and the ghost entity
        local distance = ((player.position.x - hovered_entity.position.x)^2 + (player.position.y - hovered_entity.position.y)^2)^0.5

        -- Check if the player is within build range and has the item in their inventory
        if distance <= player.build_distance and player.get_item_count(actual_item_name) > 0 then
            -- Attempt to revive the ghost entity
            local revived, entity = hovered_entity.revive()
            if revived then
                -- If the entity is revived, consume one item from the player's inventory
                player.remove_item({name = actual_item_name, count = 1})
            end
        end
    end
end)
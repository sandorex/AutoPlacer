-- control.lua

-- Table to keep track of the toggle state per player
local ghost_builder_enabled = {}

-- Function to toggle the state for a player
local function toggle_ghost_builder(player)
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

-- Event for handling the shortcut press directly
script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "ghost-builder-toggle" then
        toggle_ghost_builder(game.get_player(event.player_index))
    end
end)

-- Event for handling the custom key input (e.g., CONTROL + G)
script.on_event("ghost-builder-toggle", function(event)
    toggle_ghost_builder(game.get_player(event.player_index))
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
        -- Get the ghost's real entity prototype
        local ghost_prototype = hovered_entity.ghost_prototype
        if not ghost_prototype then return end

        local item_list = ghost_prototype.items_to_place_this
        local player_main_inventory = player.get_inventory(defines.inventory.character_main)
        local cursor_stack = player.cursor_stack

        -- Ensure the player can place the entity at the specified position
        if not player.can_place_entity({
            name = hovered_entity.ghost_name,
            position = hovered_entity.position,
            direction = hovered_entity.direction
        }) then return end

        -- Iterate through the item list and attempt to use one to build the entity
        for _, item in pairs(item_list) do
            -- Check if the item is available either in the player's inventory or in the cursor stack
            local has_item_in_inventory = player_main_inventory
                    and player_main_inventory.get_item_count({ name = item.name, quality = hovered_entity.quality }) > 0
            local has_item_in_cursor = cursor_stack and cursor_stack.valid_for_read
                    and cursor_stack.name == item.name and cursor_stack.quality == hovered_entity.quality

            if has_item_in_inventory or has_item_in_cursor then
                -- Attempt to remove the item and revive the ghost entity
                if has_item_in_cursor then
                    cursor_stack.count = cursor_stack.count - 1
                elseif has_item_in_inventory then
                    player_main_inventory.remove({name = item.name, count = 1, quality = hovered_entity.quality})
                end

                local revived, _ = hovered_entity.revive()
                if not revived then
                    -- Return the item if reviving the entity failed
                    player.insert({name = item.name, count = 1, quality = hovered_entity.quality})
                    player.create_local_flying_text({
                        text = "Failed to build, item returned.",
                        position = player.position,
                        color = {r = 1, g = 0, b = 0},
                        time_to_live = 600
                    })
                end
                return
            end
        end
    end
end)
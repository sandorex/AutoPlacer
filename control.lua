-- control.lua

-- name of the shortcut
local SHORTCUT = 'autoplacer-toggle'

local function is_available(player)
    return player.force.technologies["autoplacer"].researched
end

local function set_toggled(player, state)
    player.set_shortcut_toggled(SHORTCUT, state)
end

local function is_toggled(player)
    return player.is_shortcut_toggled(SHORTCUT)
end

-- Function to toggle the state for a player
local function toggle_shortcut(player)
    if not player then return end

    -- if not available force disable it and return
    if not is_available(player) then
        set_toggled(player, false)
        return
    end

    -- toggle it and alert the player
    if is_toggled(player) then
        player.print("Auto Placer disabled")
        set_toggled(player, false)
    else
        player.print("Auto Placer enabled")
        set_toggled(player, true)
    end
end

-- Event for handling the shortcut press directly
script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == SHORTCUT then
        toggle_shortcut(game.get_player(event.player_index))
    end
end)

-- Event for handling the custom key input (e.g., CONTROL + G)
script.on_event(SHORTCUT, function(event)
    toggle_shortcut(game.get_player(event.player_index))
end)

-- Event for checking and building ghosts
script.on_event({defines.events.on_selected_entity_changed}, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    -- ensure toggled
    if not is_toggled(player) then return end

    -- Check if the player is hovering over a ghost entity
    local hovered_entity = player.selected
    if hovered_entity and hovered_entity.name == "entity-ghost" then
        -- Get the ghost's real entity prototype
        local ghost_prototype = hovered_entity.ghost_prototype
        if not ghost_prototype then return end

        local item_list = ghost_prototype.items_to_place_this
        local cursor_stack = player.cursor_stack

        -- Ensure the player can place the entity at the specified position
        if not player.can_place_entity({
            name = hovered_entity.ghost_name,
            position = hovered_entity.position,
            direction = hovered_entity.direction
        }) then return end

        -- Iterate through the item list and attempt to use one to build the entity
        for _, item in pairs(item_list) do
            local has_item_in_cursor = cursor_stack and cursor_stack.valid_for_read
                    and cursor_stack.name == item.name and cursor_stack.quality == hovered_entity.quality

            if has_item_in_cursor then
                -- Attempt to remove the item and revive the ghost entity
                cursor_stack.count = cursor_stack.count - 1

                local revived, _ = hovered_entity.revive({ raise_revive = true })
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

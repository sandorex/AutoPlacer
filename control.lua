-- control.lua

-- name of the shortcut
local SHORTCUT = 'autoplacer-toggle'

-- set the state of the shortcut
local function set_toggled(player, state)
    player.set_shortcut_toggled(SHORTCUT, state)
end

-- check the state of the shortcut
local function is_toggled(player)
    return player.is_shortcut_toggled(SHORTCUT)
end

-- Function to toggle the state for a player
local function toggle_shortcut(player)
    if not player then
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

-- calculate distance between two points
local function distance_between(p1, p2)
    local x1 = p1.x
    local x2 = p2.x
    local y1 = p1.y
    local y2 = p2.y

    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- event for handling the shortcut press directly
script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == SHORTCUT then
        toggle_shortcut(game.get_player(event.player_index))
    end
end)

-- event for handling the custom key input
script.on_event(SHORTCUT, function(event)
    toggle_shortcut(game.get_player(event.player_index))
end)

-- try to place on 2 different events:
--   1. when entity hovered/selected has changed, when dragging cursor over ghosts
--   2. when cursor item changes, like switching hotbar item or using pippete
script.on_event({
    defines.events.on_selected_entity_changed,
    defines.events.on_player_cursor_stack_changed,
}, function(event)
    local player = game.get_player(event.player_index)
    if not player then
        return
    end

    -- ensure shortcut is toggled
    if not is_toggled(player) then
        return
    end

    -- check if the player is hovering over a ghost entity
    local hovered_entity = player.selected
    if hovered_entity and hovered_entity.name == "entity-ghost" then
        -- get the ghost entity prototype
        local ghost_prototype = hovered_entity.ghost_prototype
        if not ghost_prototype then
            return
        end

        -- prevent player from placing things outside the build range
        local distance = distance_between(hovered_entity.position, player.position)
        if distance > player.build_distance then
            return
        end

        local item_list = ghost_prototype.items_to_place_this
        local cursor_stack = player.cursor_stack

        -- prevent trying to build on any kind of colliding entity, including terrain
        --
        -- NOTE: used surface version of the function to prevent issues with entities that can be
        -- replaced like placing belts over underground belts
        if not player.surface.can_place_entity({
            name = hovered_entity.ghost_name,
            position = hovered_entity.position,
            direction = hovered_entity.direction,
            force = player.force,
            build_check_type = defines.build_check_type.ghost_revive,
        }) then
            return
        end

        -- check if item in cursor can be used to build the hovered ghost
        for _, item in pairs(item_list) do
            local has_item_in_cursor = cursor_stack
                and cursor_stack.valid_for_read
                and cursor_stack.name == item.name
                and cursor_stack.quality == hovered_entity.quality

            if has_item_in_cursor then
                -- decrement the item count
                cursor_stack.count = cursor_stack.count - 1

                local revived, _ = hovered_entity.revive({ raise_revive = true })
                if not revived then
                    -- last fallback if for some reason the revive fails
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

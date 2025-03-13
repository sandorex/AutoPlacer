-- data.lua

data:extend{
    {
        type = "custom-input",
        name = "autoplacer-toggle",
        key_sequence = "CONTROL + G",
        consuming = "none",
    },
    {
        type = 'technology',
        name = 'autoplacer',
        icons = {
            {
                icon = "__autoplacer__/graphics/icon-512.png",
                icon_size = 512,
            },
        },
        prerequisites = { 'logistic-science-pack' },
        research_trigger = {
            type = "craft-item",
            item = "logistic-science-pack",
            count = 1
        }
    },
    {
        type = "shortcut",
        name = "autoplacer-toggle",
        order = "a[auto]-p[placer]",
        action = "lua",
        technology_to_unlock = "autoplacer",
        unavailable_until_unlocked = true,
        toggleable = true,
        localised_name = {"autoplacer.gui.toggle-button"},
        associated_control_input = "autoplacer-toggle",
        icons = {
            {
                icon = "__autoplacer__/graphics/icon-32.png",
                icon_size = 32,
            },
        },
        small_icons = {
            {
                icon = "__autoplacer__/graphics/icon-32.png",
                icon_size = 32,
            },
        },
    }
}

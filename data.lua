-- data.lua

data:extend{
    {
        type = "custom-input",
        name = "ghost-builder-toggle",
        key_sequence = "CONTROL + G",
        consuming = "none",
    },
    {
        type = 'technology',
        name = 'ghost-builder',
        icons = {
            {
                icon = "__AutoGhostBuilder__/graphics/ghost-a-512.png",
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
        name = "ghost-builder-toggle",
        order = "a[ghost]-b[builder]",
        action = "lua",
        technology_to_unlock = "ghost-builder",
        unavailable_until_unlocked = true,
        toggleable = true,
        localised_name = {"autoghostbuilder.gui.toggle-button"},
        associated_control_input = "ghost-builder-toggle",
        icons = {
            {
                icon = "__AutoGhostBuilder__/graphics/ghost-a.png",
                icon_size = 32,
                scale = 1,
            },
        },
        small_icons = {
            {
                icon = "__AutoGhostBuilder__/graphics/ghost-a-24.png",
                icon_size = 24,
                scale = 1,
            },
        },
        disabled_icons = {
            {
                icon = "__AutoGhostBuilder__/graphics/ghost-b.png",
                icon_size = 32,
                scale = 1,
            },
        },
        disabled_small_icons = {
            {
                icon = "__AutoGhostBuilder__/graphics/ghost-b-24.png",
                icon_size = 24,
                scale = 1,
            },
        },
    }
}

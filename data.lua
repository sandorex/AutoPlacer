-- data.lua

data:extend{
    {
        type = "custom-input",
        name = "autoplacer-toggle",
        key_sequence = "CONTROL + G",
        consuming = "none",
    },
    {
        type = "shortcut",
        name = "autoplacer-toggle",
        order = "a[auto]-p[placer]",
        action = "lua",
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

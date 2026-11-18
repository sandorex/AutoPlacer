-- settings.lua

data:extend{
    {
        type = "bool-setting",
        name = "autoplacer-auto-mine-marked",
        setting_type = "runtime-per-user",
        default_value = false,
        order = "a[autoplacer]-a[auto-mine-marked]",
    },
}

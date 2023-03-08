data:extend({
	{
		type = "string-setting",
		name = "wh-sizes",
		setting_type = "startup",
		order = "A",
		default_value = "2;4",
	},
	{
		type = "bool-setting",
		name = "wh-enable-logistic",
		order = "B",
		setting_type = "startup",
		default_value = true,
	},
	{
		type = "bool-setting",
		name = "wh-enable-advanced-logistic",
		order = "C",
		setting_type = "startup",
		default_value = false,
	},
	{
		type = "bool-setting",
		name = "wh-validate-on-join",
		order = "D",
		setting_type = "startup",
		default_value = true,
	},
	{
		type = "int-setting",
		name = "wh-wagon-size",
		order = "E",
		setting_type = "startup",
		default_value = 40,
	},
	{
		type = "int-setting",
		name = "wh-storage-multiplier",
		order = "F",
		setting_type = "startup",
		default_value = 2,
	},
	{
		type = "bool-setting",
		name = "wh-limit-chest-size",
		order = "G",
		setting_type = "startup",
		default_value = true,
	},
})

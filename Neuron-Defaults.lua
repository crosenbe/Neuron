--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2020.

NeuronDefaultBarOptions = {}

NeuronDefaultBarOptions.ActionBar = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 55,
		showGrid = true,
		multiSpec = true,
		vehicle = true,
		possess = true,
		override = true,

		buttons = {
			[1] = {
				keys = { hotKeys = ":1:", hotKeyText = ":1:",},
			},
			[2] = {
				keys = { hotKeys = ":2:", hotKeyText = ":2:",},
			},
			[3] = {
				keys = { hotKeys = ":3:", hotKeyText = ":3:",},
			},
			[4] = {
				keys = { hotKeys = ":4:", hotKeyText = ":4:",},
			},
			[5] = {
				keys = { hotKeys = ":5:", hotKeyText = ":5:",},
			},
			[6] = {
				keys = { hotKeys = ":6:", hotKeyText = ":6:",},
			},
			[7] = {
				keys = { hotKeys = ":7:", hotKeyText = ":7:",},
			},
			[8] = {
				keys = { hotKeys = ":8:", hotKeyText = ":8:",},
			},
			[9] = {
				keys = { hotKeys = ":9:", hotKeyText = ":9:",},
			},
			[10] = {
				keys = { hotKeys = ":0:", hotKeyText = ":0:",},
			},
			[11] = {
				keys = { hotKeys = ":-:", hotKeyText = ":-:",},
			},
			[12] = {
				keys = { hotKeys = ":=:", hotKeyText = ":=:",},
			},
		},
	},

	[2] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 100,
		showGrid = true,

		buttons = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {},
			[7] = {},
			[8] = {},
			[9] = {},
			[10] = {},
			[11] = {},
			[12] = {},
		},
	}
}

NeuronDefaultBarOptions.ZoneAbilityBar = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		showGrid = false,
		point = "BOTTOM",
		x = 350,
		y = 75,
		border = true,

		buttons = {
			[1] = {},
		},
	}
}

NeuronDefaultBarOptions.ExtraBar = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 205,

		buttons = {
			[1] = {},
		},
	}
}

NeuronDefaultBarOptions.BagBar = {
	[1] = {
		padH = 0,
		scale = 1.1,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOMRIGHT",
		x = -102,
		y = 24,

		buttons = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
		},
	}
}

NeuronDefaultBarOptions.StatusBar = {
	[1] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 385,

		buttons = {
			[1] = {
				config = {sbType = "cast", cIndex = 1, lIndex = 2, rIndex = 3, showIcon = true},
			}
		},

	},

	[2] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 24,

		buttons = {
			[1] = {
				config = { sbType = "xp", cIndex = 2, lIndex = 6, rIndex = 4, mIndex = 3, width = 450},
			},
		},
	},

	[3] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 7,

		buttons = {
			[1] = {
				config = { sbType = "rep", cIndex = 3, lIndex = 2, rIndex = 4, mIndex = 6, width = 450},
			},
		},
	},

	[4] = {
		showGrid = true,
		columns = 1,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "TOP",
		x = 0,
		y = -123,

		buttons = {
			[1] = {
				config = { sbType = "mirror", cIndex = 1, lIndex = 2, rIndex = 3},
			},
			[2] = {
				config = { sbType = "mirror", cIndex = 1, lIndex = 2, rIndex = 3},
			},
			[3] = {
				config = { sbType = "mirror", cIndex = 1, lIndex = 2, rIndex = 3},
			},
		},


	}
}

NeuronDefaultBarOptions.ExitBar = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 305,

		buttons = {
			[1] = {},
		},
	}
}

NeuronDefaultBarOptions.MenuBar = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOMRIGHT",
		x = -348,
		y = 24,

		buttons = {},
	}
}

for i = 1,#MICRO_BUTTONS do
	NeuronDefaultBarOptions.MenuBar[1].buttons[i] = {}
end

NeuronDefaultBarOptions.PetBar = {
	[1] = {
		hidestates = ":pet0:",
		showGrid = true,
		scale = 0.8,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = -440,
		y = 75,

		buttons = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {},
			[7] = {},
			[8] = {},
			[9] = {},
			[10] = {},
		},
	}
}
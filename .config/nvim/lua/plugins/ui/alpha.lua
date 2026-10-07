return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-mini/mini.icons",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			[[                                                    -         ]],
			[[                     :........                      =         ]],
			[[                     ..::::.:.::                   --         ]],
			[[                     =**#**##*-::                  -+         ]],
			[[                     **+=+++*%%#=                ::-+         ]],
			[[                     +==-+=++=**            .:::--==          ]],
			[[                      --=+-==-=        ......--==             ]],
			[[                    ::---===-*:............:::                ]],
			[[                  ....::+**=::--:....:.::::::                 ]],
			[[               .:...--:.:::-:*::-.:::.::::-                   ]],
			[[              :.-=-:::....:%=:::--:::::-                      ]],
			[[             ...:.:::-+...#::-:+---:                          ]],
			[[             .:..:..:::=.:::+:-=-=                            ]],
			[[            ....-###-::-#=-*::#::+                            ]],
			[[           ..:.:-:===---*=+:-**-*                             ]],
			[[          ....:.::::-=-:%=:-**-*#                             ]],
			[[          .::::*:::++=:+#:-*+-*#                              ]],
			[[         ...-::*.:::#:+%==:-:::#                              ]],
			[[         ....##:-::::#%%%#*.+###                              ]],
			[[         ....%%%%%%%%#%%%%%%%%#                               ]],
			[[          -:%%%%%%%%%%%%%###%%                                ]],
			[[           +%%%%%%#%%%%%%%%%%%                                ]],
			[[           %%%%%%#%%%%%%%%%%%%                                ]],
			[[           %%%%%%%%%#%%%%%####                                ]],
			[[           %%%%#%%%%%%#%%%%%%                                 ]],
			[[           %%%#%%%%%%######%%                                 ]],
			[[          %%%#%%%%%%%%%#%%%%#                                 ]],
			[[          %#%%%%%%%%#%####%%                                  ]],
			[[         %%%%%%%%%%%######%%                                  ]],
		}

		dashboard.section.buttons.val = {
			dashboard.button("f", "󰱼  Find file", ":FzfLua files<CR>"),
			dashboard.button("r", "󰄉  Recent files", ":FzfLua oldfiles<CR>"),
			dashboard.button("g", "󰊄  Find text", ":FzfLua live_grep<CR>"),
			dashboard.button("n", "  New file", ":ene <BAR> startinsert<CR>"),
			dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
			dashboard.button("q", "󰅚  Quit", ":qa<CR>"),
		}

		alpha.setup(dashboard.config)

		alpha.setup(dashboard.config)
	end,
}

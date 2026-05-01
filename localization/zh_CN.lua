return {
    descriptions = {
        Other = {
            disabled = {
				name = "已禁用",
				text = {
					"在对局中",
					"不再出现",
				},
			},
			slib_perma_plus_asc = {
				text = {
					"{C:gold}#1#{} 晋升强度"
				}
			},
			slib_perma_h_plus_asc = {
				text = {
					"留在手中时提供 {C:gold}#1#{} 晋升强度"
				}
			},
			slib_perma_x_asc = {
				text = {
					"{X:money,C:white}X#1#{} 晋升强度"
				}
			},
			slib_perma_h_asc = {
				text = {
					"留在手中时提供 {X:money,C:white}X#1#{} 晋升强度"
				}
			},
			slib_perma_exp_asc = {
				text = {
					"{X:money,C:white}^#1#{} 晋升强度" -- 作者注：我不知道这应该是什么颜色，随便猜的
				}
			},
			slib_perma_h_exp_asc = {
				text = {
					"留在手中时提供 {X:money,C:white}^#1#{} 晋升强度"
				}
			},
			slib_perma_xlog_chips = {
				text = {
					"{X:chips,C:white}Xlog_#1#(筹码){} 筹码"
				}
			},
			slib_perma_h_xlog_chips = {
				text = {
					"留在手中时提供 {X:chips,C:white}Xlog_#1#(筹码){} 筹码"
				}
			},
			slib_perma_xlog_mult = {
				text = {
					"{X:mult,C:white}Xlog_#1#(倍率){} 倍率"
				}
			},
			slib_perma_h_xlog_mult = {
				text = {
					"留在手中时提供 {X:mult,C:white}Xlog_#1#(倍率){} 倍率"
				}
			},
			entr_card_suit_level = {
				text = {
					"--------------",
					"{S:0.8,V:1}#1#{} {S:0.8}({S:0.8,V:2}lvl.#4#{})",
					"{C:blue}+#2#{} 筹码, {C:mult}+#3#{} 倍率",
				}
			},
			entr_card_suit_level_chips = {
				text = {
					"--------------",
					"{S:0.8,V:1}#1#{} {S:0.8}({S:0.8,V:2}lvl.#4#{})",
					"{C:blue}+#2#{} 筹码",
				}
			},
			entr_card_suit_level_mult = {
				text = {
					"--------------",
					"{S:0.8,V:1}#1#{} {S:0.8}({S:0.8,V:2}lvl.#4#{})",
					"{C:mult}+#3#{} 倍率",
				}
			},
			slib_perma_e_chips = {
				text = {
					"{X:slib_echips,C:white}^#1#{} 筹码"
				}
			},
			slib_perma_h_e_chips = {
				text = {
					"留在手中时提供 {X:slib_echips,C:white}^#1#{} 筹码"
				}
			},
			slib_perma_e_mult = {
				text = {
					"{X:slib_emult,C:white}^#1#{} 倍率"
				}
			},
			slib_perma_h_e_mult = {
				text = {
					"留在手中时提供 {X:slib_emult,C:white}^#1#{} 倍率"
				}
			},
        }
    },
    misc = {
        dictionary = {
            cry_gameset_explanation = {
				"选择一个游戏设置集",
				"应用到此卡上。",
			},
            -- 作者注：它不知为何崩溃了，所以除此之外的所有选项只能被设定为禁用
			cry_gameset_disabled = "已禁用",
			cry_gameset_modest = "已禁用",
			cry_gameset_mainline = "已启用",
			cry_gameset_madness = "已禁用",
			cry_gameset_custom = "已禁用",
			cry_gameset_exp = "已禁用",

			k_content_set = "主题集合",
			b_content_sets = "主题集合",
			cry_view_set_contents = "查看集合内项目",
			cry_set_enable_features = "使用此选项卡来启用或禁用整个主题集合。",
			cry_family = "家庭友好模式",

			slib_exp_colours = "指数筹码与倍率的颜色",
			slib_exp_colour_1 = "默认",
			slib_exp_colour_2 = "经典 (G.C.DARK_EDITION)",

			b_tag = "标签",
			b_blind = "盲注",
			k_mult = "倍率",
			k_chips = "筹码",

			cry_balanced_q = "这平衡吗...？",
			slib_forcetrigger_ex = "强制触发！",
			slib_plus_consumable = "+1 消耗牌",
        },
        v_dictionary = {
        	a_xchips = "X#1# 筹码",
			a_powmult = "^#1# 倍率",
			a_powchips = "^#1# 筹码",
			a_powmultchips = "^#1# 倍率+筹码",
			a_round = "+#1# 回合",
			a_xchips_minus = "-X#1# 筹码",
			a_powmult_minus = "-^#1# 倍率",
			a_powchips_minus = "-^#1# 筹码",
			a_powmultchips_minus = "-^#1# 倍率+筹码",
			a_round_minus = "-#1# 回合",
			a_tag_minus = "-#1# 标签",
			a_tags_minus = "-#1# 标签",
			a_tag = "+#1# 标签",
			a_tags = "+#1# 标签",
			a_eq_chips = "=#1# 筹码",
			a_eq_mult = "=#1# 倍率",
			a_xasc = "X#1# 晋升强度",
			a_xasc_minus = "-X#1# 晋升强度",
			a_asc = "+#1# 晋升强度",
			a_asc_minus = "#1# 晋升强度",
			a_exp_asc = "^#1# 晋升强度",
			a_exp_asc_minus = "-^#1# 晋升强度",
			a_escore = "^#1# 分数",
			a_eescore = "^^#1# 分数",
			a_eblindsize = "^#1# 盲注规模",
			a_eeblindsize = "^^#1# 盲注规模"
		},
		suits_singular = {
			suitless = "无花色"
		},
		suits_plural = {
			suitless = "无花色"
		}
    }
}

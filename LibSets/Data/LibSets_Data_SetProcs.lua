--Check if the library was loaded before already w/o chat output
--if IsLibSetsAlreadyLoaded(false) then return end

--This file the sets data and info (pre-loaded from the specified API version)
--It should be updated each time the APIversion increases to contain the new/changed data
--local lib = LibSets

--local tins = table.insert

------------------------------------------------------------------------------------------------------------------------
--> Last updated: API 101047, 2025-08-21, Baertram
------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
--Current APIversion is live or PTS check
--local isPTSAPIVersionLive = lib.checkIfPTSAPIVersionIsLive()
---------------------------------------------------------------------------------------------------------------------------


--local setDataPreloaded = lib.setDataPreloaded

------------------------------------------------------------------------------------------------------------------------
--  IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT
------------------------------------------------------------------------------------------------------------------------
-- [SET PROCS LAST UPDATE: 14.03.2021, API10034, Baertram] -> CURRENTLY NOT FURTHER SUPPORTED! NOT UPDATED!!!
-- Data provided by ExoY (and the internet + furthe ringaem tests).
-- See addon ExoYs ProcSet timer: https://www.esoui.com/downloads/info2783-ExoYsProcSetTimer.html (it's not using LibSets!)

    --The set procs
    --Generated lua code coming from file LibSets_SetData.xlsx -> tab SetProcs, column g "Lua table coce of set procs".
    -->Copy the code and as it's multiline Excel will add "" :-( Search and replace the double "" first with ". Then search for "[ and replace with [.
    -->Afterwards search for regex "\n and replace with \n
    -->Then lua minify the tables!
    --
    --The base format of each table entry will be:
    --[[
    [number setId] = {
        [number LIBSETS_SETPROC_CHECKTYPE_ constant from LibSets_ConstantsLibraryInternal.lua] = {
            [number index1toN] = {
                ["abilityIds"] = {number abilityId1, number abilityId2, ...},
                    --Only for LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_EFFECT_CHANGED
                    ["unitTag"] = String unitTag e.g. "player", "playerpet", "group", "boss", etc.,

                    --Only for LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT
                    ["source"] = number combatUnitType e.g. COMBAT_UNIT_TYPE_PLAYER
                    ["target"] = number combatUnitType e.g. COMBAT_UNIT_TYPE_PLAYER

                    --Only for LIBSETS_SETPROC_CHECKTYPE_EVENT_POWER_UPDATE
                    ["powerType"] = number powerType e.g. POWERTYPE_STAMINA

                    --Only for LIBSETS_SETPROC_CHECKTYPE_EVENT_BOSSES_CHANGED
                    ["unitTag"] = String unitTagOfBoss e.g. boss1, boss2, ...

                    --Only for LIBSETS_SETPROC_CHECKTYPE_SPECIAL
                    [number index1toN] = boolean specialFunctionIsGiven e.g. true/false (if true: the abilityId1's callback function should run a special                                             function as well, which will be registered for the

                ["cooldown"] = {number cooldownForAbilityId1 e.g. 12000, number cooldownForAbilityId2, ...},
                ["icon"] = String iconPathOfTheBuffIconToUse e.g. "/esoui/art/icons/ability_buff_minor_vitality.dds"
            },
        },
        [number LIBSETS_SETPROC_CHECKTYPE_ constant from LibSets_ConstantsLibraryInternal.lua] = {
        ...
        },
        ...
        --String comment name of the set -> description of the proc EN / description of the proc DE
    },
    ]]
    --[[
    2022-04-20, Disabled
    [LIBSETS_TABLEKEY_SET_PROCS] = {
------------------------------------------------------------------------------------------------------------------------
        [147] = {[LIBSETS_SETPROC_CHECKTYPE_EVENT_POWER_UPDATE] = {
            [1] = {
              ["unitTag"] = "player",
              ["powerType"] = POWERTYPE_STAMINA,
                  },
        },
        [LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {127070},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
              ["cooldown"] = {8000},
                  },
          },
        [LIBSETS_SETPROC_CHECKTYPE_SPECIAL] = {
            [1] = true,
        },},     --Way of Martial Knowledge ->  / "
        [160] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {61459},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
              ["cooldown"] = {12000},
                  },
          },},     --Burning Spellweave ->  / "
        [167] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
        [1] = {
              ["abilityIds"] = {59590},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
        },},     --Nightflame ->  / "
        [180] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {61771},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
                  },
          },},     --Powerful Assault ->  / "
        [181] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {65706},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
                  },
          },},     --Meritorious Service ->  / "
        [185] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {66902},
              ["cooldown"] = {5000},
            --Attention: No source COMBAT_UNIT_TYPE_PLAYER here!
                  },
          },},     --Spell Power Cure ->  / "
        [211] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {71107},
              ["cooldown"] = {15000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Permafrost ->  / "
        [225] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {75746},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
                  },
          },},     --Clever Alchemist ->  / "
        [230] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {75801, 75804},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
                  },
          },},     --Moondancer -> 1: Lunar blessing (magReg), 2: Shadow blessing (spellPower) / "
        [268] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {81036},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
              ["cooldown"] = {15000},
            },
          },},     --Sentinel of Rkugamz ->  / "
        [271] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
        [1] = {
              ["abilityIds"] = {80545},
              ["cooldown"] = {6000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
        }},     --Sellistrix ->  / "
        [276] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
        [1] = {
              ["abilityIds"] = {80865},
              ["cooldown"] = {7000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
        }},     --Tremorscale ->  / "
        [280] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
        [1] = {
              ["abilityIds"] = {84504},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
        }},     --Grothdarr -> Grothdarr proc 1 / "
        [341] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {97855},
              ["cooldown"] = {20000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
                  },
          },},     --Earthgore ->  / "
        [353] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {99204},
              ["cooldown"] = {18000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Mechanical Acuity ->  / "
        [391] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {107141},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Vestment of Olorime ->  / "
        [395] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {109084},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Perfect Vestment of Olorime ->  / "
        [446] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
        [1] = {
              ["abilityIds"] = {121878},
              ["cooldown"] = {8000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
        }},     --Claw of Yolnakhriin ->  / "
        [451] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
        [1] = {
              ["abilityIds"] = {121878},
              ["cooldown"] = {8000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
        }},     --Perfected Claw of Yolnakhriin ->  / "
        [452] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {126924},
              ["cooldown"] = {9000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
                  },
          },},     --Hollowfang Thirst ->  / "
        [455] = {[LIBSETS_SETPROC_CHECKTYPE_EVENT_BOSSES_CHANGED] = {
            [1] = {
              ["abilityIds"] = {126597},
              ["cooldown"] = {22000}
                  },
          },
        [LIBSETS_SETPROC_CHECKTYPE_SPECIAL] = {
            [1] = true,
        },},     --Z'en's Redress ->  / "
        [471] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {133210},
              ["cooldown"] = {12000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
        },
          },},     --Hiti\'s Hearth ->  / "
        [487] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {135659},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Winter's Respite ->  / "
        [488] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {135690},
              ["cooldown"] = {15000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Venomous Smite ->  / "
        [492] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {136098},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Kyne's Wind ->  / "
        [493] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {137995},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Perfected Kyne's Wind ->  / "
        [496] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {135923},
              ["debuffIds"] = {135924},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
              ["cooldown"] = {22000},
                  },
        },
        [LIBSETS_SETPROC_CHECKTYPE_SPECIAL] = {
            [1] = true,
        },},     --Roaring Opportunist ->  / "
        [497] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {137986},
              ["debuffIds"] = {137985},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
              ["cooldown"] = 22000
                  },
        },
        [LIBSETS_SETPROC_CHECKTYPE_SPECIAL] = {
            [1] = true,
           },},     --Perfected Roaring Opportunist ->  / "
        [535] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
        [1] = {
              ["abilityIds"] = {141905},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
        }},     --Lady Thorn ->  / "
        [558] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {147747},
              ["cooldown"] = {13000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Void Bash ->  / "
        [561] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {147858},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Wrath of Elements ->  / "
        [562] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {147875},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Force Overflow ->  / "
        [564] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {147747},
              ["cooldown"] = {13000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Perfected Void Bash ->  / "
        [567] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {147858},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Perfected Wrath of Elements ->  / "
        [568] = {[LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT] = {
            [1] = {
              ["abilityIds"] = {147875},
              ["cooldown"] = {10000},
              ["source"] = COMBAT_UNIT_TYPE_PLAYER,
            },
          },},     --Perfected Force Overflow ->  / "
    }, --LIBSETS_TABLEKEY_SET_PROCS
    ]]
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

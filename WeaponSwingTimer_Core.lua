local addon_name, addon_data = ...
local L = addon_data.localization_table


addon_data.core = {}

addon_data.core.core_frame = CreateFrame("Frame", addon_name .. "CoreFrame", UIParent)
addon_data.core.core_frame:RegisterEvent("ADDON_LOADED")

addon_data.core.all_timers = {
    addon_data.player, addon_data.target
}

local version = "4.1.0"

local load_message = L["Thank you for installing WeaponSwingTimer Version"] .. " " .. version .. 
                     " " .. L["by LeftHandedGlove! Use |cFFFFC300/wst|r for more options."]
                     
addon_data.core.default_settings = {
    one_frame = false
}

addon_data.core.in_combat = false

local swing_reset_spells = {}
swing_reset_spells['DRUID'] = {
    -- --[[ Abolish Poison ]]           2893,
    -- --[[ Aquatic Form ]]             1066,
    -- --[[ Barkskin ]]                 22812,
    -- --[[ Bash ]]                     5211, 6798, 8983,
    -- --[[ Bear Form ]]                5487,
    -- --[[ Cat Form ]]                 768,
    -- --[[ Challenging Roar ]]         5209,
    -- --[[ Claw ]]                     1082, 3029, 5201, 9849, 9850,
    -- --[[ Cower ]]                    8998, 9000, 9892,
    -- --[[ Cure Poison ]]              8946,
    -- --[[ Dash ]]                     1850, 9821,
    -- --[[ Demoralizing Roar ]]        99, 1735, 9490, 9747, 9898,
    -- --[[ Dire Bear Form ]]           9634,
    -- --[[ Enrage ]]                   5229,
    -- --[[ Entangling Roots ]]         339, 1062, 5195, 5196, 9852, 9853,
    -- --[[ Faerie Fire ]]              770, 778, 9749, 9907, 
    -- --[[ Faerie Fire (Feral) ]]      16857, 17390, 17391, 17392, 
    -- --[[ Feral Charge ]]             16979, 
    -- --[[ Ferocious Bite ]]           22568, 22827, 22828, 22829, 31018,
    -- --[[ Frenzied Regeneration ]]    
    -- --[[ Gift of the Wild ]]
    -- --[[ Growl ]]
    -- --[[ Healing Touch ]]
    -- --[[ Hibernate ]]
    -- --[[ Hurricane ]]
    -- --[[ Innervate ]]
    -- --[[ Insect Storm ]]
    -- --[[ Mark of the Wild ]]
    --[[ Maul ]]                        6807, 6808, 6809, 8972, 9745, 9880, 9881
    -- --[[ Moonfire ]]
    -- --[[ Moonkin Form ]]
    -- --[[ Nature's Grasp ]]
    -- --[[ Nature's Swiftness ]]
    -- --[[ Omen of Clarity ]]
    -- --[[ Pounce ]]
    -- --[[ Prowl ]]
    -- --[[ Rake ]]
    -- --[[ Ravage ]]
    -- --[[ Rebirth ]]
    -- --[[ Regrowth ]]
    -- --[[ Rejuvenation ]]
    -- --[[ Remove Curse ]]
    -- --[[ Rip ]]
    -- --[[ Shred ]]
    -- --[[ Soothe Animal ]]
    -- --[[ Starfire ]]
    -- --[[ Swiftmend ]]
    -- --[[ Swipe ]]
    -- --[[ Teleport: Moonglade ]]
    -- --[[ Thorns ]]
    -- --[[ Tiger's Fury ]]
    -- --[[ Track Humanoids ]]
    -- --[[ Tranquility ]]
    -- --[[ Travel Form ]]
    -- --[[ Wrath ]]
}
swing_reset_spells['HUNTER'] = {
    -- --[[ Aimed Shot ]]
    -- --[[ Arcane Shot ]]
    -- --[[ Aspect of the Beast ]]
    -- --[[ Aspect of the Cheetah ]]
    -- --[[ Aspect of the Hawk ]]
    -- --[[ Aspect of the Monkey ]]
    -- --[[ Aspect of the Pack ]]
    -- --[[ Aspect of the Wild ]]
    -- --[[ Auto Shot ]]
    -- --[[ Beast Lore ]]
    -- --[[ Bestial Wrath ]]
    -- --[[ Call Pet ]]
    -- --[[ Concussive Shot ]]
    -- --[[ Counterattack ]]
    -- --[[ Deterrence ]]
    -- --[[ Disengage ]]
    -- --[[ Dismiss Pet ]]
    -- --[[ Distracting Shot ]]
    -- --[[ Eagle Eye ]]
    -- --[[ Explosive Trap ]]
    -- --[[ Eyes of the Beast ]]
    -- --[[ Feed Pet ]]
    -- --[[ Feign Death ]]
    -- --[[ Flare ]]
    -- --[[ Freezing Trap ]]
    -- --[[ Frost Trap ]]
    -- --[[ Hunter's Mark ]]
    -- --[[ Immolation Trap ]]
    -- --[[ Intimidation ]]
    -- --[[ Mend Pet ]]
    -- --[[ Mongoose Bite ]]
    -- --[[ Multi-Shot ]]
    -- --[[ Rapid Fire ]]
    --[[ Raptor Strike ]]               2973, 14260, 14261, 14262, 14263, 14264, 14265, 14266,
    -- --[[ Readiness ]]
    -- --[[ Revive Pet ]]
    -- --[[ Scare Beast ]]
    -- --[[ Scatter Shot ]]
    -- --[[ Scorpid Sting ]]
    -- --[[ Serpent Sting ]]
    -- --[[ Tame Beast ]]
    -- --[[ Throw ]]
    -- --[[ Track Beast ]]
    -- --[[ Track Demons ]]
    -- --[[ Track Dragonkin ]]
    -- --[[ Track Elements ]]
    -- --[[ Track Giants ]]
    -- --[[ Track Hidden ]]
    -- --[[ Track Humanoids ]]
    -- --[[ Track Undead ]]
    -- --[[ Tranquilizing Shot ]]
    -- --[[ Trueshot Aura ]]
    -- --[[ Viper Sting ]]
    -- --[[ Volley ]]
    -- --[[ Wing Clip ]]
    -- --[[ Wyvern Sting ]]
}
swing_reset_spells['MAGE'] = {
    -- --[[ Amplify Magic ]]
    -- --[[ Arcane Brilliance ]]
    -- --[[ Arcane Explosion ]]
    -- --[[ Arcane Intellect ]]
    -- --[[ Arcane Missles ]]
    -- --[[ Arcane Power ]]
    -- --[[ Blast Wave ]]
    -- --[[ Blink ]]
    -- --[[ Blizzard ]]
    -- --[[ Cold Snap ]]
    -- --[[ Combustion ]]
    -- --[[ Cone of Cold ]]
    -- --[[ Counterspell ]]
    -- --[[ Dampen Magic ]]
    -- --[[ Detect Magic ]]
    -- --[[ Evocation ]]
    -- --[[ Fire Blast ]]
    -- --[[ Fire Ward ]]
    -- --[[ Fireball ]]
    -- --[[ Flamestrike ]]
    -- --[[ Frost Armor ]]
    -- --[[ Frost Nova ]]
    -- --[[ Frost Ward ]]
    -- --[[ Frostbolt ]]
    -- --[[ Ice Armor ]]
    -- --[[ Ice Barrier ]]
    -- --[[ Ice Block ]]
    -- --[[ Mage Armor ]]
    -- --[[ Mana Shield ]]
    -- --[[ Polymorph ]]
    -- --[[ Polymorph: Cow ]]
    -- --[[ Polymorph: Pig ]]
    -- --[[ Polymorph: Turtle ]]
    -- --[[ Portal: Darnassus ]]
    -- --[[ Portal: Ironforge ]]
    -- --[[ Portal: Orgimmar ]]
    -- --[[ Portal: Stormwind ]]
    -- --[[ Portal: Thunder Bluff ]]
    -- --[[ Portal: Undercity ]]
    -- --[[ Presence of Mind ]]
    -- --[[ Pyroblast ]]
    -- --[[ Remove Lesser Curse ]]
    -- --[[ Scorch ]]
    -- --[[ Shoot ]]
    -- --[[ Slow Fall ]]
    -- --[[ Teleport: Darnassus ]]
    -- --[[ Teleport: Ironforge ]]
    -- --[[ Teleport: Orgimmar ]]
    -- --[[ Teleport: Stormwind ]]
    -- --[[ Teleport: Thunder Bluff ]]
    -- --[[ Teleport: Undercity ]]
    -- --[[ Conjure Food ]]
    -- --[[ Conjure Mana Agate ]]
    -- --[[ Conjure Mana Citrine ]]
    -- --[[ Conjure Mana Jade ]]
    -- --[[ Conjure Mana Ruby ]]
    -- --[[ Conjure Water ]]
}
swing_reset_spells['PALADIN'] = {
    -- --[[ Blessing of Freedom ]]
    -- --[[ Blessing of Kings ]]
    -- --[[ Blessing of Light ]]
    -- --[[ Blessing of Might ]]
    -- --[[ Blessing of Protection ]]
    -- --[[ Blessing of Sacrifice ]]
    -- --[[ Blessing of Salvation ]]
    -- --[[ Blessing of Sanctuary ]]
    -- --[[ Blessing of Wisdom ]]
    -- --[[ Cleanse ]]
    -- --[[ Concentration Aura ]]
    -- --[[ Consecration ]]
    -- --[[ Devotion Aura ]]
    -- --[[ Divine Favor ]]
    -- --[[ Divine Intervention ]]
    -- --[[ Divine Protection ]]
    -- --[[ Divine Shield ]]
    -- --[[ Exorcism ]]
    -- --[[ Fire Resistance Aura ]]
    -- --[[ Flash of Light ]]
    -- --[[ Frost Resistance Aura ]]
    -- --[[ Greater Blessing of Kings ]]
    -- --[[ Greater Blessing of Light ]]
    -- --[[ Greater Blessing of Might ]]
    -- --[[ Greater Blessing of Salvation ]]
    -- --[[ Greater Blessing of Sanctuary ]]
    -- --[[ Greater Blessing of Wisdom ]]
    -- --[[ Hammer of Justice ]]
    -- --[[ Hammer of Wrath ]]
    -- --[[ Holy Light ]]
    -- --[[ Holy Shield ]]
    -- --[[ Holy Shock ]]
    -- --[[ Holy Wrath ]]
    -- --[[ Judgement ]]
    -- --[[ Lay on Hands ]]
    -- --[[ Purify ]]
    -- --[[ Redemption ]]
    -- --[[ Repentance ]]
    -- --[[ Retribution Aura ]]
    -- --[[ Righteous Fury ]]
    -- --[[ Sanctity Aura ]]
    -- --[[ Seal of Command ]]
    -- --[[ Seal of Justice ]]
    -- --[[ Seal of Light ]]
    -- --[[ Seal of Righteousness ]]
    -- --[[ Seal of the Crusader ]]
    -- --[[ Seal of Wisdom ]]
    -- --[[ Sense Undead ]]
    -- --[[ Shadow Resistance Aura ]]
    -- --[[ Summon Charger ]]
    -- --[[ Summon Warhorse ]]
    -- --[[ Turn Undead ]]
}
swing_reset_spells['PRIEST'] = {
    -- --[[ Abolish Disease ]]
    -- --[[ Cure Disease ]]
    -- --[[ Desperate Prayer ]]
    -- --[[ Devouring Plague ]]
    -- --[[ Dispel Magic ]]
    -- --[[ Divine Spirit ]]
    -- --[[ Fade ]]
    -- --[[ Fear Ward ]]
    -- --[[ Feedback ]]
    -- --[[ Flash Heal ]]
    -- --[[ Greater Heal ]]
    -- --[[ Heal ]]
    -- --[[ Hex of Weakness ]]
    -- --[[ Holy Fire ]]
    -- --[[ Holy Nova ]]
    -- --[[ Inner Fire ]]
    -- --[[ Inner Focus ]]
    -- --[[ Lesser Heal ]]
    -- --[[ Levitate ]]
    -- --[[ Lightwell ]]
    -- --[[ Mana Burn ]]
    -- --[[ Mind Blast ]]
    -- --[[ Mind Control ]]
    -- --[[ Mind Flay ]]
    -- --[[ Mind Soothe ]]
    -- --[[ Mind Vision ]]
    -- --[[ Power Infusion ]]
    -- --[[ Power Word: Fortitude ]]
    -- --[[ Power Word: Shield ]]
    -- --[[ Prayer of Fortitude ]]
    -- --[[ Prayer of Healing ]]
    -- --[[ Prayer of Shadow Protection ]]
    -- --[[ Prayer of Spirit ]]
    -- --[[ Psychic Scream ]]
    -- --[[ Renew ]]
    -- --[[ Resurrection ]]
    -- --[[ Shackle Undead ]]
    -- --[[ Shadow Protection ]]
    -- --[[ Shadow Word: Pain ]]
    -- --[[ Shadowform ]]
    -- --[[ Shadowguard ]]
    -- --[[ Shoot ]]
    -- --[[ Silence ]]
    -- --[[ Smite ]]
    -- --[[ Starshards ]]
    -- --[[ Touch of Weakness ]]
    -- --[[ Vampiric Embrace ]]
}
swing_reset_spells['ROGUE'] = {
    -- --[[ Adrenaline Rush ]]
    -- --[[ Ambush ]]
    -- --[[ Backstab ]]
    -- --[[ Blade Flurry ]]
    -- --[[ Blind ]]
    -- --[[ Cheap Shot ]]
    -- --[[ Cold Blood ]]
    -- --[[ Detect Traps ]]
    -- --[[ Disarm Trap ]]
    -- --[[ Distract ]]
    -- --[[ Evasion ]]
    -- --[[ Eviscerate ]]
    -- --[[ Expose Armor ]]
    -- --[[ Feint ]]
    -- --[[ Garrote ]]
    -- --[[ Ghostly Strike ]]
    -- --[[ Gouge ]]
    -- --[[ Hemorrhage ]]
    -- --[[ Kick ]]
    -- --[[ Kidney Shot ]]
    -- --[[ Pick Lock ]]
    -- --[[ Pick Pocket ]]
    -- --[[ Preparation ]]
    -- --[[ Riposte ]]
    -- --[[ Rupture ]]
    -- --[[ Sap ]]
    -- --[[ Shoot Bow ]]
    -- --[[ Shoot Crossbow ]]
    -- --[[ Shoot Gun ]]
    -- --[[ Sinister Strike ]]
    -- --[[ Slice and Dice ]]
    -- --[[ Sprint ]]
    -- --[[ Stealth ]]
    -- --[[ Throw ]]
    -- --[[ Vanish ]]
    -- --[[ Blinding Powder ]]
    -- --[[ Crippling Poison ]]
    -- --[[ Crippling Poison II ]]
    -- --[[ Deadly Poison ]]
    -- --[[ Deadly Poison II ]]
    -- --[[ Deadly Poison III ]]
    -- --[[ Deadly Poison IV ]]
    -- --[[ Deadly Poison V ]]
    -- --[[ Instant Poison ]]
    -- --[[ Instant Poison II ]]
    -- --[[ Instant Poison III ]]
    -- --[[ Instant Poison IV ]]
    -- --[[ Instant Poison V ]]
    -- --[[ Instant Poison VI ]]
    -- --[[ Mind-numbing Poison ]]
    -- --[[ Mind-numbing Poison II ]]
    -- --[[ Mind-numbing Poison III ]]
    -- --[[ Would Poison ]]
    -- --[[ Would Poison II ]]
    -- --[[ Would Poison III ]]
    -- --[[ Would Poison IV ]]
}
swing_reset_spells['SHAMAN'] = {
    -- --[[ Ancestral Spirit ]]
    -- --[[ Astral Recall ]]
    -- --[[ Chain Heal ]]
    -- --[[ Chain Lightning ]]
    -- --[[ Cure Disease ]]
    -- --[[ Cure Poison ]]
    -- --[[ Disease Cleansing Totem ]]
    -- --[[ Earth Shock ]]
    -- --[[ Earthbind Totem ]]
    -- --[[ Elemental Mastery ]]
    -- --[[ Farsight ]]
    -- --[[ Fire Nova Totem ]]
    -- --[[ Fire Resistance Totem ]]
    -- --[[ Flame Shock ]]
    -- --[[ Flametongue Totem ]]
    -- --[[ Flametongue Weapon ]]
    -- --[[ Frost Resistance Totem ]]
    -- --[[ Frost Shock ]]
    -- --[[ Frostbrand Weapon ]]
    -- --[[ Ghost Wolf ]]
    -- --[[ Grace of Air Totem ]]
    -- --[[ Grounding Totem ]]
    -- --[[ Healing Stream Totem ]]
    -- --[[ Healing Wave ]]
    -- --[[ Lesser Healing Wave ]]
    -- --[[ Lightning Bolt ]]
    -- --[[ Lightning Shield ]]
    -- --[[ Magma Totem ]]
    -- --[[ Mana Spring Totem ]]
    -- --[[ Mana Tide Totem ]]
    -- --[[ Nature Resistance Totem ]]
    -- --[[ Nature's Swiftness ]]
    -- --[[ Poison Cleansing Totem ]]
    -- --[[ Purge ]]
    -- --[[ Reincarnation ]]
    -- --[[ Rockbiter Weapon ]]
    -- --[[ Searing Totem ]]
    -- --[[ Sentry Totem ]]
    -- --[[ Stoneclaw Totem ]]
    -- --[[ Stoneskin Totem ]]
    -- --[[ Stormstrike ]]
    -- --[[ Strength of Earth Totem ]]
    -- --[[ Tranquil Air Totem ]]
    -- --[[ Tremor Totem ]]
    -- --[[ Water Breathing ]]
    -- --[[ Water Walking ]]
    -- --[[ Windfury Totem ]]
    -- --[[ Windfury Weapon ]]
    -- --[[ Windwall Totem ]]
}
swing_reset_spells['WARLOCK'] = {
    -- --[[ Amplify Curse ]]
    -- --[[ Banish ]]
    -- --[[ Conflagrate ]]
    -- --[[ Corruption ]]
    -- --[[ Create Healthstone ]]
    -- --[[ Create Healthstone (Greater) ]]
    -- --[[ Create Healthstone (Lesser) ]]
    -- --[[ Create Healthstone (Major) ]]
    -- --[[ Create Healthstone (Minor) ]]
    -- --[[ Curse of Agony ]]
    -- --[[ Curse of Doom ]]
    -- --[[ Curse of Exhaustion ]]
    -- --[[ Curse of Recklessness ]]
    -- --[[ Curse of Shadow ]]
    -- --[[ Curse of the Elements ]]
    -- --[[ Curse of Tongues ]]
    -- --[[ Curse of Weakness ]]
    -- --[[ Dark Pact ]]
    -- --[[ Death Coil ]]
    -- --[[ Demon Armor ]]
    -- --[[ Demon Skin ]]
    -- --[[ Demonic Sacrifice ]]
    -- --[[ Detect Greater Invisibility ]]
    -- --[[ Detect Invisibility ]]
    -- --[[ Detect Lesser Invisibility ]]
    -- --[[ Drain Life ]]
    -- --[[ Drain Mana ]]
    -- --[[ Drain Soul ]]
    -- --[[ Enslave Demon ]]
    -- --[[ Eye of Kilrogg ]]
    -- --[[ Fear ]]
    -- --[[ Fel Domination ]]
    -- --[[ Health Funnel ]]
    -- --[[ Hell Fire ]]
    -- --[[ Howl of Terror ]]
    -- --[[ Immolate ]]
    -- --[[ Inferno ]]
    -- --[[ Life Tap ]]
    -- --[[ Rain of Fire ]]
    -- --[[ Ritual of Doom ]]
    -- --[[ Ritual of Summoning ]]
    -- --[[ Searing Pain ]]
    -- --[[ Sense Demons ]]
    -- --[[ Shadow Bolt ]]
    -- --[[ Shadow Ward ]]
    -- --[[ Shadowburn ]]
    -- --[[ Shoot ]]
    -- --[[ Siphon Life ]]
    -- --[[ Soul Fire ]]
    -- --[[ Soul Link ]]
    -- --[[ Summon Dreadsteed ]]
    -- --[[ Summon Felhunter ]]
    -- --[[ Summon Felsteed ]]
    -- --[[ Summon Imp ]]
    -- --[[ Summon Succubus ]]
    -- --[[ Summon Voidwalker ]]
    -- --[[ Unending Breath ]]
    -- --[[ Create Firestone ]]
    -- --[[ Create Firestone (Greater) ]]
    -- --[[ Create Firestone (Lesser) ]]
    -- --[[ Create Firestone (Major) ]]
    -- --[[ Create Soulstone ]]
    -- --[[ Create Soulstone (Greater) ]]
    -- --[[ Create Soulstone (Lesser) ]]
    -- --[[ Create Soulstone (Major) ]]
    -- --[[ Create Spellstone ]]
    -- --[[ Create Spellstone (Greater) ]]
    -- --[[ Create Spellstone (Major) ]]
}
swing_reset_spells['WARRIOR'] = {
    -- --[[ Battle Shout ]]
    -- --[[ Battle Stance ]]
    -- --[[ Berserker Rage ]]
    -- --[[ Berserker Stance ]]
    -- --[[ Bloodrage ]]
    -- --[[ Bloodthirst ]]
    -- --[[ Challenging Shout ]]
    -- --[[ Charge ]]
    --[[ Cleave ]]                  845, 7369, 11608, 11609, 20569,
    -- --[[ Death Wish ]]
    -- --[[ Defensive Stance ]]
    -- --[[ Demoralizing Shout ]]
    -- --[[ Disarm ]]
    -- --[[ Execute ]]
    -- --[[ Hamstring ]]
    --[[ Heroic Strike ]]           78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286,
    -- --[[ Intercept ]]
    -- --[[ Intimidating Shout ]]
    -- --[[ Last Stand ]]
    -- --[[ Mocking Blow ]]
    -- --[[ Mortal Strike ]]
    -- --[[ Overpower ]]
    -- --[[ Piercing Howl ]]
    -- --[[ Pummel ]]
    -- --[[ Recklessness ]]
    -- --[[ Rend ]]
    -- --[[ Retaliation ]]
    -- --[[ Revenge ]]
    -- --[[ Shield Bash ]]
    -- --[[ Shield Block ]]
    -- --[[ Shield Slam ]]
    -- --[[ Shield Wall ]]
    -- --[[ Shoot Bow ]]
    -- --[[ Shoot Crossbow ]]
    -- --[[ Shoot Gun ]]
    --[[ Slam ]]                    1464, 8820, 11604, 11605
    -- --[[ Sunder Armor ]]
    -- --[[ Sweeping Strikes ]]
    -- --[[ Taunt ]]
    -- --[[ Throw ]]
    -- --[[ Thunder Clap ]]
    -- --[[ Whirlwind ]]
}

local function LoadAllSettings()
    addon_data.core.LoadSettings()
    addon_data.player.LoadSettings()
    addon_data.target.LoadSettings()
    addon_data.hunter.LoadSettings()
end

addon_data.core.RestoreAllDefaults = function()
    addon_data.core.RestoreDefaults()
    addon_data.player.RestoreDefaults()
    addon_data.target.RestoreDefaults()
    addon_data.hunter.RestoreDefaults()
end

local function InitializeAllVisuals()
    addon_data.player.InitializeVisuals()
    addon_data.target.InitializeVisuals()
    addon_data.hunter.InitializeVisuals()
    addon_data.config.InitializeVisuals()
end


addon_data.core.UpdateAllVisualsOnSettingsChange = function()
    addon_data.player.UpdateVisualsOnSettingsChange()
    addon_data.target.UpdateVisualsOnSettingsChange()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.core.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_core_settings then
        character_core_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.core.default_settings) do
        if character_core_settings[setting] == nil then
            character_core_settings[setting] = value
        end
    end
end

addon_data.core.RestoreDefaults = function()
    for setting, value in pairs(addon_data.core.default_settings) do
        character_core_settings[setting] = value
    end
end

local function CoreFrame_OnUpdate(self, elapsed)
    addon_data.player.OnUpdate(elapsed)
    addon_data.target.OnUpdate(elapsed)
    addon_data.hunter.OnUpdate(elapsed)
end

addon_data.core.MissHandler = function(unit, miss_type, is_offhand)
    if miss_type == "PARRY" then
        if unit == "player" then
            min_swing_time = addon_data.target.main_weapon_speed * 0.2
            if addon_data.target.main_swing_timer > min_swing_time then
                addon_data.target.main_swing_timer = min_swing_time
            end
            if not is_offhand then
                addon_data.player.ResetMainSwingTimer()
            else
                addon_data.player.ResetOffSwingTimer()
            end
        elseif unit == "target" then
            min_swing_time = addon_data.player.main_weapon_speed * 0.2
            if addon_data.player.main_swing_timer > min_swing_time then
                addon_data.player.main_swing_timer = min_swing_time
            end
            if not is_offhand then
                addon_data.target.ResetMainSwingTimer()
            else
                addon_data.target.ResetOffSwingTimer()
            end
        else
            addon_data.utils.PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    else
        if unit == "player" then
            if not is_offhand then
                addon_data.player.ResetMainSwingTimer()
            else
                addon_data.player.ResetOffSwingTimer()
            end 
        elseif unit == "target" then
            if not is_offhand then
                addon_data.target.ResetMainSwingTimer()
            else
                addon_data.target.ResetOffSwingTimer()
            end 
        else
            addon_data.utils.PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    end
end

addon_data.core.SpellHandler = function(unit, spell_id)
    local _, player_class, _ = UnitClass('player')
    for class, spell_table in pairs(swing_reset_spells) do
        if player_class == class then
            for spell_index, curr_spell_id in ipairs(spell_table) do
                if spell_id == curr_spell_id then
                    if unit == "player" then
                        addon_data.player.ResetMainSwingTimer()
                    elseif unit == "target" then
                        addon_data.target.ResetMainSwingTimer()
                    else
                        addon_data.utils.PrintMsg("Unexpected Unit Type in SpellHandler().")
                    end
                end
                
            end
        end
    end
end

local function OnAddonLoaded(self)
    -- Attach the rest of the events and scripts to the core frame
    addon_data.core.core_frame:SetScript("OnUpdate", CoreFrame_OnUpdate)
    addon_data.core.core_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    addon_data.core.core_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    addon_data.core.core_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    addon_data.core.core_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    addon_data.core.core_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    addon_data.core.core_frame:RegisterEvent("START_AUTOREPEAT_SPELL")
    addon_data.core.core_frame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
    addon_data.core.core_frame:RegisterEvent("UNIT_SPELLCAST_START")
    addon_data.core.core_frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    addon_data.core.core_frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    addon_data.core.core_frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    addon_data.core.core_frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    addon_data.core.core_frame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
    -- Load the settings for the core and all timers
    LoadAllSettings()
    InitializeAllVisuals()
    -- Any other misc operations that happen at the start
    addon_data.player.ZeroizeSwingTimers()
    addon_data.target.ZeroizeSwingTimers()
    addon_data.utils.PrintMsg(load_message)
end

local function CoreFrame_OnEvent(self, event, ...)
    local args = {...}
    if event == "ADDON_LOADED" then
        if args[1] == "WeaponSwingTimer" then
            OnAddonLoaded()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        addon_data.core.in_combat = false
    elseif event == "PLAYER_REGEN_DISABLED" then
        addon_data.core.in_combat = true
    elseif event == "PLAYER_TARGET_CHANGED" then
        addon_data.target.OnPlayerTargetChanged()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local combat_info = {CombatLogGetCurrentEventInfo()}
        addon_data.player.OnCombatLogUnfiltered(combat_info)
        addon_data.target.OnCombatLogUnfiltered(combat_info)
    elseif event == "UNIT_INVENTORY_CHANGED" then
        addon_data.player.OnInventoryChange()
        addon_data.target.OnInventoryChange()
    elseif event == "START_AUTOREPEAT_SPELL" then
        addon_data.hunter.OnStartAutorepeatSpell()
    elseif event == "STOP_AUTOREPEAT_SPELL" then
        addon_data.hunter.OnStopAutorepeatSpell()
    elseif event == "UNIT_SPELLCAST_START" then
        addon_data.hunter.OnUnitSpellCastStart(args[1], args[3])
    elseif event == "UNIT_SPELLCAST_STOP" then
        addon_data.hunter.OnUnitSpellCastStop(args[1], args[3])
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        addon_data.hunter.OnUnitSpellCastSucceeded(args[1], args[3])
    elseif event == "UNIT_SPELLCAST_DELAYED" then
        addon_data.hunter.OnUnitSpellCastDelayed(args[1], args[3])
    elseif event == "UNIT_SPELLCAST_FAILED" then
        addon_data.hunter.OnUnitSpellCastFailed(args[1], args[3])
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        addon_data.hunter.OnUnitSpellCastInterrupted(args[1], args[3])
    elseif event == "UNIT_SPELLCAST_FAILED_QUIET" then
        addon_data.hunter.OnUnitSpellCastFailedQuiet(args[1], args[3])
    end
end

-- Add a slash command to bring up the config window
SLASH_WEAPONSWINGTIMER_CONFIG1 = "/WeaponSwingTimer"
SLASH_WEAPONSWINGTIMER_CONFIG2 = "/weaponswingtimer"
SLASH_WEAPONSWINGTIMER_CONFIG3 = "/wst"
SlashCmdList["WEAPONSWINGTIMER_CONFIG"] = function(option)
    InterfaceOptionsFrame_OpenToCategory("WeaponSwingTimer")
    InterfaceOptionsFrame_OpenToCategory("WeaponSwingTimer")
end

-- Setup the core of the addon (This is like calling main in C)
addon_data.core.core_frame:SetScript("OnEvent", CoreFrame_OnEvent)

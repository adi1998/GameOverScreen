local retryRequirements = {
    OrRequirements =
    {
        {
            {
                PathTrue = { "GameState", "ReachedTrueEnding" },
            },
        },
        {
            {
                PathTrue = { "CurrentRun", "IsDreamRun" },
            },
        },
        {
            {
                PathFromSource = true,
                PathTrue = { _PLUGIN.guid .. "SkipRecordRunCleared" }
            },
        }
    },
    {
        PathFalse = { "CurrentRun", "ActiveBounty" },
    }
}

game.ScreenData.RunClear.ComponentData[_PLUGIN.guid .. "RetryButton"] =
{
    Graphic = "ContextualActionButton",
    X = 250,
    Y = 50,
    Alpha = 0.0,
    AlphaTarget = 0.0,
    Data =
    {
        OnMouseOverFunctionName = "MouseOverContextualAction",
        OnMouseOffFunctionName = "MouseOffContextualAction",
        OnPressedFunctionName = _PLUGIN.guid .. "." .. "RetryRun",
        ControlHotkeys = { "Reroll", },
    },
    Text = "{RR} RETRY RUN",
    TextArgs = game.UIData.ContextualButtonFormatRight,
    Requirements = retryRequirements
}

game.ScreenData.RunClear.ComponentData[_PLUGIN.guid .. "RetryBackground"] =
{
    AnimationName = "GUI\\ActionBar",
    GroupName = "HUD_Backing",
    X = game.ScreenCenterX,
    Y = game.UIData.ActionBarBottomOffset-50,
    UseScreenScaleX = true,
    Requirements = retryRequirements
}

for index, value in ipairs(game.ScreenData.RunClear.ComponentData.Order) do
    if value  == "ActionBarBackground" then
        table.insert(game.ScreenData.RunClear.ComponentData.Order, index + 1, _PLUGIN.guid .. "RetryBackground")
        break
    end
end

modutil.mod.Path.Wrap("CloseRunClearScreen", function (base, screen)
    base(screen)
    game.ScreenData.RunClear.ComponentData.DreamRunTitleText.Text = "RunClearScreen_Title"
    game.ScreenData.RunClear.ComponentData.SurfaceTitleText.Text = "RunClearScreen_Title_Surface"
    game.ScreenData.RunClear.ComponentData.UnderworldTitleText.Text = "RunClearScreen_Title"
    game.ScreenData.RunClear.ComponentData.VictoryBackground.Animation = "VictoryScreenIllustration_Underworld"
    game.ScreenData.RunClear[_PLUGIN.guid .. "SkipRecordRunCleared"] = nil
    game.notifyExistingWaiters(_PLUGIN.guid .. "CloseRunClearScreenTriggered")
end)

function mod.OpenGameOverScreen()
    if modutil.mod.IndexArray.Get(game, {"BountyData", game.CurrentRun.ActiveBounty or _PLUGIN.guid .. "UnknownBounty", "Category"}) ~= "PackagedBounty" or not game.CurrentRun.BountyCleared then
        game.ScreenData.RunClear.ComponentData.DreamRunTitleText.Text = "G a m e  O v e r !"
        game.ScreenData.RunClear.ComponentData.SurfaceTitleText.Text = "G a m e  O v e r !"
        game.ScreenData.RunClear.ComponentData.UnderworldTitleText.Text = "G a m e  O v e r !"
        if game.CurrentRun.ModsNikkelMHadesBiomesIsModdedRun and not game.CurrentRun.IsDreamRun then
            game.ScreenData.RunClear.ComponentData.VictoryBackground.Animation = "ModsNikkelMHadesBiomes_VictoryScreenIllustration_Elysium"
        end
        if game.CurrentRun.BiomesReached.N and not game.CurrentRun.IsDreamRun then
            game.ScreenData.RunClear.ComponentData.VictoryBackground.Animation = "VictoryScreenIllustration_Surface"
        end
    end
    game.ScreenData.RunClear[_PLUGIN.guid .. "SkipRecordRunCleared"] = true
    game.ShowHealthUI( { FadeDuration = 0.4, IgnoreLifePips = true } )
    game.ShowManaMeter( { FadeDuration = 0.4 } )
    game.OpenRunClearScreen()
end

modutil.mod.Path.Wrap("DeathPresentation", function (base, ...)
    base(...)
    -- only show this if its never seen before in this run
    if (game.CurrentRun.ScreenViewRecord["RunClear"] or 0) <= 0 or game.CurrentRun["zerp-DreamDiveTweaks" .. "EndlessStarted"] or game.CurrentRun["zerp-BossRush" .. "GauntletStarted"] then
        game.FadeIn({ Duration = 0 })
        game.thread(mod.OpenGameOverScreen)
        game.waitUntil(_PLUGIN.guid .. "CloseRunClearScreenTriggered")
    end
end)

function mod.RetryRun(screen)
    game.CurrentRun[_PLUGIN.guid .. "Retry"] = true
    game.CloseRunClearScreen(screen)
end

modutil.mod.Path.Wrap("StartOver", function (base, args)
    base(args)
    if game.CurrentRun then
        game.CurrentRun[_PLUGIN.guid .. "SavedStartOverArgs"] = args
    end
end)

modutil.mod.Path.Wrap("RunClearMessagePresentation", function (base, screen, message, tooltipData)
    if screen[_PLUGIN.guid .. "SkipRecordRunCleared"] and not( game.CurrentRun.IsDreamRun or game.CurrentRun.ActiveBounty ) then
        message = ""
        if game.CurrentRun.KilledByName then
            message = "Killed by {$TooltipData[1]}"
            tooltipData = { game.CurrentRun.KilledByName }
        end
        game.CurrentRun.VictoryMessage = nil
    end
    base(screen, message, tooltipData)
    if screen.Components[_PLUGIN.guid .. "RetryButton"] then
        game.SetAlpha({ Id = screen.Components[_PLUGIN.guid .. "RetryButton"].Id, Duration = game.HUDScreen.FadeInDuration, Fraction = 1.0 })
    end
end)

modutil.mod.Path.Wrap("KillHero", function (base, ...)
    base(...)
    if game.CurrentRun[_PLUGIN.guid .. "Retry"] and game.CurrentRun[_PLUGIN.guid .. "SavedStartOverArgs"] then
        game.StartOver(game.CurrentRun[_PLUGIN.guid .. "SavedStartOverArgs"])
        -- remove any hub load input blocks
        game.RemoveInputBlock({Name = "DeathAreaTransition"})
        game.RemoveInputBlock({Name = "DeathAreaSwitchRoom"})
        game.RemoveInputBlock({Name = "DeathWalkBlock"})
        game.RemoveInputBlock({Name = "HubPostDreamStartPresentation"})
        game.RemoveInputBlock({Name = "StartRoomPresentation"})
    end
end)

modutil.mod.Path.Wrap("CreateScreenFromData", function (base, screen, componentData)
    if screen[_PLUGIN.guid .. "SkipRecordRunCleared"] == true then
        if modutil.mod.IndexArray.Get(game, {"BountyData", game.CurrentRun.ActiveBounty or _PLUGIN.guid .. "UnknownBounty", "Category"}) ~= "PackagedBounty" or not game.CurrentRun.BountyCleared then
            if game.CurrentRun.BiomesReached.N and not game.CurrentRun.IsDreamRun then
                screen.ComponentData.RunClearMessageText = game.DeepCopyTable(game.ScreenData.RunClear.ComponentData.SurfaceRunClearMessageText)
            end
            if game.CurrentRun.ModsNikkelMHadesBiomesIsModdedRun and not game.CurrentRun.IsDreamRun then
                screen.ComponentData.RunClearMessageText.TextArgs.Color = { 245, 255, 225, 255 }
            end
        end
    end
    base(screen, componentData)
    if screen.Components[_PLUGIN.guid .. "RetryBackground"] then
        game.FlipVertical({ Id = screen.Components[_PLUGIN.guid .. "RetryBackground"].Id })
    end
end)
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
        game.thread(mod.OpenGameOverScreen)
        game.waitUntil(_PLUGIN.guid .. "CloseRunClearScreenTriggered")
    end
end)
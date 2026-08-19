modutil.mod.Path.Context.Env("OpenRunClearScreen", function ()
    modutil.mod.Path.Wrap("RecordRunCleared", function (base)
        if game.ScreenData.RunClear[_PLUGIN.guid .. "SkipRecordRunCleared"] then
            print("skipping RecordRunCleared on death")
            return
        end
        return base()
    end)
    modutil.mod.Path.Wrap("SetAlpha", function (base, args)
        local screen = game.ActiveScreens.RunClear
        if screen and screen[_PLUGIN.guid .. "SkipRecordRunCleared"] and args.Id == screen.Components.ClearTimeRecord.Id then
            return
        end
        return base(args)
    end)
end)

modutil.mod.Path.Context.Env("KillHero", function ()
    modutil.mod.Path.Wrap("LoadMap", function (base, args)
        args = args or {}
        if game.CurrentRun[_PLUGIN.guid .. "Retry"] and game.CurrentRun[_PLUGIN.guid .. "SavedStartOverArgs"] then
            return game.StartOver(game.CurrentRun[_PLUGIN.guid .. "SavedStartOverArgs"])
        end
        return base(args)
    end)
end)
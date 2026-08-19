modutil.mod.Path.Context.Env("OpenRunClearScreen", function ()
    modutil.mod.Path.Wrap("RecordRunCleared", function (base, ...)
        if game.ScreenData.RunClear[_PLUGIN.guid .. "SkipRecordRunCleared"] then
            print("skipping RecordRunCleared on death")
            return
        end
        return base(...)
    end)

    modutil.mod.Path.Wrap("SetAlpha", function (base, args)
        local screen = game.ActiveScreens.RunClear
        if screen and screen[_PLUGIN.guid .. "SkipRecordRunCleared"] and args.Id == screen.Components.ClearTimeRecord.Id then
            return
        end
        return base(args)
    end)

    modutil.mod.Path.Wrap("PlayVoiceLines", function (base, ...)
        if game.ScreenData.RunClear[_PLUGIN.guid .. "SkipRecordRunCleared"] then
            print("skipping PlayVoiceLines on death")
            return
        end
        return base(...)
    end)
end)
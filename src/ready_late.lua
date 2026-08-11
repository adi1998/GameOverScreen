modutil.mod.Path.Context.Env("OpenRunClearScreen", function ()
    modutil.mod.Path.Wrap("RecordRunCleared", function (base)
        if game.ScreenData.RunClear[_PLUGIN.guid .. "SkipRecordRunCleared"] then
            print("skipping RecordRunCleared on death")
            return
        end
        return base()
    end)
end)
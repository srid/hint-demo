\config -> config
  & #configValue %~ (* 2)
  & #configName %~ (++ "_updated")

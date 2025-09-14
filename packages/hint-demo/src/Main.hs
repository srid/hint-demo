module Main where

import HintDemo.Nix
import HintDemo.Types
import Language.Haskell.Interpreter
import Main.Utf8 qualified as Utf8
import Paths_hint_demo (getDataFileName)

-- Load and evaluate expressions from config.hs
loadConfig :: IO ()
loadConfig = do
  configPath <- getDataFileName "config.hs"
  configContent <- decodeUtf8 <$> readFileBS configPath
  let initialConfig = Config "initial" 42

  result <- runInterpreterWithNixPackageDb $ do
    -- Import the types from the hint-demo-types package
    setImports ["Prelude", "HintDemo.Types", "Optics.Core"]

    -- Enable OverloadedLabels extension
    set [languageExtensions := [OverloadedLabels]]

    -- Interpret the config function
    configFunc <- interpret configContent (as :: Config -> Config)
    return $ configFunc initialConfig

  case result of
    Left err -> putTextLn $ "Error loading config: " <> show err
    Right updatedConfig -> putTextLn $ "Updated config: " <> show updatedConfig

main :: IO ()
main = do
  Utf8.withUtf8 $ do
    loadConfig

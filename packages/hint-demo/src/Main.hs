module Main where

import HintDemo.Nix (runInterpreterWithNixPackageDb)
import HintDemo.Types (Config (Config))
import Language.Haskell.Interpreter qualified as H
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
    H.setImports ["Prelude", "HintDemo.Types", "Optics.Core"]

    -- Enable OverloadedLabels extension
    H.set [H.languageExtensions H.:= [H.OverloadedLabels]]

    -- Interpret the config function
    configFunc <- H.interpret configContent (H.as :: Config -> Config)
    return $ configFunc initialConfig

  case result of
    Left err -> die $ "Interpreter error: " ++ show err
    Right v -> do
      putTextLn $ "Original: " <> show initialConfig
      putTextLn $ " Updated: " <> show v

main :: IO ()
main = do
  Utf8.withUtf8 $ do
    loadConfig

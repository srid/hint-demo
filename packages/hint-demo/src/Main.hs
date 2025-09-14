module Main where

import HintDemo.Types
import IncludeEnv.TH
import Language.Haskell.Interpreter
import Language.Haskell.Interpreter.Unsafe
import Main.Utf8 qualified as Utf8
import Paths_hint_demo (getDataFileName)

-- Embed environment variables at compile time
$(includeEnv "GHC_LIB_DIR" "ghcLibDir")
ghcLibDir :: String

$(includeEnv "GHC_PACKAGE_PATH" "ghcPackagePath")
ghcPackagePath :: String
-- Load and evaluate expressions from config.hs
loadConfig :: IO ()
loadConfig = do
  configPath <- getDataFileName "config.hs"
  configContent <- decodeUtf8 <$> readFileBS configPath
  let initialConfig = Config "initial" 42

  result <- runInterpreterWithPackageDb $ do
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

-- Helper function to run interpreter with proper package database
runInterpreterWithPackageDb :: InterpreterT IO a -> IO (Either InterpreterError a)
runInterpreterWithPackageDb action = do
  unsafeRunInterpreterWithArgsLibdir
    ["-package-db", ghcPackagePath, "-hide-all-packages", "-package", "base", "-package", "hint-demo-types", "-package", "optics-core"]
    ghcLibDir
    action

main :: IO ()
main = do
  Utf8.withUtf8 $ do
    putTextLn "Loading configuration using include-env and hint..."
    loadConfig

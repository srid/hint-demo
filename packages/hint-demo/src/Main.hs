module Main where

import HintDemo.Types
import Language.Haskell.Interpreter
import Language.Haskell.Interpreter.Unsafe
import Main.Utf8 qualified as Utf8
import Paths_hint_demo (getDataFileName)

-- Load and evaluate expressions from config.hs
loadConfig :: IO ()
loadConfig = do
  configPath <- getDataFileName "config.hs"
  configContent <- decodeUtf8 <$> readFileBS configPath
  let initialConfig = Config "initial" 42

  result <- runInterpreterWithPackageDb $ do
    -- Import the types from the hint-demo-types package
    setImports ["Prelude", "HintDemo.Types"]

    -- Interpret the config function
    configFunc <- interpret configContent (as :: Config -> Config)
    return $ configFunc initialConfig

  case result of
    Left err -> putTextLn $ "Error loading config: " <> show err
    Right updatedConfig -> putTextLn $ "Updated config: " <> show updatedConfig

-- Helper function to run interpreter with proper package database
runInterpreterWithPackageDb :: InterpreterT IO a -> IO (Either InterpreterError a)
runInterpreterWithPackageDb action = do
  mLibDir <- lookupEnv "GHC_LIB_DIR"
  mPkgPath <- lookupEnv "GHC_PACKAGE_PATH"
  case (mLibDir, mPkgPath) of
    (Just libDir, Just pkgPath) ->
      unsafeRunInterpreterWithArgsLibdir
        ["-package-db", pkgPath, "-hide-all-packages", "-package", "base", "-package", "hint-demo-types"]
        libDir
        action
    _ ->
      -- Fallback to standard interpreter
      runInterpreter action

main :: IO ()
main = do
  Utf8.withUtf8 $ do
    putTextLn "Loading configuration using hint library..."
    loadConfig

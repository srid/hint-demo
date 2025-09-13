module Main where

import Language.Haskell.Interpreter
import Main.Utf8 qualified as Utf8

-- Load and evaluate expressions from config.hs
loadConfig :: IO ()
loadConfig = do
  configContent <- decodeUtf8 <$> readFileBS "./config.hs"
  result <- runInterpreter $ do
    setImports ["Prelude"]

    -- Interpret the config file as a function that takes two Ints and returns a String
    configFunc <- interpret configContent (as :: Int -> Int -> String)
    return $ configFunc 10 5

  case result of
    Left err -> putTextLn $ "Error loading config: " <> show err
    Right value -> putTextLn $ "Config result: " <> toText value

main :: IO ()
main = do
  Utf8.withUtf8 $ do
    putTextLn "Loading configuration using hint library..."
    loadConfig

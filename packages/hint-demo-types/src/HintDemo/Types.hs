module HintDemo.Types where

-- Example data type with 2 fields
data Config = Config
  { configName :: String
  , configValue :: Int
  }
  deriving (Show, Read, Eq)

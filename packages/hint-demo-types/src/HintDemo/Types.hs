module HintDemo.Types where

import Optics.TH

-- Example data type with 2 fields
data Config = Config
  { name :: String
  , value :: Int
  }
  deriving (Show, Read, Eq, Generic)

makeFieldLabels ''Config

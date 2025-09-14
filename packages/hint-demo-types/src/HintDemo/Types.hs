module HintDemo.Types where

import Data.Time.Calendar (Day)
import Optics.TH

-- Example data type with 2 fields
data Config = Config
  { name :: String
  , when :: Day
  }
  deriving (Show, Read, Eq, Generic)

makeFieldLabels ''Config

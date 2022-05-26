{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( start
    ) where

import GHC.Generics
import Control.Monad.IO.Class
import Data.Aeson
import Network.HTTP.Req
import Data.Aeson.Types (parseMaybe)
import Control.Monad
import Data.Functor
import Control.Concurrent


data Game = Game {
  id :: String,
  created_at :: String,
  crash_point :: String
} deriving (Generic)

instance Show Game where
  show (Game id ts v) = id ++ ";" ++ ts ++ ";" ++ v

newtype GameList = Response {
  records :: [Game]
} deriving (Show, Generic)

instance FromJSON Game
instance FromJSON GameList


filterUntil :: String -> [Game] -> [Game]
filterUntil id' (x:xs) = if Lib.id x /= id' then x : filterUntil id' xs else []
filterUntil id' [] = []

fetchUntil :: String -> IO [Game]
fetchUntil id' = filterUntil id' <$> getGameList

lastGameIdOrFromMemory :: String -> [Game] -> String
lastGameIdOrFromMemory lastId (x:_) = Lib.id x
lastGameIdOrFromMemory lastId [] = lastId

getGameList :: IO [Game]
getGameList = runReq defaultHttpConfig $
                req GET url NoReqBody jsonResponse mempty <&> records . responseBody
  where
    url = https "blaze.com" /: "api" /: "crash_games" /: "recent" /: "history"

start :: IO ()
start = go "-"
  where
    go id' = do
      result <- fetchUntil id'
      mapM_ print (reverse result)
      threadDelay 15000000
      go $ lastGameIdOrFromMemory id' result
module Main where

import System.IO

import Lib

main :: IO ()
main = do
    hSetBuffering stdout LineBuffering
    start

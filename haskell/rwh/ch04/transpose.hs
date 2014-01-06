#!/usr/bin/runhaskell

import Data.List (transpose)

main = interact $ unlines . transpose . lines

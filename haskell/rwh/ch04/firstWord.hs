#!/usr/bin/runhaskell

import Data.List (intersperse)

safeHead [] = Nothing
safeHead (x:xs) = Just x

firstWord line =
  let h = safeHead $ words line
      w = case h of
        Nothing -> ""
        Just s -> s
  in w

printWords = concat . intersperse "\n" . map firstWord . lines

-- Print 1st word of every line.
main = interact printWords

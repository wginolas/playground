import Data.Char (digitToInt)

safeHead [] = Nothing
safeHead (x:xs) = Just x

safeTail [] = Nothing
safeTail (x:xs) = Just xs

safeLast [] = Nothing
safeLast [x] = Just x
safeLast (x:xs) = safeLast xs

safeInit [] = Nothing
safeInit [x] = Just []
safeInit (x:xs) = safeCons x (safeInit xs)
  where
    safeCons _ Nothing = Nothing
    safeCons x (Just xs) = Just (x:xs)

--takeWhileRest :: (a -> Bool) -> [a] -> ([a]. [a])

splitWith :: (a -> Bool) -> [a] -> [[a]]
splitWith p xs = map reverse $ splitWith' p [] xs

splitWith' p word [] = [word]
splitWith' p word (x:xs) =
  if p x
  then splitWith' p (x:word) xs
  else word : splitWith' p [] xs

instance Monad (Either String) where
  Right x >>= k = k x
  Left x >>= k = Left x
  return = Right
  fail s = Right s

saveDigitToInt d
  | d >= '0' && d <= '9' = Right $ digitToInt d
  | otherwise = Left $ concat ["non-digit '", [d], "'"]

asPosInt = foldl f 0
  where
    f acc c = acc * 10 + digitToInt c

asInt ('-':cs) = - asPosInt cs
asInt cs = asPosInt cs

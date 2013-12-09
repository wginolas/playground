
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

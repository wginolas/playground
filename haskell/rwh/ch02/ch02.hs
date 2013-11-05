
lastButOne :: [a] -> a
lastButOne [a, b] = a
lastButOne (x:xs) = lastButOne xs

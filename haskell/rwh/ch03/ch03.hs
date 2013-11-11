import Data.List (sortBy)
import Data.Ord (comparing)

data List a = Cons a (List a)
            | Nil
            deriving (Show)

fromList (x:xs) = Cons x (fromList xs)
fromList []     = Nil

toList (Cons x xs) = x : toList xs
toList Nil= []

data MyTree a = MyTree a (Maybe (MyTree a)) (Maybe (MyTree a))
              deriving (Show)

-- EXERCISES
-- Write a function that computes the number of elements in a list. To test it, ensure that it gives the same answers as the standard length function.
-- Add a type signature for your function to your source file. To test it, load the source file into ghci again.

myLen :: [a] -> Int
myLen [] = 0
myLen (x:xs) = 1 + myLen xs

-- Write a function that computes the mean of a list, i.e., the sum of all elements in the list divided by its length. (You may need to use the fromIntegral function to convert the length of the list from an integer into a floating-point number.)

sumLen xs = sumLen' xs 0 0
  where
    sumLen' [] sum len = (sum, len)
    sumLen' (x:xs) sum len = sumLen' xs (sum + x) (len + 1)

mean xs = sum / len
  where
    (sum, len) = sumLen xs

-- Turn a list into a palindrome; i.e., it should read the same both backward and forward. For example, given the list [1,2,3], your function should return [1,2,3,3,2,1].

palindrome xs = xs ++ reverse xs

-- Write a function that determines whether its input list is a palindrome.

isPalindrome xs = xs == reverse xs

-- Create a function that sorts a list of lists based on the length of each sublist. (You may want to look at the sortBy function from the Data.List module.)

sortByLen xs = sortBy (comparing length) xs

-- Define a function that joins a list of lists together using a separator value:
-- -- file: ch03/Intersperse.hs
-- intersperse :: a -> [[a]] -> [a]
-- The separator should appear between elements of the list, but it should not follow the last element. Your function should behave as follows:
-- ghci> :load Intersperse
-- [1 of 1] Compiling Main             ( Intersperse.hs, interpreted )
-- Ok, modules loaded: Main.
-- ghci> intersperse ',' []
-- ""
-- ghci> intersperse ',' ["foo"]
-- "foo"
-- ghci> intersperse ',' ["foo","bar","baz","quux"]
-- "foo,bar,baz,quux"

intersperse' :: a -> [[a]] -> [[a]] 
intersperse' _ [] = []
intersperse' a [x] = [x]
intersperse' a (x:xs) = x : [a] : intersperse' a xs

intersperse :: a -> [[a]] -> [a]
intersperse a xs = concat $ intersperse' a xs

-- Using the binary tree type that we defined earlier in this chapter, write a function that will determine the height of the tree. The height is the largest number of hops from the root to an Empty. For example, the tree Empty has height zero; Node "x" Empty Empty has height one; Node "x" Empty (Node "y" Empty Empty) has height two; and so on.

data Tree a = Node a (Tree a) (Tree a)
            | Empty
            deriving (Show)

height Empty = 0
height (Node _ l r) = 1 + min (height l) (height r)

-- Consider three two-dimensional points, a, b, and c. If we look at the angle formed by the line segment from a to b and the line segment from b to c, it turns left, turns right, or forms a straight line. Define a Direction data type that lets you represent these possibilities.

pairs [] = []
pairs [x] = []
pairs (x:xs) = pairs' (x:xs) x
  where
    pairs' [x] last = [(x, last)]
    pairs' (x1:x2:xs) last = (x1, x2) : pairs' (x2:xs) last

data Point = Point {
  pointX :: Double,
  pointY :: Double
  } deriving (Show, Eq)

data Orientation = LeftOf | RightOf | Parallel deriving(Show, Eq)

oriFromZ z | z > 0  = LeftOf
oriFromZ z | z < 0  = RightOf
oriFromZ z | otherwise = Parallel

crossZ (Point ax ay) (Point bx by) = ax*by - ay*bx

instance Num Point where
  (+) (Point ax ay) (Point bx by) = Point (ax+bx) (ay+by)
  (-) (Point ax ay) (Point bx by) = Point (ax-bx) (ay-by)
  (*) _ _ = error "Not Implemented"
  negate _ = error "Not Implemented"
  abs _ = error "Not Implemented"
  signum _ = error "Not Implemented"
  fromInteger _ = error "Not Implemented"
  fromInt _ = error "Not Implemented"

orientation a b c = oriFromZ $ crossZ (b-a) (c-a)

origin = Point 0 0
testPoints = [Point 1 0, Point 0 1, Point (-1) 0, Point 0 (-1)]

orientation' a (b, c) = orientation a b c
crossZ' (a, b) = crossZ a b

-- map (orientation' origin) $ pairs $ reverse testPoints
-- map (orientation' origin) $ pairs testPoints

-- Write a function that calculates the turn made by three two-dimensional points and returns a Direction.

turn a b c = oriFromZ $ crossZ (b-a) (c-b)

turn' a (b, c) = turn a b c

-- Define a function that takes a list of two-dimensional points and computes the direction of each successive triple. Given a list of points [a,b,c,d,e], it should begin by computing the turn made by [a,b,c], then the turn made by [b,c,d], then [c,d,e]. Your function should return a list of Direction.
-- Using the code from the preceding three exercises, implement Graham’s scan algorithm for the convex hull of a set of 2D points. You can find good description of what a convex hull is, and how the Graham scan algorithm should work, on Wikipedia.

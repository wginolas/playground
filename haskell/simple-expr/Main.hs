import Data.List
import Data.List.Ordered
import qualified Data.Set as Set

data Expr = Const Double
          | Var String
          | Add Expr Expr
          | Mul Expr Expr
            deriving (Eq, Ord, Read)

instance Show Expr where
    show (Const c) = show c
    show (Var v) = v
    show (Add a b) = concat ["(", show a, " + ", show b, ")"]
    show (Mul a b) = concat ["(", show a, " * ", show b, ")"]

data QueueElem = QueueElem { expr :: Expr
                           , eLen :: Int
                           , eGen :: Int }
                 deriving (Read, Show)

queueElem :: Expr -> Int -> QueueElem
queueElem e g = QueueElem e (exprLen e) g

data ExprQueue = ExprQueue { solutions :: [QueueElem]
                           , transformationQueue :: [QueueElem]
                           , visited :: Set.Set Expr}
                 deriving (Read, Show)

emptyQueue = ExprQueue [] [] Set.empty

compareQueueElem :: QueueElem -> QueueElem -> Ordering
compareQueueElem a b = case compare (eLen a) (eLen b) of
                         EQ -> compare (eGen a) (eGen b)
                         LT -> LT
                         GT -> GT

insertSortedQueue :: [QueueElem] -> [QueueElem] -> [QueueElem]
insertSortedQueue toAdd queue = mergeBy compareQueueElem (sortBy compareQueueElem toAdd) queue

exprLen :: Expr -> Int
exprLen (Const _) = 1
exprLen (Var _) = 1
exprLen (Add a b) = 1 + (exprLen a) + (exprLen b)
exprLen (Mul a b) = 1 + (exprLen a) + (exprLen b)

addSwitch (Add a b) = Just $ Add b a
addSwitch _ = Nothing

addSwitch1 (Add (Add a b) c) = Just $ Add a (Add b c)
addSwitch1 _ = Nothing

addOne a = Just $ (Mul (Const 1) a)

addSame (Add a1 a2)
    | a1==a2 = Just $ (Mul (Const 2) a1)
addSame _ = Nothing

addConsts (Add (Const a) (Const b)) = Just $ Const $ a + b
addConsts _ = Nothing

mulSwitch (Mul a b) = Just $ Mul b a
mulSwitch _ = Nothing

mulSwitch1 (Mul (Mul a b) c) = Just $ Mul a (Mul b c)
mulSwitch1 _ = Nothing

mulConsts (Mul (Const a) (Const b)) = Just $ Const $ a * b
mulConsts _ = Nothing

addMulDistributive1 (Mul a (Add b c)) = Just $ (Add (Mul a b) (Mul a c))
addMulDistributive1 _ = Nothing

addMulDistributive2 (Add (Mul a1 b) (Mul a2 c))
    | a1==a2 = Just $ (Mul a1 (Add b c))
    | otherwise = Nothing
addMulDistributive2 _ = Nothing

transformFunctions = [addConsts
                     ,mulConsts
                     ,addSwitch
                     ,addSwitch1
                     ,addOne
                     ,addSame
                     ,mulSwitch
                     ,mulSwitch1
                     ,addMulDistributive1
                     ,addMulDistributive2]

onlyJust :: [Maybe a] -> [a]
onlyJust [] = []
onlyJust ((Just x):xs) = x : onlyJust xs
onlyJust (Nothing:xs) = onlyJust xs

transformStep :: Expr -> [Expr]
transformStep e@(Const _) = transformTerm e
transformStep e@(Var _) = transformTerm e
transformStep e@(Add a b) = concat [
                    transformTerm e,
                    map (\x -> Add x b) $ transformStep a,
                    map (\x -> Add a x) $ transformStep b]
transformStep e@(Mul a b) = concat [
                    transformTerm e,
                    map (\x -> Mul x b) $ transformStep a,
                    map (\x -> Mul a x) $ transformStep b]

transformQueueElem :: QueueElem -> [QueueElem]
transformQueueElem e = map (\x -> queueElem x g) s
    where
      g = 1 + (eGen e)
      s = transformStep (expr e)

transformTerm :: Expr -> [Expr]
transformTerm e = onlyJust $ map (\f -> f e) transformFunctions

insertQueue :: QueueElem -> ExprQueue -> ExprQueue
insertQueue e eq@(ExprQueue sol trans visited)
    = if Set.member (expr e) visited
      then eq
      else ExprQueue
               (insertSortedQueue [e] sol)
               (insertSortedQueue (transformQueueElem e) trans)
               (Set.insert (expr e) visited)

workStep :: ExprQueue -> ExprQueue
workStep (ExprQueue sol (t:ts) visited)
    = insertQueue t (ExprQueue sol ts visited)

work' :: ExprQueue -> ExprQueue
work' eq@(ExprQueue sol [] _) = eq
work' eq@(ExprQueue ((QueueElem _ sLen _):_) ((QueueElem _ tLen _):_) _)
    | sLen * 2 < tLen = eq
work' eq = work' $ workStep eq

work :: Expr -> Expr
work e = expr $ head $ solutions $ work' $ insertQueue (queueElem e 0) emptyQueue

main = print "Hello World!"

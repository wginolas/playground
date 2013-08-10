-- http://projecteuler.net/

import Data.List

fibs = 1:1:(h 1 1)
    where
    h a b = s:(h b s)
        where
        s = a+b
          
notDivides n t = n `mod` t /= 0
divides n t = n `mod` t == 0

primes = 2:3: filter isPrime [5,7..]
    where
    isPrime n = (all (notDivides n) . takeWhile (\x->x*x<=n)) primes

primeFactors n = hlp primes n
    where
    hlp (p:ps) n | p>n = []
                 | divides n p = p:hlp (p:ps) (n `div` p)
                 | otherwise   = hlp ps n

isPalindrome n = s == reverse s
    where
    s = show n

threeDigits = reverse [100..999]

hcf a b = a * b `div` (gcd a b)

sqr x = x*x

p8Str = "73167176531330624919225119674426574742355349194934" ++
    "96983520312774506326239578318016984801869478851843" ++
    "85861560789112949495459501737958331952853208805511" ++
    "12540698747158523863050715693290963295227443043557" ++
    "66896648950445244523161731856403098711121722383113" ++
    "62229893423380308135336276614282806444486645238749" ++
    "30358907296290491560440772390713810515859307960866" ++
    "70172427121883998797908792274921901699720888093776" ++
    "65727333001053367881220235421809751254540594752243" ++
    "52584907711670556013604839586446706324415722155397" ++
    "53697817977846174064955149290862569321978468622482" ++
    "83972241375657056057490261407972968652414535100474" ++
    "82166370484403199890008895243450658541227588666881" ++
    "16427171479924442928230863465674813919123162824586" ++
    "17866458359124566529476545682848912883142607690042" ++
    "24219022671055626321111109370544217506941658960408" ++
    "07198403850962455444362981230987879927244284909188" ++
    "84580156166097919133875499200524063689912560717606" ++
    "05886116467109405077541002256983155200055935729725" ++
    "71636269561882670428252483600823257530420752963450"

p8Digits :: [Integer]
p8Digits = map (\d -> read [d]) p8Str

p8Seqs = (filter (\l -> length l == 5) . map (take 5) . tails) p8Digits


{-
a+b+c=1000
c=1000-a-b

a²+b²=c²
a²+b²=(1000-a-b)²
a²+b²=(1000-a-b)*(1000-a-b)
a²+b²=1000000 - 1000*a - 1000*b - 1000*a + a² + a*b - 1000*b + a*b + b²
-}

round3 (a,b,c) = (round a, round b, round c)

p9 = ((\(a,b,c)->a*b*c). head . filter isSolution . map round3 . map check) [1..999]
    where
    check a = (a, b, c)
        where
        b = (500000 - 1000*a) / (1000 - a)
        c = 1000 - a - b
    isSolution (a, b, c) = a*a + b*b == c*c

p10 = (sum . takeWhile (<2000000)) primes

p13 = do inp <- readFile "p13.txt"
         putStr ((take 10 . show . sum . map readInt . filter (not.null) . lines) inp)
         putStr "\n"
         where
             readInt :: String -> Integer
             readInt = read

collatz 1 = [1]
collatz n | odd n     = n : collatz (n*3+1)
          | otherwise = n : collatz (n `div` 2)

p14 = (foldl1' maxC . map cozLen) [1..1000000]
    where
    maxC x@(a,_) y@(b,_) | a<b = y
                         | otherwise = x
    cozLen n = (length c, c)
        where
        c = collatz n

checksum 0 = 0
checksum n = n `mod` 10 + checksum (n `div` 10)

p20 = checksum $ product [1..100]

p16 = checksum $ product $ take 1000 [2,2..]

p25 = fst $ head $ filter ((>=1000) . length  . show . snd) $ zip [1..] fibs

hasDigits12 n = all (\d -> d=='0' || d=='1' || d=='2') (show n)

p303f n = head $ dropWhile (not . hasDigits12) (map (n*) [1..])

p303avg m = sum $ (map (\n-> (p303f n) `div` n) [1..m])

p303 = p303avg 10000


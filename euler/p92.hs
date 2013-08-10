-- A number chain is created by continuously adding the square of the digits in a number to form a new number until it has been seen before.
-- 
-- For example,
-- 
-- 44 → 32 → 13 → 10 → 1 → 1
-- 85 → 89 → 145 → 42 → 20 → 4 → 16 → 37 → 58 → 89
-- 
-- Therefore any chain that arrives at 1 or 89 will become stuck in an endless loop. What is most amazing is that EVERY starting number will eventually arrive at 1 or 89.
-- 
-- How many starting numbers below ten million will arrive at 89?

import List

numbers max =
  tail $ impl max
  where impl max = do
          count1 <- [0..max]
          let max2 = max-count1
          count2 <- [0..max2]
          let max3 = max2-count2
          count3 <- [0..max3]
          let max4 = max3-count3
          count4 <- [0..max4]
          let max5 = max4-count4
          count5 <- [0..max5]
          let max6 = max5-count5
          count6 <- [0..max6]
          let max7 = max6-count6
          count7 <- [0..max7]
          let max8 = max7-count7
          count8 <- [0..max8]
          let max9 = max8-count8
          count9 <- [0..max9]
          [[count1,
            count2,
            count3,
            count4,
            count5,
            count6,
            count7,
            count8,
            count9]]

countsToDigits cs = (zip [1..] cs)

reverseDigits 0 = []
reverseDigits n = mod n 10 : reverseDigits (div n 10)

sortedDigits = sort . reverseDigits

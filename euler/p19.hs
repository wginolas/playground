-- How many Sundays fell on the first of the month during the twentieth century (1 Jan 1901 to 31 Dec 2000)?

import Data.Time
import Data.Time.Calendar.WeekDate

sunday :: Int
sunday = 7

months = [fromGregorian year month 1 | year <- [1901..2001], month <- [1..12]]

isSunday day = wd == sunday
  where (_, _, wd) = toWeekDate day

main = print $ length $ filter isSunday months

--start = toClockTime CalendarTime {
--  ctYear = 1951,
--  ctMonth = January,
--  ctDay = 1,
--  ctHour = 0,
--  ctMin = 0,
--  ctSec = 0,
--  ctPicosec = 0,
--  ctWDay = Monday,
--  ctYDay = 1,
--  ctTZName = "CEST",
--  ctTZ = 7200,
--  ctIsDST = False
--  }
--
--end = toClockTime CalendarTime {
--  ctYear = 2000,
--  ctMonth = December,
--  ctDay = 31,
--  ctHour = 0,
--  ctMin = 0,
--  ctSec = 0,
--  ctPicosec = 0,
--  ctWDay = Monday,
--  ctYDay = 1,
--  ctTZName = "CEST",
--  ctTZ = 7200,
--  ctIsDST = False
--  }
--
--dMonth = TimeDiff {
--  tdYear = 0,
--  tdMonth = 1,
--  tdDay = 0,
--  tdHour = 0,
--  tdMin = 0,
--  tdSec = 0,
--  tdPicosec = 0
--  }
--
--testCount end =
--  impl 1 end
--  where impl i end
--          | i > end = []
--          | otherwise = i : impl (i+1) end
--
--months =
--  impl start
--  where impl i
--          | i > end = []
--          | otherwise = i : impl (addToClockTime dMonth i)
--
--main = do
--  clockTime <- getClockTime
--  calendarTime  <- toCalendarTime clockTime
--  print calendarTime

getDivisors num
  | num < 1 = []
  | otherwise = [x | x <- [n | n <- primeNumbers (num - 1), n <= ((floor.sqrt.fromIntegral) (num + 1))], num `mod` x == 0 ]

primeNumbers :: Integer -> [Integer]
primeNumbers 2 = [2]
primeNumbers num = 
	if getDivisors num == []
		then primeNumbers (num - 1) ++ [num]
		else primeNumbers (num - 1)

main :: IO()
main = print (primeNumbers 1000)

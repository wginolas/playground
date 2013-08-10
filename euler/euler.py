#!/usr/bin/python
import math

def divisors(a):
    for d in xrange(1,a/2 + 1):
        if a % d == 0: yield d
    yield a

def gen_len(g):
    return sum(1 for j in g)

def numbers(start):
    i = start
    while True:
        yield i
        i += 1

def find(f, g):
    for i in g:
        if f(i): return i
    return None

def take(count, gen):
    for i, a in zip(xrange(count), gen):
        yield a
    
def triangle():
    n = 0
    for i in numbers(1):
        n += i
        yield n
        
def p12Slow():
    return find(
        lambda t: len(t[1]) == 501,
        ((t, list(divisors(t))) for t in triangle())
        )

primeCache = [2]

def isPrime(i):
    for p in primes():
        if i % p == 0: return False
        if p*p > i: return True

def primes():
    for p in primeCache:
        yield p
    
    for i in numbers(p+1):
        if isPrime(i):
            primeCache.append(i)
            yield i

def prime_factors(n):
    for p in primes():
        while n % p == 0:
            yield p
            n /= p
        if p*p > n: break

    if n != 1: yield n

def tuples(start):
    for s in numbers(start*2):
        for i in xrange(start, s - start + 1):
            yield (i, s-i)

def prime_tuples():
    for p1 in primes():
        for p2 in primes():
            if p2 >= p1: break

            yield (p1, p2)
            yield (p2, p1)
        yield (p1, p1)

def print_gen(gen):
    print list(take(100, gen))

#triangle_cache = set()
#last_triangle = 0
#next_triangle_dec = 1
#def is_triangle(n):
#    global triangle_cache
#    global last_triangle
#    global next_triangle_dec
#    while n > last_triangle:
#        last_triangle += next_triangle_dec
#        next_triangle_dec += 1
#        triangle_cache.add(last_triangle)#
#
#    return n in triangle_cache

def nth_triangle(n):
    return (n*n+n) / 2

# geht nicht für große Zahlen :(
def is_triangle(t):
    n = long((math.sqrt(8*t+1)-1) / 2)
    test = nth_triangle(n)
    d = int(math.copysign(1, t - test))
    while True:
        if t == test:
            return True
        n += d
        test = nth_triangle(n)
        if (t - test) * d < 0: return False

#n = 12345678901234567890
#print is_triangle(nth_triangle(n)+1)

def find_smallest(gen):
    small = gen.next()
    print "found:", small
    for i in gen:
        if i < small:
            small = i
            print
            print "found: ", small

# Loesungsansatz:
# - Welche Zahlen haben 501 Teiler?
# - Beziehung zwischen Primfaktorzerlegeung und Teilern
# - Welche Primfaktorzerlegung haben Zahlen mit 501 Teilern?
#def p12():
#    for a, b in prime_tuples():
#        n = a**166 * b**2
#        #if a!=b and is_triangle(n):
#        if a!=b and is_triangle(n):
#            yield n

def p12():
    cnt = 0
    for a in primes():
        for b in take(15, primes()):
            n = b**166 * a**2
            #n = b**2 * a
            if is_triangle(n):
                yield n

            cnt += 1
            if cnt == 1:
                print "log: ", a, b
                cnt = 0

#find_smallest(p12())
#printGen(p12())

def p205():
    s = 0
    w = 0
    for p1 in xrange(1, 5):
        for p2 in xrange(1, 5):
            for p3 in xrange(1, 5):
                for p4 in xrange(1, 5):
                    for c1 in xrange(1, 7):
                        for c2 in xrange(1, 7):
                            for c3 in xrange(1, 7):
                                for c4 in xrange(1, 7):
                                    for c5 in xrange(1, 7):
                                        for c6 in xrange(1, 7):
                                            s += 1
                                            if p > c: w += 1
    print w, s, float(w)/s

#p205()

#printGen(tuples(1))
#print_gen(primeFactors(28))
#print_gen(divisors(28))
#print_gen(primeFactors(6))

#print
#for n, fs, ds in take(10, (
#        (n, primeFactors(n), divisors(n)) 
#        for n in triangle())):
#    print "%4d: %s" % (n, list(fs))
#    print "    : %s" % list(ds)

#print list(primeFactors(501))
#print list(primeFactors(1024))
#print list(take(10, primes()))
#print p12()
#print list(take(10, ((t, list(divisors(t))) for t in triangle())))
#print list(((i,i) for i in range(10)))

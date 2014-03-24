int digit_square(int n) {
	int result = 0;

	while (n > 0) {
		int d = n % 10;
		n = n / 10;
		result += d * d;
	}
	return result;
}

int fill_cache(int n, int[] cache) {
	if (cache[n] != 0) {
		return cache[n];
	}

	int r = fill_cache(digit_square(n), cache);
	cache[n] = r;
	return r;
}

int main(string[] args) {
	int max_cache = digit_square(9999999) + 1;
	int count = 0;
    int[] cache = new int[max_cache];
	cache[1] = 1;
	cache[89] = 89;

	for (int i=1; i<max_cache; i++) {
		int r = fill_cache(i, cache);
		if (r == 89) count++;
	}

	for (int i=max_cache; i<=10000000; i++) {
		if (cache[digit_square(i)] == 89) count++;
	}

	stdout.printf("%d\n", count);
	return 0;
}

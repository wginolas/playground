//valac --pkg=gmp --vapidir=. -X -lgmp test.vala

using Gmp;

public class BigInt : Object {

	private Gmp.Mpz mpz = Gmp.Mpz();

	public BigInt(long i) {
		mpz.set_si(i);
	}

	public BigInt.zero() {
	}

	public BigInt mul_si(long op) {
		BigInt r = new BigInt.zero();
		r.mpz.mul_si(mpz, op);
		return r;
	}

	public BigInt add(BigInt op) {
		BigInt r = new BigInt.zero();
		r.mpz.add(mpz, op.mpz);
		return r;
	}

	public BigInt sub(BigInt op) {
		BigInt r = new BigInt.zero();
		r.mpz.sub(mpz, op.mpz);
		return r;
	}

	public BigInt pow(ulong exp) {
		BigInt r = new BigInt.zero();
		r.mpz.pow_ui(mpz, exp);
		return r;
	}

	public int cmp(BigInt op) {
		return mpz.cmp(op.mpz);
	}

	public string to_string() {
		return to_String_base(10);
	}

	public string to_String_base(int b) {
		char* chars = new char[mpz.sizeinbase(b) + 2];
		mpz.get_str(chars, b);
		string result = (string)chars;
		delete chars;
		return result;
	}
}

int main(string[] args) {
	BigInt max = new BigInt(10).pow(1000);
	//BigInt max = new BigInt(100);
	BigInt a = new BigInt(1);
	BigInt b = new BigInt(2);
	while (b.cmp(max) < 0) {
		BigInt c = a.add(b);
		a = b;
		b = c;
	}
	stdout.printf("%s\n", b.to_string());
	return 0;
}

/**
100!
int main(string[] args) {
	BigInt r = new BigInt(1);
	for(int i=1; i<100; i++) {
		r = r.mul_si(i);
		stdout.printf("%d: %s\n", i, r.to_string());
	}
	return 0;
}
**/

/*
int main(string[] args) {
	Gmp.Mpz result = Gmp.Mpz();
	result.set_si(1);
	for (int i=1; i<100; i++) {
		result.mul_si(result, i);
		stdout.printf("%d: %s\n", i, mpz_to_str(result));
	}
	return 0;
}
*/
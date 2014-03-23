//valac --pkg=gmp --vapidir=. -X -lgmp test.vala

using Gmp;

string mpz_to_str(Gmp.Mpz mpz) {
	char* chars = new char[mpz.sizeinbase(10) + 2];
	mpz.get_str(chars, 10);
	string result = (string)chars;
	delete chars;
	return result;
}

public class BigInt : Object {

	private Gmp.Mpz mpz = Gmp.Mpz();

	public BigInt(long i) {
		mpz.set_si(i);
	}

	public BigInt.from_mpz(Mpz mpz) {
		this.mpz.set(mpz);
	}

	public BigInt mul_si(long op) {
		Mpz r = Mpz();
		r.mul_si(mpz, op);
		return new BigInt.from_mpz(r);
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
	BigInt r = new BigInt(1);
	for(int i=1; i<100; i++) {
		r = r.mul_si(i);
		stdout.printf("%d: %s\n", i, r.to_string());
	}
	return 0;
}

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
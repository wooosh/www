set Title "Derivation of Fractional Datatypes"
set Date 2022-03-29
set Description "WIP"


set Contents {
  section Rationals {
    txt {
      Fractional datatypes are equivalent to the category of *rational* numbers, that is, any number that can be represented by a pair of integers `(P, Q)`, which when divided as `P/Q`, produce the held value.

      There are a variety of ways to represent `P` and `Q`, but the most obvious method is simply to store `P` and `Q` together:
    }

    code c {
      struct {
        int p;
        int q;
      } rational;
    }

    txt {
      This representation is referred to as a  [Rational Data Type](https://en.wikipedia.org/wiki/Rational_data_type).

      Implementing common mathematical operations for rational datatypes is fairly simple, following the same rules one would use on paper to manipulate fractions.
    }

    txt "**Addition & Subtraction**"
    code c {
      add(A, B) = {p: (A.p * B.q) + (B.p * A.q),
             q: A.q * B.q}

      sub(A, B) = {p: (A.p * B.q) - (B.p * A.q),
                  q: A.q * B.q}
    }

    latex {
      \frac{A_p * B_q + B_q * A_q}{A_q * B_q}
    }

    latex {
      \frac{A_p * B_q - B_q * A_q}{A_q * B_q}
    }
  }
}
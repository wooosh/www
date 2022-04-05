set Title "Derivation of Fractional Datatypes"
set Date 2022-04-04
set Description "Algebraically deriving arithmetic operations and properties of various fractional datatypes."

set Contents {
  section Introduction {
    txt {
      While working with fractional datatypes, I've felt I never had a good intuition for how arithmetic operations worked under the hood. While I knew the basics of how rationals, fixed point, and floating point were represented in memory, I did not understand how, for example, a multiplication would affect the precision of a floating point value.

      Doing more research into the topic, I've realized that each fractional datatype is just a different representation of `P/Q`, where `P` and `Q` are integers.

      Each represesentation implies different constraints, which can be taken advantage of in order to allow simpler and faster arithmetic operations.
    }

    note {
      The structure definitions of each fractional type in this post are used for demonstration purposes, and are not intended to be an efficient use of memory.
      The memory layout of fractional datatypes usually have much more care put into them for efficiency.
    }
  }

  section Rationals {
    txt {
      The most obvious (and least constrained) method of representing a fraction is simply to store `P` and `Q` together:
    }



    code c {
      struct rational {
        int p;
        int q;
      };
    }

    txt {
      This representation is referred to as a  [Rational Data Type](https://en.wikipedia.org/wiki/Rational_data_type).

      Implementing arithmetic operations for rational datatypes is fairly simple, using the same techniques one would use manually for fractions:
    }

    section "Addition & Subtraction" {
      pre {
        add(A, B) = {p: (A.p * B.q) + (B.p * A.q),
                     q: A.q * B.q}

        sub(A, B) = {p: (A.p * B.q) - (B.p * A.q),
                     q: A.q * B.q}
      }
    }

    section "Multiplication & Division" {
      pre {
        mul(A, B) = {p: A.p * B.p,
                     q: A.q * B.q}

        div(A, B) = {p: A.p * B.q,
                     q: A.q * B.p}
      }
    }

    section "Issues" {
      txt {
        However, there are a couple of practical issues with this representation:

        * `Q` can be 0, representing an undefined value.
          * This is problematic because zero-initialization produces an invalid rational value.
        * Rationals cannot be compared component wise (i.e. checking if `A.p == B.p` and `A.q == B.q`).
          * As an example, `1/2 == 0.5 == 2/4`, but `A.p == B.p && A.q == B.q` evaluates to false.
        * As more operations are performed on a rational, `P` and `Q` will approach the maximum value of the integer type, resulting in overflow.

        While #1 can be avoided relatively easily, #2 and #3 require the rational to be simplified, which can be achieved by dividing `P` and `Q` by their GCD (greatest common divisor):
      }

      code c {
        int find_gcd(int a, int b) {
            int remainder = a % b;

            if (remainder == 0) {
                return b;
            }

            return gcd(b, remainder);
        }

        struct rational simplify(struct rational r) {
          int gcd = find_gcd(r.p, r.q);

          r.p /= gcd;
          r.q /= gcd;

          return r;
        }
      }


      txt {
        Simplification ends up being a relatively expensive operation, requiring repeated use of the slow modulus operator, though there are a few methods of reducing the perfomance cost:

        * Implement special cases for each operation when `A.q == B.q`, avoiding the growth in denominator.
        * Avoid simplification after every operation:
          * Check if `P` or `Q` will overflow during the operation, and simplify if so.
          * Trust the developer to insert explicit simplify calls.
        * Use a faster method of finding GCD, such as [binary GCD](https://en.wikipedia.org/wiki/Binary_GCD_algorithm#Efficiency)

        Regardless, using this type of rational will always suffer from this issue in some form.
      }
    }
  }

  section "Fixed-Q Rationals" {
    txt {
      Similar to how a fixed-size integer types (e.g. int8, int16) can be used if the expected range of values is known ahead of time, a constant value of `Q` (denoted `kQ`) can be picked for a rationals, providing a precision of `1/kQ`.

      The representation of a fixed-Q rational only requires a single component, now that `Q` is an implicit constant:
    }

    code c {
      typedef int fixed_q_100;
    }

    txt {
      A constant denominator provides the following benefits:

      * The issue of simplification is avoided entirely.
      * Any `Q` above can be substituted for `kQ`, enabling many operations to be factored out.
      * Fixed-Q rationals with the same `kQ` can be compared directly using the standard integer `==` operator.
      * Division can be replaced with multiplication (which is faster), by precomputing the reciprocal of `kQ`, denoted `rQ`, where `rQ = 1/kQ`.

      Using these techniques, the fixed-Q variant of each arithmetic operation can be found:
    }

    section "Addition (subtraction omitted for brevity)" {
      pre {
        add(A, B) = {p: (A.p * B.q) + (B.p * A.q),
                     q: A.q * B.q}
              
        x = add(A, B)
        x.p/x.q = [(A.p * B.q) + (B.p * A.q)] / (A.q * B.q)
        x.p/x.q = [(A.p * kQ) + (B.p * kQ)] / (kQ * kQ)
        x.p/x.q = [kQ * (A.p + B.p)] / (kQ^2)
        x.p/x.q = (A.p + B.p) / kQ
              
        add(A, B) = {p: A.p + B.p,
                     q: kQ}
      }
    }

    section "Multiplication" {
      pre {
        mul(A, B) = {p: A.p * B.p,
                     q: A.q * B.q}

        x = mul(A, B)
        x.p/x.q = (A.p * B.p) / (A.q * B.q)
        x.p/x.q = (A.p * B.p) / (kQ * kQ)
        x.p/x.q = (A.p * B.p * 1/kQ) / kQ
        x.p/x.q = (A.p * B.p * rQ) / kQ
                  
        mul(A, B) = {p: A.p * B.p * rQ,
                     q: kQ}
      }
    }

    section "Division" {
      pre {
        div(A, B) = {p: A_p * B_q,
                     q: A_q * B_p}

        x = div(A, B)             
        x.p/x.q = (A.p * B.q) / (A.q * B.p)
        x.p/x.q = (A.p * kQ) / (kQ * B.p)
        x.p/x.q = A.p / B.p
      }

      txt {
        Though this is simplified to a single division, `Q != kQ`, making the result non-fixed-Q. There are two ways to solve this:
      }

      label "Method #1"
      pre {
        x.p/x.q = A.p / B.p
        x.p/x.q = [(A.p / B.p) * kQ] / kQ

        div(A, B) = {p: (A.p / B.p) * kQ
                     q: kQ}
      }

      label "Method #2"
      pre {
        x.p/x.q = A.p / B.p
        x.p/x.q = [(A.p * kQ) / B.p] / kQ

        div(A, B) = {p: (A.p * kQ) / B.p
                     q: kQ}
      }

      txt {
        Though equivalent mathematically, method #2 grants greater precision at the cost of requiring a larger type to store the intermediate value of `A.p * kQ`, or risk overflow. Method #1 results in the fractional component being lost completely, but does not require a larger type to store intermediate values.
      }
    }

    section "Mixing Fixed-Q Rationals with Different Q Values" {
      txt {
        It is possible to use fixed-Q rationals with different Q, by following the same rules as a regular rational, simply by substituting `A.q` and `B.q` with the value of `kQ` for each value.
      }
    }
  }

  section "'Point' Types" {
    note {
      The use of the term 'floating point' in this section refers to the general concept, not the IEEE754 specification of floating point values.
    }

    txt {
      A point type (as in fixed point or floating point) is simply a type where `Q` is a power of a constant base, ie `Q = k^e` (e stands for exponent in this context, not Eulers number).

      Example:
    }

    pre {
      1234.5678
      This is is a decimal number (base 10)
      The "point" is at the 4th digit

      P = 12,345,678
      Q = k^e
      Q = 10^(4)
      Q = 10,000

      12,345,678/10,000 = 1234.5678
    }

    txt {
      It's worth noting that in a manner similar to scientific notation, `e` can be varied such that both very large numbers (positive e) and very small numbers (negative e) can be represented, unlike regular rationals. 

      The point variant of fixed-Q rationals (known as fixed point) is used effectively the same way as regular fixed-Q rationals, with 3 minor differences when the base is a power of 2:

      1. Multiplication by `kQ` can be replaced with a left shift.
      2. Division by `rQ`, or divison by `kQ` can be replaced with a right shift.
      3. Fixed point with different exponents can be operated on using the floating point operations described below.

      Bitshifts are considerably faster than multiplication or division, resulting in improved performance over fixed-Q rationals.

      The point variant of regular rationals (known as floating point) enables us to sidestep the simplification and comparison issues, while retaining the ability to vary `Q`, and thus the precision. 

      Floating point types are also able to make use of bitwise operations if `k` is a power of 2 in order to gain performance.

      A floating point type can be represented simply by storing `P` and the exponent `e`.
    }

    code c {
      struct floating_point {
        int p;
        int e; /* exponent */
      };
    }

    txt {
      We can derive the operations for floating point types by replacing any `q` with `k^e`:
    }

    section "Addition (subtraction omitted for brevity)" {
      pre {
        add(A, B) = {p: (A.p * B.q) + (B.p * A.q),
                     q: A.q * B.q}
        
        x = add(A, B)
        x.p/x.q = [(A.p * B.q) + (B.p * A.q)] / (A.q * B.q)
        x.p/x.q = [(A.p * k^B.e) + (B.p * k^A.e)] / (k^A.e * k^B.e)
        x.p/x.q = [(A.p * k^B.e) + (B.p * k^A.e)] / (k^(A.e + B.e)

        add(A, B) = {p: (A.p * k^B.e) + (B.p * k^A.e),
                     q: k^(A.e + B.e)}
      }

      txt {
        This can be simplified further if we assert that `A.e >= B.e` and simply raise `B.e` to `A.e`:
      }

      pre {
        add(A, B) = {p: (A.p * k^B.e) + (B.p * k^A.e),
                     q: k^(A.e + B.e)}

        x.p/x.q = [(A.p * k^B.e) + (B.p * k^A.e)] / (k^(A.e + B.e)
        x.p/x.q = [(A.p * k^B.e)/k^B.e + (B.p * k^A.e)/k^B.e] / k^A.e
        x.p/x.q = [A.p + B.p * (k^A.e/k^B.e)] / k^A.e
        x.p/x.q = [A.p + B.p * k^(A.e - B.e)] / k^A.e
     
        add(A, B) = {p: A.p + B.p * k^(A.e - B.e),
                     q: k^A.e}
      }

      txt {
        In practice, `A` and `B` can be swapped if `B.e > A.e` to satisfy `A.e >= B.e`.
        
        The reason this assertion is important is because if `A.e - B.e < 0`, then `k^(A.e - B.e)` will have a negative exponent of `k`, which is not representable as an integer value unless `k == 1`.
      }
    }

    section "Multiplication" {
      pre {
        mul(A, B) = {p: A.p * B.p,
                     q: A.q * B.q}

        x = mul(A, B)
        x.p/x.q = (A.p * B.p) / (A.q * B.q)
        x.p/x.q = (A.p * B.p) / (k^A.e * k^B.e)
        x.p/x.q = (A.p * B.p) / (k^(A.e + B.e))

        mul(A, B) = {p: A.p * B.p,
                     q: k^(A.e + B.e)}
      }
    }

    section "Division" {
      pre {
        div(A, B) = {p: A_p * B_q,
                     q: A_q * B_p}

        x = div(A, B)
        x.p/x.q = (A.p * B.q) / (A.q * B.p)
        x.p/x.q = (A.p * k^B.e) / (k^A.e * B.p)
        x.p/x.q = (A.p/B.p) * (k^B.e/k^A.e)
        x.p/x.q = (A.p/B.p) * (k^(B.e - A.e))
        x.p/x.q = (A.p/B.p) * (k^-(A.e - B.e))
        x.p/x.q = (A.p/B.p) * 1/(k^(B.e - A.e))
        x.p/x.q = (A.p/B.p) / (k^(B.e - A.e))

        div(A, B) = {p: A.p / B.p
                     q: k^(A.e - B.e)}
      }
    }
  }

  section "Conclusion" {
    txt {
      Finding the "best" fractional datatype for a given usecase is usually quite tricky, as you have to balance ergonomics and perfomance.

      Generally speaking, you should default to single or double precision floats unless you have a good reason not to. Though floats are more complicated, all x86_64 CPUs have hardware support for them, and tend to have very competitive performance relative to standard integer math. Additionally, nearly every language used today has support for floating point natively, resulting in better ergonomics compared to other options.

      Some situtations where you may want to consider another representation:

      * Embedded processors without hardware floating point support
      * Avoiding the cost of saving and restoring FPU registers during context switches
      * Applications that need 100% deterministic fractional math
      * Greater data density by using 8 or 16 bit wide types, compared to the smallest commonly available floating point type, which is 32 bits

      Additionally, there are arbitrary precision fractional datatypes, which are capable of representing a number at any precision that fits in memory. These require much more care to implement, and are almost always used through a library such as [Boost Multiprecision](https://github.com/boostorg/multiprecision) or [GMP (GNU Multiple Precision)](https://gmplib.org/).
    }
  }
}

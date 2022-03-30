set Title "Chebyshev Polynomials"
set Date 2022-03-30
set Description "WIP"


set Contents {
  section "Chebyshev Polynomials" {
    txt {
      Test Page
    }

    latex {
      T_n(\cos x) = \cos (nx)
    }

    section "Recurrence Relation" {
      txt {`T_n` can be defined in a recursive form without trigonometric functions:}
      
      latex {
        T_0(x) &= 1\\
        T_1(x) &= x\\
        T_n(x) &= 2x T_{n-1}(x) - T_{n-2}(x)
      }

      details "Proof" {
        txt {
          The non-trigonometric form of the first two Chebyshev polynomials can be found directly:
        }

        latex {
          T_n(\cos x) &= \cos(nx)\\
          T_0(\cos \arccos x) &= \cos(0*\arccos x) = 1\\
          T_0(x) &= 1\\
          T_1(\cos \arccos x) &= \cos(1*\arccos x) = x\\
          T_1(x) &= x
        }

        txt {
          Subsequent `T_n` can be found by calculating cos(nx) in terms of `cos[(n-1)x]` and `cos[(n-2)x]` using the angle addition identity:
        }

        latex {
          \cos(a+b) &= \cos(a)\cos(b) - \sin(a)\sin(b)\\
          \cos(a-b) &= \cos(a)\cos(b) + \sin(b)\sin(b)
        }

        latex {
          \cos(a+b) + \cos(a-b) &= \cos(a)\cos(b) - \sin(a)\sin(b)\\
          &+ \cos(a)\cos(b) + \sin(a)\sin(b)\\
          \cos(a+b) + \cos(a-b) &= 2\cos(a)\cos(b)
        }

        latex {
          \cos(nx+x) + \cos(nx-x) &= 2\cos(nx)\cos(x)\\
          \cos[(n+1)x] + \cos[(n-1)x] &= 2\cos(nx)\cos(x)\\
          \cos(nx) + \cos[(n-2)x] &= 2\cos[(n-1)x]\cos(x)\\
          \cos(nx) &= 2\cos[(n-1)x]\cos(x) - \cos[(n-2)x]
        }

        txt {Substituting this into `T_n`:}

        latex {
          T_n(\cos x) &= \cos(nx)\\
          T_{n-1}(\cos x) &= \cos[(n-1)x]\\
          T_{n-2}(\cos x) &= \cos[(n-2)x]\\
          T_n(\cos x) &= 2\cos(x)\cos[(n-1)x] - \cos[(n-2)x]\\
          T_n(\cos x) &= 2\cos(x)T_{n-1}(\cos x) - T_{n-2}(\cos x)\\
          T_n(x) &= 2x T_{n-1}(x) - T_{n-2}(x)
        }
      }

      txt {
        This recurrence relation can then be efficiently evaluted with coefficients using the [Clenshaw Algorithm](https://en.wikipedia.org/wiki/Clenshaw_algorithm), defined as follows:
      }

      latex {
        S(x) = \sum_{k=0}^{n} \alpha_k \phi_k(x)
      }
    }
  }
}
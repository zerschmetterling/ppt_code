# load the necessary functionalities, i.e. code written for this 
# thesis

load("perfectness.sage") 

# define the generators of the polynomial ring our coefficients 
# live in
varList = [ var("v"+str(i)) for i in range( catalan_number(3) ) ] 

# initalize the ring (which now has variables v0, v0CC for complex 
# conjugate, and so on), as well as a list of TL algebras (a list 
# because of the inductive construction), a list of the respective 
# bases, and a dictionary for complex conjugation

R = initR(varList)
T = initT(3, q, R)
bas = initBasis(T)
cc_dict = conjugate_dictionary(R)


# we define the coefficient of our vector simply as the generators 
# of the ring, then normalize, and make the tangle self-adjoint
coeff = varList
coeff[1] = 1 
coeff = coeffsSelfadjoint(coeff)

# then compute all rotations of the tangle, as well as all 
# multiplications of each rotations with its adjoint
rot = allRotations(coeff)
mult = allMultiplications(rot)

# finally, we can obtain our (complex) equations, and because 
# Mathematica has a bit of trouble with these, we split them into 
# real and imaginary parts, then things somehow get easier
symEq = getSymbolicEquations(mult)
real_symEq = symbolicEquations_real_split(symEq)

# verification of results

dict_q_2 = {
        q : 2,
        v4r : 1,
        v4i : 0,
        v2r : -1,
        v3r : -1
    }

var("x")
assume(x, 'integer')
assume(x > 2)

dict_q_plus = {
        q : 2*cos(pi/x),
        v4r : 1,
        v4i : 0,
        v2r : (sqrt(4 - 4*cos(pi/x)^2) - 2)/(2*cos(pi/x)),
        v3r : (2*cos(pi/x))/(sqrt(4 - 4*cos(pi/x)^2) - 2)
    }

dict_q_minus = {
        q : 2*cos(pi/x),
        v4r : 1,
        v4i : 0,
        v2r : (-sqrt(4 - 4*cos(pi/x)^2) - 2)/(2*cos(pi/x)),
        v3r : (2*cos(pi/x))/(-sqrt(4 - 4*cos(pi/x)^2) - 2)
    }

dict_q_sqrt3 = {
        q : sqrt(3),
        v4r : 1,
        v4i : 0,
        v2r : -sqrt(3),
        v3r : -sqrt(3)
    }


symEq_q_2 = list(set([bla.subs(dict_q_2) for bla in real_symEq]))

symEq_q_plus = list(set([bla.subs(dict_q_plus) for bla in real_symEq]))
symEq_q_plus = [bla.simplify_trig() for bla in symEq_q_plus]
symEq_q_plus = list(set(symEq_q_plus))

symEq_q_minus = list(set([bla.subs(dict_q_minus) for bla in real_symEq]))
symEq_q_minus = [bla.simplify_trig() for bla in symEq_q_minus]
symEq_q_minus = list(set(symEq_q_minus))

symEq_q_sqrt3 = list(set([bla.subs(dict_q_sqrt3) for bla in real_symEq]))

print "q = 2: ", symEq_q_2
print "f plus: ", symEq_q_plus
print "f minus: ", symEq_q_minus
print "q = sqrt(3): ", symEq_q_sqrt3


# We will also verify the other rotation invariant solutions.

coeff = [1,1,v0,v0,1]
rot = allRotations(coeff)
mult = allMultiplications(rot)
symEq = getSymbolicEquations(mult)
real_symEq = symbolicEquations_real_split(symEq)

var("y")
assume(y, 'real')
assume( y >= sqrt(3), y < 2 )

dict_rot_plus = {
        q : y,
        v0r : -y/(y^2 - 2),
        v0i : +sqrt(-(12 - 7*y^2 + y^4)/(y^2 - 2)^2)
    }

dict_rot_minus = {
        q : y,
        v0r : -y/(y^2 - 2),
        v0i : -sqrt(-(12 - 7*y^2 + y^4)/(y^2 - 2)^2)
    }


symEq_rot_plus = list(set([bla.subs(dict_rot_plus) for bla in real_symEq]))
symEq_rot_plus = [bla.simplify_trig() for bla in symEq_rot_plus]
symEq_rot_plus = list(set(symEq_rot_plus))

symEq_rot_minus = list(set([bla.subs(dict_rot_minus) for bla in real_symEq]))
symEq_rot_minus = [bla.simplify_trig() for bla in symEq_rot_minus]
symEq_rot_minus = list(set(symEq_rot_minus))

print "rot plus: ", symEq_rot_plus
print "rot minus: ", symEq_rot_minus

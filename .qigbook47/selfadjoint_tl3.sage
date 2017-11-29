# load the necessary functionalities, i.e. code written for this thesis
load("perfectness.sage") 

# define the generators of the polynomial ring our coefficients live in
varList = [ var("v"+str(i)) for i in range( catalan_number(3) ) ] 

# initalize the ring (which now has variables v0, v0CC for complex conjugate, 
# and so on), as well as a list of TL algebras (a list because of the 
# inductive construction), a list of the respective bases, and a dictionary
# for complex conjugation

R = initR(varList)
T = initT(3, q, R)
bas = initBasis(T)
cc_dict = conjugate_dictionary(R)


# we define the coefficient of our vector simply as the generators of the 
# ring, then normalize, and make the tangle self-adjoint
coeff = varList
coeff[1] = 1 #normalize so that coefficient of unit is 1
coeff = coeffsSelfadjoint(coeff)

# then compute all rotations of the tangle, as well as all multiplications of 
# each rotations with its adjoint
rot = allRotations(coeff)
mult = allMultiplications(rot)

# finally, we can obtain our (complex) equations, and because Mathematica
# has a bit of trouble with these, we split them into real and imaginary
# parts, then things somehow get easier
symEq = getSymbolicEquations(mult)
real_symEq = symbolicEquations_real_split(symEq)

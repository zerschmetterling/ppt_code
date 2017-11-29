load("perfectness.sage")
varList = [var("v"+str(i)) for i in range( catalan_number (3) )]

R = initR(varList)
T = initT(3,q,R)
bas = initBasis(T)

coeff = varList
coeff[1] = 1
rot = allRotations(coeff)
mult = allMultiplications (rot)

symEq = getSymbolicEquations (mult)
real_symEq = symbolicEquations_real_split (symEq)


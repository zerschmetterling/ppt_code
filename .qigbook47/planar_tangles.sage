#####################################################################################################
#                                                                                                   #
#   What we need here is a list of TL algebras, eg obtained with                                    #
#       T = [TemperleyLiebAlgebra(i, q, R) for i in range(7)]                                       #
#   over the ring                                                                                   #
#       R.<a1,a2,b1,b2,q,iSymbol> = LaurentPolynomialRing(QQbar)                                    #
#                                                                                                   #
#   It could happen that older versions of sage cannot build such rings of Laurent polynomials.     #
#   In that case you simply remove the "Laurent" and build a standard polynomial ring.              #
#                                                                                                   #
#   The code in this file works like this.                                                          #        
#                                                                                                   #    
#       (*) The function F is an implementation of the tangle $\widetilde{}_n$, as follows: It      #
#           takes two arguments, the first being an arbitrary tangle, while the second must be      #
#           a 2-tangle.                                                                             #    
#                                                                                                   #        
#       (*) The function recursionF takes two inputs, a 2-tangle v and a number n. This is the      #            
#           actual implementation of the recursive definition of $\widetilde{}_n$: The output is    #
#           the n-tangle $\widetilde{v}_n$                                                          # 
#                                                                                                   # 
#       (*) getVector takes the list generated by F as input and returns the vector it corrseponds  # 
#           to, in the correct TL-algebra                                                           #
#                                                                                                   #
#       (*) To leftInclusion we pass a vector and a number n , which is greater than the order of   #
#           the TL algebra (lets say the order is k) the vector lives in. The output is the result  #
#           of passing the vector to left inclusion tangle $inc_k^n$. That is, it is not only the   #
#           inclusion into the TL algebra one order higher, but arbitrarily often.                  #
#                                                                                                   # 
#####################################################################################################

def get_variable(i):
    return "v"+str(i)

###
#   Given a list of lists of the form [coefficient, diagram], return the corresponding tangle
###

def getVector(splitList):
    TL_algebra = T[ len(splitList[0][1]) ]
    this_bas = bas[ TL_algebra.order() ]
    this_R = TL_algebra.base_ring()
    summed = TL_algebra.zero()
    for x in splitList:
        # _coeff = this_R( reduceIsquared_coeff( x[0] ))
        _coeff = this_R( x[0])
        vector = [v for v in this_bas if convertToList(v) == x[1]]
        summed += _coeff*vector[0]
    return summed

###
#   Linear extension of the function on basis tangles. Includes the n-tangle v into TL of order topDim > n
###

def leftInclusion(v, topDim):
    vTerms = v.terms()
    split = [ [x.trailing_coefficient(), BASIS_leftInclusion(x.trailing_monomial(), topDim)] for x in vTerms ]
    # split = getVector(spli)
    split = sum(split[i][0]*split[i][1] for i in range( len(split)) )
    return split

def BASIS_leftInclusion(basis_element, topDim):
    diagram = convertToList(basis_element)
    dim = len(diagram)
    for i in range(1,topDim - dim+1):
        diagram.append([-(dim+i), dim+i])
    diagram.sort()
    diagram = getVector([[1,diagram]])
    return diagram

###
#   Convert basis tangle to easy-to-parse list. Cleaner than always using an instance method.
###

def convertToList( base_tangle ):
    return base_tangle.diagram().standard_form()

###
#   Obtain the adjoint of a basis tangle by simply flipping the sign of each "node", then reordering the list
###

def adjointBasisElement( base_tangle ):
    tList = convertToList(base_tangle)
    tempList = []
    for i in range(len(tList)):
        tempList.append([-tList[i][0], -tList[i][1]])
    [x.sort() for x in tempList]
    tempList.sort()
    answer = getVector([[1, tempList]])
    # return [x for x in bas if convertToList(x) == tempList][0]
    return answer

#### RETURN THE ADJOINT OF A LINEAR COMBINATION

def adjoint( tangle ):
    this_R = tangle.base_ring()
    try:
        cc_dict = cc_dict_glob
    except:
        cc_dict = conjugate_dictionary(this_R)
        global cc_dict_glob
        cc_dict_glob = cc_dict

    terms = tangle.terms()
    
    coeffs = [SR(x.trailing_coefficient()) for x in terms]
    vector = [x.trailing_monomial() for x in terms]

    coeffsCC = [this_R(x.subs(cc_dict)) for x in coeffs]
    vectorCC = [adjointBasisElement(x) for x in vector]

    adjointTangle = sum( coeffsCC[k]*vectorCC[k] for k in range(len(terms)) )

    return adjointTangle

### ROTATE AN INPUT TANGLE ONE CLICK 

def rotateTangle( vector_in ):
    this_TL = vector_in.parent()
    this_bas = this_TL.basis().list()
    basis_as_list = [ convertToList(x) for x in this_bas ]
    strands = this_TL.order()
    in_list = convertToList(vector_in)
    out_list = []

    for i in range(strands):
        out_list.append([])
        for x in in_list[i]:
            if x == -1:
                out_list[i].append( 1 )
            elif x == strands:
                out_list[i].append( -strands )
            else:
                out_list[i].append( x + 1 )
    
    [x.sort() for x in out_list]
    out_list.sort()
    
    rotated = this_bas[ basis_as_list.index( out_list ) ]
    return rotated 


###
#   More advanced stuff. Pretty much the construction from the main theorem
###

def init_FF(tang, n):
    FF = [0,0,tang]
    for i in range(3,n):
        FF.append(F(FF[i-1], tang))
    return FF

def recursionF(v, n):
    if n == 3:
        return F(v,v)
    else:
        return F(
                recursionF(v, n-1),
                v)

def F( v, w ):
    this_TL = v.parent()
    subs_dict = {}

    for i in range(this_TL.order()+1):
        vTEMP = var(get_variable(i+1))
        subs_dict.update({vTEMP : i+1})

    vTerms = v.terms()
    wTerms = w.terms()
    vSplit = [[t.trailing_coefficient(), t.diagram().standard_form()] for t in vTerms]
    wSplit = [[t.trailing_coefficient(), t.diagram().standard_form()] for t in wTerms]
    
    answer = []
    for x in vSplit:
        vector = x[1]
        for comp in vector:
            for i in range(1,this_TL.order()+1):
                if -i in comp:
                    comp.remove(-i)
                    comp.append(-eval(get_variable(i+1)))
                if i in comp:
                    if i != 1:
                        comp.remove(i)
                        comp.append(eval(get_variable(i+1)))


    for x in wSplit:
        vector = x[1]
        for comp in vector:
            for i in range(1,3):
                if -i in comp:
                    if i != 2:
                        comp.remove(-i)
                        comp.append(-eval(get_variable(i)))
                if i in comp:
                    comp.remove(i)
                    comp.append(eval(get_variable(i)))
    
    for x in vSplit:
        xCoeff = x[0]
        xVec = x[1]
        for y in wSplit:
            yCoeff = y[0]
            yVec = y[1]
            appendThis = [xCoeff*yCoeff, []]
            for xComp in xVec:
                for yComp in yVec:
                    if 1 not in xComp and -2 not in yComp:
                        if xComp not in appendThis[1]:
                            appendThis[1].append(xComp)
                        if yComp not in appendThis[1]:
                            appendThis[1].append(yComp)
                    if 1 in xComp and -2 in yComp:
                        yTemp = copy(yComp)
                        xTemp = copy(xComp)
                        yTemp.remove(-2)
                        xTemp.remove(1)
                        xTemp.append(yTemp[0])
                        if xTemp not in appendThis[1]:
                            appendThis[1].append(xTemp)

            answer.append(appendThis)

    for x in answer:
        for y in x[1]:
            try:
                y[0] = y[0].subs(subs_dict)
            except:
                pass
            try:
                y[1] = y[1].subs(subs_dict)
            except:
                pass
            y.sort()
        x[1].sort()

    answer = getVector(answer)
    return answer


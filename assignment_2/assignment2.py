S = ["fit","unfit"]
A = ["exercise", "relax"]
S_prime = ["fit","unfit","dead"]

exerciseMatrix = [[(0.99, 8), (0.01, 8)], [(0.2, 0), (0.8, 0)]]
relaxMatrix  = [[(0.7, 10), (0.3, 10)], [(0, 5), (1, 5)]]

gamma = 0.9



def p(s,a,s_prime):
    if s == "fit":
        if a == "exercise":
            if s_prime == "fit":
                return exerciseMatrix[0][0][0]
            else:   #s_prime = unfit
                return exerciseMatrix[0][1][0]
        if a == "relax":
            if s_prime == "fit":
                return relaxMatrix[0][0][0]
            else: #s_prime = unfit
                return relaxMatrix[0][1][0]
    elif s == "unfit":
        if a == "exercise":
            if s_prime == "fit":
                return exerciseMatrix[1][0][0]
            else:   #s_prime = unfit
                return exerciseMatrix[1][1][0]
        if a == "relax":
            if s_prime == "fit":
                return relaxMatrix[1][0][0]
            else: #s_prime = unfit
                return relaxMatrix[1][1][0]


def r(s,a,s_prime):
    if s == "fit":
        if a == "exercise":
            if s_prime == "fit":
                return exerciseMatrix[0][0][1]
            else:   #s_prime = unfit
                return exerciseMatrix[0][1][1]
        if a == "relax":
            if s_prime == "fit":
                return relaxMatrix[0][0][1]
            else: #s_prime = unfit
                return relaxMatrix[0][1][1]
    elif s == "unfit":
        if a == "exercise":
            if s_prime == "fit":
                return exerciseMatrix[1][0][1]
            else:   #s_prime = unfit
                return exerciseMatrix[1][1][1]
        if a == "relax":
            if s_prime == "fit":
                return relaxMatrix[1][0][1]
            else: #s_prime = unfit
                return relaxMatrix[1][1][1]


def q0(s,a):
    return ( p_prime(s,a,"fit")*r_prime(s,a,"fit") + p_prime(s,a,"unfit")*r_prime(s,a,"unfit") + p_prime(s,a,"dead")*r_prime(s,a,"dead") )

qExerciseCache = {int : {str : float}}
qRelaxCache = {int : {str : float}}


def q(n,s,a):
    if n == 0:
        return q0(s,a)
    else:    
        try:
            if a == "exercise":
                return qExerciseCache[n][s]
            elif a == "relax":
                return qRelaxCache[n][s]
        except:
            return assignToCache(n,s,a)

def assignToCache(n,s,a):
    retVal =  ( q0(s,a) + gamma*(p_prime(s,a,"fit")*V(n-1,"fit") + p_prime(s,a,"unfit")*V(n-1,"unfit") + p_prime(s,a,"dead")*V(n-1,"dead") ))
    if a == "relax":
        if n not in qRelaxCache:
            qRelaxCache[n] = {s : retVal}
        else:
            if s not in qRelaxCache[n]:
                qRelaxCache[n][s] = retVal
    else:
        if n not in qExerciseCache:
            qExerciseCache[n] = {s : retVal}
        else:
            if s not in qExerciseCache[n]:
                qExerciseCache[n][s] = retVal
    return retVal


def V(n,s):
    return max(q(n,s,"exercise"), q(n,s,"relax"))


def p_prime(s,a,s_prime):
    if s =="dead" and s_prime =="dead":
        return 1
    elif s == "dead":
        return 0
    elif s_prime == "dead" and a == "exercise":
        return 0.1
    elif s_prime == "dead" and a == "relax":
        return 0.01
    elif a == "exercise":
        return ( (9*p(s,a,s_prime)) / 10 )
    else:
        return ( (99*p(s,a,s_prime)) / 100 )


def r_prime(s,a,s_prime):
    if s_prime == "dead" or s == "dead":
        return 0
    else:
        return ( r(s,a,s_prime) )


#################################################

n = int(input("Provide 'n' : "))
gamma = float(input("Provide a gamma setting G : "))
stateInput = input("Provide a state : ")


for i in range(n+1):
    exVal = q(i,stateInput,"exercise")
    relaxVal = q(i,stateInput,"relax")
    print("n = " + str(i) + " exer : " + str(exVal) + " relax : " + str(relaxVal))
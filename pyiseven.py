import julia
j2 = julia.Julia()

def even(x):
  j2.run("using IsOdd")
  return not j2.run("IsOdd.odd(" + str(x) + ")")


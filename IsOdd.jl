module IsOdd

using PyCall
@pyimport pyiseven

function odd(x)
  if x == 1
    true
  elseif x == 0
    false
  else
    pyiseven.even(x-1)
  end
end

end

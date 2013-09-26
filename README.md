##Calling Julia from Python (and Python from Julia)

Code for Lightning talk at Madison Python User Group on Sept 26, 2013.

Since this is a Python User Group, let's drive the main event from Python.

## Dependencies

* Install [Julia](github.com/JuliaLang/Julia)
* at the Julia REPL, `Pkg.add("PyCall")`
* `git clone https://github.com/JuliaLang/IJulia.jl`
    + in `IJulia.jl/python/`, run `python setup.py install` (may need `sudo`)

## Running the Code

To start with, clone this repo.
Then, in the cloned directory, open a Python REPL.

Run the following code:

~~~~
import pyiseven
pyiseven.even(5)
~~~~

You should get `False`.
On the surface this seems pretty innocuous.
We imported a python file, and it took a long time to load.
Then, we called a function, which told us that 5 is not even.
However, that ignores key implementation details (which are hinted at by all those dependencies).

Let's start with the python file, `pyiseven.py`.

~~~~
import julia
j = julia.Julia()

def even(x):
  j.run("using IsOdd")
  return not j.run("IsOdd.odd(" + str(x) + ")")
~~~~

First, we `import` the thing we installed from inside the `IJulia.jl/python` directory.
Then, we start up the Julia process we'll be talking to.

In the `even` function, we import a Julia package called `IsOdd`.
That string argument to `run` is just a snippet of Julia code.
After that, we return the opposite of running `IsOdd`'s function `odd` on `x`.

So far, we've discovered that we called Julia code from Python.
To see that happen in the Python REPL:

~~~~
import julia
j = julia.Julia() # this will take a longish time
j.run("2+2") #=> 4
j.run("sin(pi)") #=> 1.2246467991473532e-16
j.run("x = 5") #=> 5
j.run("x += 2") #=> 2
~~~~

Now, let's look at the Julia side of the code, in the `IsOdd` module.

~~~~
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
~~~~

The `module` keyword creates a Module (a namespace); the last `end` keyword closes it.

`using PyCall` imports that Julia package we added in the Dependencies section.
`@pyimport` is a macro from `PyCall`, which takes a Python package name as it's argument.
After `@pyimport`ing `pyiseven`, we can use dot-notation to access its members, including the `even` function.

In the `odd` function, we first take care of a couple of base cases in our recursion,
then we call right back into that Python function (decrementing `x` so that we'll eventually finish).

There are some obvious short-comings of this code, such as not handling negative numbers,
but it is an example of a minimal mutual recursion between Python and Julia.
It also breaks on my machine if you pass `even` an integer greater than `200`.
I don't yet know why.

## More PyCall fun

If you install [matplotlib](http://matplotlib.org/users/installing.html),
then you can have more fun calling Python from Julia.

~~~~
using PyCall
@pyimport pylab
x = linspace(0,2*pi,1000); y = sin(3*x + 4*cos(2*x));
pylab.plot(x, y; color="red", linewidth=2.0, linestyle="--")
pylab.show() 
~~~~

This should pop open a window with a nice graph of a dotted red squiggley line. :)

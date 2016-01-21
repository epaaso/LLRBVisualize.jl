using LLRBVisualize
using FactCheck

# write your own tests here
@fact 1 == 1 --> true "meh"

FactCheck.exitstatus()

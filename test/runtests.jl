using LLRBVisualize
using FactCheck

# write your own tests here
facts("Basic") do
    @fact 1 == 1 --> true "meh"

end

FactCheck.exitstatus()

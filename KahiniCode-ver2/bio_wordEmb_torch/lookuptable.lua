require 'nn'
-- a lookup table containing 10 tensors of size 3
module = nn.LookupTable(10, 3)

--print(module[{1}])
input = torch.Tensor{1}
print(module:forward(input))

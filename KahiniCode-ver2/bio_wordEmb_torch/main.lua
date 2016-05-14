require 'train'
require 'predict_next_word'


use_manual_technique = false;
epochs = 1;

-- Manual Training seems to require more epochs to get a similar error rate.
if use_manual_technique == true then epochs = 3; end

print('-------MODEL TRAINING BEGINS------------')
model = train(epochs,use_manual_technique);
print('-------MODEL TRAINING DONE SUCCESSFULLY------------')

-- dumping model
torch.save('model/model.dat', model);

--print('-------PREDICT NEXT WORD BEGINS------------')
---- sample taken -- 'introduction modern agriculture is highly dependent on the use of chemical'
--predict_next_word('introduction', 'modern', 'agriculture', 'is', 'highly', 'dependent',
--    'on', 'the', 'use', 'of', model, 3);
--print('-------PREDICTION DONE SUCCESSFULLY------------')

-- loading the model from dumped file
model_loaded = torch.load('model/model.dat')

--print the lookup table
local ltable = model_loaded:get(1)
--print('ltable')
local input = torch.Tensor{1}
print(ltable:forward(input))




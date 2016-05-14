local matio = require 'matio'


function load_data(N)
--[[% This method loads the training, validation and test set.
% It also divides the training set into mini-batches.
% Inputs:
%   N: Mini-batch size.
% Outputs:
%   train_input: An array of size D X N X M, where
%                 D: number of input dimensions (in this case, 3).
%                 N: size of each mini-batch (in this case, 100).
%                 M: number of minibatches.
%   train_target: An array of size 1 X N X M.
%   valid_input: An array of size D X number of points in the validation set.
%   test: An array of size D X number of points in the test set.
%   vocab: Vocabulary containing index to word mapping.
]]--

--dataset = 'data/data.mat';
--data = matio.load(dataset);
vocab_data = 'data/vocab.mat';
train_data = 'data/train.mat';
valid_data = 'data/valid.mat';
test_data = 'data/test.mat';


--vocab = data['data']['vocab'];
print('before')
vocab = matio.load(vocab_data)['vocab1'];   --revisit
--vocab = vocab1:transpose(1,2);
--print(#vocab)
words = {}; 
vocab_ByIndex = {};
vocab_size = 0;

for i=1, #vocab do
      --print('inside vocab loop')
      length = (#vocab[i])[2];
      --print('len :: ', length)
      local word = ''
         for c=1, length do
           word = word .. string.char(vocab[i][1][c]);
         end
      -- print('word :: ',word)
      --print('count',i)
      words[word] = i
      --print('words filled')
      table.insert(vocab_ByIndex, word)
      --print('table inserted ')
      vocab_size=i;
      --print('end loop')
end
print('VOCAB LOOP DONE')
print(#vocab)
--print('vocab size ::',vocab_size,vocab_ByIndex)
vocab = words;
--print('vocab processed',vocab);
--print('word::')
--print(vocab[3])
print('LOOKING UP ')
print(vocab['pathogen'])

--testData = data['data']['testData'];
test = matio.load(test_data)['test1'];
-- already trasnposed in matlab
testData = test:type('torch.IntTensor');
--print(testData)
--testData = test:transpose(1,2);
print('testData')
print(testData:type(),testData:size())

--trainData = data['data']['trainData'];
----print(trainData)
--print(trainData:transpose(1,2):size())
-- transposing train data here works
train = matio.load(train_data)['train'];
-- already trasnposed in matlab
trainData = train:type('torch.IntTensor');
--revist comment again
--train_temp = train:type('torch.IntTensor');
--print('trainData before')
--print(train_temp:type(),train_temp:size());
--
--trainData = train_temp:transpose(1,2)
--print('trainData ::')
print('trainData')
print(trainData:type(),trainData:size())


--validData = data['data']['validData'];
valid = matio.load(valid_data)['valid1'];
-- already trasnposed in matlab
validData = valid:type('torch.IntTensor');
--validData = valid:transpose(1,2)
print('validData')
print(validData:type(),validData:size())

-- accessing columns not rows, so can be applied directly to chunk/batch
numdims = (#trainData)[1];
D = numdims - 1;
M = math.floor((#trainData)[2] / N);

-- revisit - couldnot understand
train_input = torch.reshape(trainData[{ {1,D},{1,N*M} }],D,N,M);
--print('train_input :: ')
--print(train_input:size())
train_target = torch.reshape(trainData[{ {D + 1},{1,N * M} }], 1, N, M);
--print('train_target :: ')
--print(train_target:size())
valid_input = validData[{ {1,D},{} }];
--print('valid_input :: ')
--print(valid_input:size())
valid_target = validData[{ {D + 1},{} }];
test_input = testData[{ {1,D},{} }];
test_target = testData[{ {D + 1}, {} }];

print('DATA LOADED SUCCESSFULLY')

return train_input, train_target, valid_input, valid_target, test_input, test_target, vocab, vocab_size, vocab_ByIndex

end
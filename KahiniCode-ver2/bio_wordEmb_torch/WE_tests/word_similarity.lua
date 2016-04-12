-- Word similarity Test1 - checking k nearest words
require 'torch'
require 'nn'
local matio = require 'matio'


function load_vocab()
    dataset = 'data/data.mat';
    data = matio.load(dataset);
    vocab_data = 'data/vocab.mat';

    vocab = matio.load(vocab_data)['vocab'];
    --vocab = vocab1:transpose(1,2);
    words = {};
    vocab_ByIndex = {};
    vocab_size = 0;

    for i=1, #vocab do
        length = (#vocab[i])[2];
        local word = ''
        for c=1, length do
            word = word .. string.char(vocab[i][1][c]);
        end
        words[word] = i
        table.insert(vocab_ByIndex, word)
        vocab_size=i;
    end
    print('VOCAB LOOP DONE')
    print(#vocab)
    vocab = words;

    return vocab,vocab_ByIndex;
end


function display_nearest_words(word, model, k)
    -- Shows the k-nearest words to the query word.
    -- Inputs:
    --   word: The query word as a string.
    --   model: Model returned by the training script.
    --   k: The number of nearest words to display.
    -- Example usage:
    --   display_nearest_words('school', model, 10);

    word_embedding_weights = model:get(1)
    vocab,vocab_ByIndex = load_vocab();

    id = vocab[word];

    if id == nil then
        print('Word not in vocabulary:', word);
        return;
    end
    -- Compute distance to every other word.
    vocab_size = #vocab_ByIndex;
    -- since lookup table is a convolution layer
    local input = torch.Tensor{id};
    word_rep = word_embedding_weights:forward(input);
    query_word_rep = word_rep:clone();
    -- since lookup table has no subtraction operator - write a loop
    -- a loop to subtract tensors and cal distances here only and store dist.
    distance = {}
    for i=1,#vocab_ByIndex do
        local input1 = torch.Tensor{i};
        word_rep1 = word_embedding_weights:forward(input1);
        local diff = word_rep1:csub(query_word_rep);
        local square =  torch.cmul(diff,diff);
        local summ =  torch.sum(square);
        local dist = torch.sqrt(summ);
        --local dist = torch.sqrt(torch.sum(torch.cmul(diff,diff)));
        table.insert(distance,dist);
    end
    -- Sort by distance.
    distance_t = torch.Tensor(distance);
    d,order = torch.sort(distance_t);
    --order = order(2:k+1);  -- The nearest word is the query word itself, skip that.
    for i = 1,k do
        print('--------------Inside loop time',i);
        print(string.format("%s %s", vocab_ByIndex[order[i]], distance[order[i]]));

    end

end

function test_word_similarity()
    --reivist - should test word similarity on words taken from a fixed input file
    --calculate - accuracy - how many similar words match out of total
    --should have ground truth for this - use meta thesaurus for test cases
    --also check with Euclidean dist and cosine similarity - revisit
    --query_word_list = {}
    -- loading the model from dumped file
    model = torch.load('model/model.dat')
    display_nearest_words('pathogen ', model, 10);
    --display_nearest_words('prevent', model, 10, dist_metric=cosine/euclidean); --revisit

end

----cosine similarity
--mlp = nn.CosineDistance()
--x = torch.Tensor({1, 2, 3})
--y = torch.Tensor({4, 5, 6})
--print(mlp:forward({x, y}))



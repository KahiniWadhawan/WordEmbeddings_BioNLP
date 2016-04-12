function predict_next_word(word1,word2,word3,word4,word5,word6,word7,word8,word9,word10, model, k)
-- Predicts the next word.
-- Inputs:
--   word1: The first word as a string.
--   word2: The second word as a string.
--   word3: The third word as a string.
--   model: Model returned by the training script.
--   k: The k most probable predictions are shown.
-- Example usage:
--   predict_next_word('john', 'might', 'be', model, 3);
--   predict_next_word('life', 'in', 'new', model, 3);

vocab = model.vocab;
id1 = vocab[word1];
print('id1::',id1)
id2 = vocab[word2];
id3 = vocab[word3];
id4 = vocab[word4];
id5 = vocab[word5];
id6 = vocab[word6];
id7 = vocab[word7];
id8 = vocab[word8];
id9 = vocab[word9];
id10 = vocab[word10];

if id1 == nil then
   print('id1')
   print('Word not in vocabulary:', word1);
  return;
end
if id2 == nil then
   print('Word not in vocabulary:', word2);
  return;
end
if id3 == nil then
   print('Word not in vocabulary:', word3);
  return;
end
if id4 == nil then
    print('Word not in vocabulary:', word4);
    return;
end
if id5 == nil then
    print('Word not in vocabulary:', word5);
    return;
end
if id6 == nil then
    print('Word not in vocabulary:', word6);
    return;
end
if id7 == nil then
    print('Word not in vocabulary:', word7);
    return;
end
if id8 == nil then
    print('Word not in vocabulary:', word8);
    return;
end
if id9 == nil then
    print('Word not in vocabulary:', word9);
    return;
end
if id10 == nil then
    print('Word not in vocabulary:', word10);
    return;
end
--input = [id1; id2; id3];
input = torch.Tensor({id1,id2,id3,id4,id5,id6,id7,id8,id9,id10}):reshape(1,10);

output = model:forward(input):exp();

prob, indices = torch.sort(output,true);
vocab_ByIndex = model.vocab_ByIndex;

--print(prob,indices)
for i = 1,k do
  print(string.format("%s %s %s %s Prob: %f", word1, word2, word3, vocab_ByIndex[indices[1][i]], prob[1][i]));
end


end
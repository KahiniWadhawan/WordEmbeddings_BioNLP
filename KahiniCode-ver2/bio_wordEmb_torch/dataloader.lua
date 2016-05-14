--local matio = require 'matio'

--#!/usr/bin/env th
-- works on 42 million train csv size
-- Read CSV file

require 'torch'

-- --------------------------------------------------------------------
-- Helper functions
function string:split(sep)
    local sep, fields = sep, {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(substr) fields[#fields + 1] = substr end)
    return fields
end

function rows_cols_count(filePath)
    local i = 0
    for line in io.lines(filePath) do
        --print('counting')
        if i == 0 then
            COLS = #line:split(',')
        end
        i = i + 1
    end

    ROWS = i  -- in our case no header is there
    --print('2',ROWS,COLS)
    return ROWS,COLS

end

function read_CSVto_tensor(filePath)
    -- Read data from CSV to tensor
    --local filePath = '../../data/back_CSV/CSVFiles/train.csv'
    -- Count number of rows and columns in file
    --count_rc()
    --print(filePath)
    local i = 0
    for line in io.lines(filePath) do
        if i == 0 then
            COLS = #line:split(',')
        end
        i = i + 1
    end

    ROWS = i  -- in our case no header is there
    --print('2',ROWS,COLS)

    local data = torch.Tensor(ROWS, COLS):zero()
    local csvFile = io.open(filePath, "r")
    local header = csvFile:read():split(',')

    local i = 1
    for key, val in ipairs(header) do
        data[i][key] = val
    end
    for line in csvFile:lines('*l') do
        i = i + 1
--        if i%100 == 0 then
--            --print('processing row ',i)
--        end
        local l = line:split(',')
        for key, val in ipairs(l) do
            data[i][key] = val
        end
    end

    csvFile:close()

    return data
end

function read_train_CSVto_tensor(filePath,N,COLS,last_read)
    --print('inside read train csv to tensor N, COLS :: ',N,COLS )
    local data = torch.Tensor(N, COLS):zero()
    --print('$$$$$$$$$ DATA created :: ',data)
    --print('$$$$$$ last read :: ', last_read)
    local csvFile = io.open(filePath, "r")

    local header = csvFile:read():split(',')
    local i = 0

    -- only insert if we are at 1st row - only for header
    if last_read == 0 then
        --print('INSIDE HEADER ')
        i = i + 1
        for key, val in ipairs(header) do
            data[i][key] = val
        end

    end
    -- revisit - to find a way to just read few lines in csvfile
    -- right now this is reading all lines in every batch request
    -- memory is saved but time is not
    -- lines excluding header start from 2nd row in csv, initializing line_count from 1
    local line_count = 1
    --print(last_read + N)
    for line in csvFile:lines('*l') do
        if i == N   then
            print('entered $$$$$$$$')
            break
        end
        line_count = line_count + 1
        if last_read < line_count and line_count < (last_read + N + 1) and i ~=N then
            i = i + 1
            --print('inside if condn, line_count, last_read :: ', line_count, last_read)
--            if i%100 == 0 then
--                print('processing row ',i)
--            end
            local l = line:split(',')
            --print('l, i  :: ', l, i )
            for key, val in ipairs(l) do
                data[i][key] = val
            end
        end
    end
    csvFile:close()
    --print('$$$$$$$$$ DATA filled :: ',data)
    return data
end

function read_CSVto_table(filePath)
    -- Read data from CSV to table
    --local filePath = '../../data/back_CSV/CSVFiles/train.csv'
    -- Count number of rows and columns in file
    --print('1',filePath)
    --count_rc()
    local data = {}
    local csvFile = io.open(filePath, "r")
    local header = csvFile:read()
    table.insert(data,header)

    for line in csvFile:lines('*l') do
        table.insert(data,line)
    end

    csvFile:close()

    --print(data)
    return data
end

-- ---------------------------------------------------------------------

function read_train(filePath)
    -- testing
    --local filePath = 'toy.csv'
    local train = read_CSVto_tensor(filePath)

    -- Serialize tensor
    local outputFilePath = 'train.th7'
    torch.save(outputFilePath, train)

    -- Deserialize tensor object
    local restored_data = torch.load(outputFilePath)

    -- Make test
    --print(train:size())
    --print(restored_data:size())
    --print(restored_data)

end

-- ---------------------------------------------------------------------

function read_vocab(filePath)
    -- testing
    --local filePath = 'vocab.csv'
    local vocab = read_CSVto_table(filePath)

--    words = {};
--    vocab_ByIndex = {};
--    vocab_size = 0;
    print('vocab size :: ', #vocab)
    for i=1, #vocab do
        local word = ''
        word = vocab[i]
        if i == 9 or i == 106 or i == 59093 then
            print('word :: ', word)
        end
        words[word] = i
        table.insert(vocab_ByIndex, word)
        vocab_size=i;
    end
    print('VOCAB LOOP DONE')
    print(#vocab)
    print('vocab by index :: ', vocab_ByIndex)

end

-- ---------------------------------------------------------------------

---- testing
--read_vocab()

-- ---------------------------------------------------------------------

function load_restof_data(N)

    vocab_filepath = 'data/CSVFiles/vocab.csv';
    train_filepath = 'data/CSVFiles/train.csv';
    valid_filepath = 'data/CSVFiles/valid.csv';
    test_filepath = 'data/CSVFiles/test.csv';

    -- ------------------------------------------------------
    -- Vocab
    -- ------------------------------------------------------
    words = {};
    vocab_ByIndex = {};
    vocab_size = 0;

    read_vocab(vocab_filepath)
    vocab = words;

    -- ------------------------------------------------------
    -- Test Data
    -- ------------------------------------------------------
    test = read_CSVto_tensor(test_filepath);
    test_temp = test:type('torch.IntTensor');
    --print('testData before')
    --print(test_temp:type(),test_temp:size());
    testData = test_temp:transpose(1,2)
    --print('testData')
    --print(testData:type(),testData:size())


    -- -----------------------------------------------------------
    -- Valid Data
    -- -----------------------------------------------------------
    valid = read_CSVto_tensor(valid_filepath);
    valid_temp = valid:type('torch.IntTensor');
    --print('validData before')
    --print(valid_temp:type(),valid_temp:size());
    validData = valid_temp:transpose(1,2)
    --print('validData')
    --print(validData:type(),validData:size())

--    -- -----------------------------------------------------
--    -- Train Data - uncomment
--    -- -----------------------------------------------------
--    train = read_CSVto_tensor(train_filepath);
--    train_temp = train:type('torch.IntTensor');
--    print('trainData before')
--    print(train_temp:type(),train_temp:size());
--    trainData = train_temp:transpose(1,2)
--    --print('trainData ::')
--    print('trainData')
--    print(trainData:type(),trainData:size())

    -- --------------------------------------------------------------------
    -- Converting 2D tensors of entire dataset to 3D for Batch Processing
    -- --------------------------------------------------------------------
    -- accessing columns not rows, so can be applied directly to chunk/batch
--    numdims = (#trainData)[1];
--    D = numdims - 1;
--    M = math.floor((#trainData)[2] / N);
--
--    -- revisit - couldnot understand
--    train_input = torch.reshape(trainData[{ {1,D},{1,N*M} }],D,N,M);
--    --print('train_input :: ')
--    --print(train_input:size())
--    train_target = torch.reshape(trainData[{ {D + 1},{1,N * M} }], 1, N, M);
--    --print('train_target :: ')
--    --print(train_target:size())
--    valid_input = validData[{ {1,D},{} }];
--    --print('valid_input :: ')
--    --print(valid_input:size())
--    valid_target = validData[{ {D + 1},{} }];
--    test_input = testData[{ {1,D},{} }];
--    test_target = testData[{ {D + 1}, {} }];

    -- -------------------------------------------------------------------------
    -- modified version - uncomment
    -- creating train_input and train_target - but here 2D tensors
    -- --------------------------------------------------------------------------
--    numdims = (#trainData)[1];
--    D = numdims - 1;
--    train_input = torch.reshape(trainData[{ {1,D},{} }],D,N);
--    train_target = torch.reshape(trainData[{ {D + 1},{} }],1,N);
-- ------------------------------------------------------------------------------------

    numdims = (#validData)[1];
    D = numdims - 1;
    --print('number of dim valid :: ', D)

    valid_input = validData[{ {1,D},{} }];
    valid_target = validData[{ {D + 1},{} }];
    test_input = testData[{ {1,D},{} }];
    test_target = testData[{ {D + 1}, {} }];
    -- -----------------------------------------------------------------------
    -- counting rows and cols train data
    -- ----------------------------------------------------------------------
    train_rows,train_cols = rows_cols_count(train_filepath)

    print('DATA LOADED SUCCESSFULLY')

    return valid_input, valid_target, test_input, test_target, vocab,
    vocab_size, vocab_ByIndex, train_rows, train_cols

end


function load_train_data(N,train_cols,last_read)

    train_filepath = 'data/CSVFiles/train.csv';

    -- -----------------------------------------------------
    -- Train Data
    -- -----------------------------------------------------
    --print('train_cols :: ', train_cols)
    train = read_train_CSVto_tensor(train_filepath,N,train_cols,last_read);
    train_temp = train:type('torch.IntTensor');
    --print('trainData before')
    --print(train_temp:type(),train_temp:size());
    trainData = train_temp:transpose(1,2)
    --print('trainData after')
    --print(trainData:type(),trainData:size())

    -- --------------------------------------------------------------------
    -- Converting 2D tensors of entire dataset to 3D for Batch Processing
    -- --------------------------------------------------------------------
    -- accessing columns not rows, so can be applied directly to chunk/batch
    --    numdims = (#trainData)[1];
    --    D = numdims - 1;
    --    M = math.floor((#trainData)[2] / N);
    --
    --    -- revisit - couldnot understand
    --    train_input = torch.reshape(trainData[{ {1,D},{1,N*M} }],D,N,M);
    --    --print('train_input :: ')
    --    --print(train_input:size())
    --    train_target = torch.reshape(trainData[{ {D + 1},{1,N * M} }], 1, N, M);
    --    --print('train_target :: ')
    --    --print(train_target:size())
    --    valid_input = validData[{ {1,D},{} }];
    --    --print('valid_input :: ')
    --    --print(valid_input:size())
    --    valid_target = validData[{ {D + 1},{} }];
    --    test_input = testData[{ {1,D},{} }];
    --    test_target = testData[{ {D + 1}, {} }];

    -- -----------------------------------------------------------------
    -- modified version
    -- creating train_input and train_target - but here 2D tensors
    -- ------------------------------------------------------------------
    numdims = (#trainData)[1];
    D = numdims - 1;
    train_input = torch.reshape(trainData[{ {1,D},{} }],D,N);
    train_target = torch.reshape(trainData[{ {D + 1},{} }],1,N);


    -- -----------------------------------------------------------------------
    print('Train DATA LOADED SUCCESSFULLY')

    return train_input, train_target

end


---- testing
--batchsize = 2;
--train_cols = 11;
--last_read = 0;
--train_rows = rows_cols_count('data/CSVFiles/train.csv')
--numbatches = math.floor(train_rows/batchsize);
--
--
--function getNextBatch(m,last_read)
--    --print('-----------3---------------');
--    -- extracting batchsize - 2d matrix from 3d matrix
--    -- here we can simply read our 2d csv, convert to tensor upto batchsize
--    input, target = load_train_data(batchsize,train_cols,last_read);
--    --transposing to make 10Xm to mX10, so each row  is one sample
--    -- earlier one sample is one col
--    -- now we want one sample to be one row
--    input_batch = input:transpose(1,2);
--    target_batch = target:transpose(1,2);
--    target_batch = torch.reshape(target_batch,(#target_batch)[1]); -- convert targets to a vector;
--    dataset = {};
--    function dataset:size() return (#target)[2] end
--    for i=1,dataset:size() do
--        local input = input_batch[i];
--        local output = target_batch[i];
--
--        dataset[i] = {input, output}
--    end
--    print('DATASET every batch :: ', dataset)
--    return dataset, input_batch, target_batch;
--
--end
--
--for m = 1, numbatches do
--
--    print(string.format("Batch #%.0f of %.0f ",m,numbatches));
--    dataset,_,_ = getNextBatch(m,last_read);
--    print('dataset :: ');
--    print(dataset);
--    last_read = last_read + batchsize;
--end
--
--
--valid_input, valid_target, test_input, test_target, vocab, vocab_size,
--vocab_ByIndex, train_rows, train_cols = load_restof_data(batchsize);
--
--print(valid_input);
--print(valid_target);
--print(test_input);
--print(test_target)
--
--



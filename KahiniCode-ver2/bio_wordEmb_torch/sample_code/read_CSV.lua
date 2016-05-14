#!/usr/bin/env th
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

function read_CSVto_tensor(filePath)
    -- Read data from CSV to tensor
    --local filePath = '../../data/back_CSV/CSVFiles/train.csv'
    -- Count number of rows and columns in file
    print('1',filePath)
    --count_rc()
    local i = 0
    for line in io.lines(filePath) do
        --print('counting')
        if i == 0 then
            COLS = #line:split(',')
        end
        i = i + 1
    end

    ROWS = i  -- in our case no header is there
    print('2',ROWS,COLS)

    local data = torch.Tensor(ROWS, COLS)
    local csvFile = io.open(filePath, "r")
    local header = csvFile:read():split(',')

    local i = 1
    for key, val in ipairs(header) do
        data[i][key] = val
    end
    --print('3')
    print('csv file :: ',type(csvFile:lines('*l')))
    print('read :: ',csvFile:read(2))
    for line in csvFile:lines('*l') do
        i = i + 1
        if i%100 == 0 then
            print('processing row ',i)
        end
        print('4')
        local l = line:split(',')
        for key, val in ipairs(l) do
            data[i][key] = val
        end
    end

    csvFile:close()

    return data
end

function read_train()
    -- testing
    local filePath = 'toy.csv'
    local train = read_CSVto_tensor(filePath)

    -- Serialize tensor
    local outputFilePath = 'train.th7'
    torch.save(outputFilePath, train)

    -- Deserialize tensor object
    local restored_data = torch.load(outputFilePath)

    -- Make test
    print(train:size())
    print(restored_data:size())
    --print(restored_data)

end

-- testing
read_train()
require 'os'
function trim1(s)
    s1 = s:gsub("^%s*(.-)%s*$", "%1")
    --s1 = s:match "^%s*(.-)%s*$"
    --s1 = s:gsub("^%s+", ""):gsub("%s+$", "")
    return s1
end
startt = os.time()
print(startt)
s = "   polymerase"
print(s)
print('out::',"polymerase"==trim1(s))
endt = os.time()

print('time taken::',endt-startt)
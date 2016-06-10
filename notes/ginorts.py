
S = 'Sorting1234'

g = sorted(S, key=lambda x: (x.isdigit() - x.islower(), x in '02468', x))
print(''.join(g))
# print(ord(S))
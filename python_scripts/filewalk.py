import os

def fileList(source, beginswith, endswith):
    assert type(beginswith) == str and type(endswith) == str
    matches = []
    for root, dirnames, filenames in os.walk(source):
        for filename in filenames:
            if filename.endswith((endswith)) and filename.startswith((beginswith)):
                matches.append(os.path.join(root, filename))
    return sorted(matches)


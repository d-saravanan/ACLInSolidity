import os,json

def readConfiguration():
    fpath = os.path.relpath("config/eth-abi-config.json")
    with open(fpath) as json_data:
        d = json.load(json_data)
    # print(d["contractAddress"])
    return d

# print (readConfiguration())
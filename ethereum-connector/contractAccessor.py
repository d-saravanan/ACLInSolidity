import json
import web3

from web3 import Web3, HTTPProvider, TestRPCProvider
# from web3.contract import ConciseContract

w3 = Web3(HTTPProvider("http://127.0.0.1:7545"))

# print('hello from web3 python')

# copy the contract deployed address by running the truffle migrate --reset from the command line
# paste the copied address and paste the value in https://ethsum.netlify.com/
# aclContractAddress = '0x260811A4b0C09352B6D02fe7a132AA8Ac217e14D'

import filereader
configuration = filereader.readConfiguration()
aclContractAddress = Web3.toChecksumAddress(configuration["contractAddress"])

# get the ABI from the contracts folder and the contractname with json file extension

aclContractABI = configuration["contractABI"]
# aclContractABI = [
#     {
#       "anonymous": False,
#       "inputs": [
#         {
#           "indexed": True,
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "indexed": False,
#           "name": "docHash",
#           "type": "string"
#         }
#       ],
#       "name": "DocumentAddedForAPatient",
#       "type": "event"
#     },
#     {
#       "anonymous": False,
#       "inputs": [
#         {
#           "indexed": False,
#           "name": "patAddr",
#           "type": "address"
#         },
#         {
#           "indexed": False,
#           "name": "docAddr",
#           "type": "address"
#         }
#       ],
#       "name": "DoctorMapped",
#       "type": "event"
#     },
#     {
#       "anonymous": False,
#       "inputs": [
#         {
#           "indexed": True,
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "indexed": True,
#           "name": "doctorAddress",
#           "type": "address"
#         }
#       ],
#       "name": "doctorPatientMappingDoesNotExist",
#       "type": "event"
#     },
#     {
#       "constant": True,
#       "inputs": [],
#       "name": "test",
#       "outputs": [
#         {
#           "name": "",
#           "type": "bool"
#         }
#       ],
#       "payable": False,
#       "stateMutability": "pure",
#       "type": "function"
#     },
#     {
#       "constant": False,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "name": "doctorAddress",
#           "type": "address"
#         }
#       ],
#       "name": "removeDoctor",
#       "outputs": [],
#       "payable": False,
#       "stateMutability": "nonpayable",
#       "type": "function"
#     },
#     {
#       "constant": True,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         }
#       ],
#       "name": "getPatientDocumentCount",
#       "outputs": [
#         {
#           "name": "",
#           "type": "uint256"
#         }
#       ],
#       "payable": False,
#       "stateMutability": "view",
#       "type": "function"
#     },
#     {
#       "constant": False,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "name": "documentHash",
#           "type": "string"
#         }
#       ],
#       "name": "addDocumentForPatient",
#       "outputs": [],
#       "payable": False,
#       "stateMutability": "nonpayable",
#       "type": "function"
#     },
#     {
#       "constant": True,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         }
#       ],
#       "name": "checkDocumentExists",
#       "outputs": [
#         {
#           "name": "",
#           "type": "bool"
#         }
#       ],
#       "payable": False,
#       "stateMutability": "view",
#       "type": "function"
#     },
#     {
#       "constant": True,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "name": "documentHash",
#           "type": "string"
#         }
#       ],
#       "name": "isDocumentAdded",
#       "outputs": [
#         {
#           "name": "",
#           "type": "bool"
#         }
#       ],
#       "payable": False,
#       "stateMutability": "view",
#       "type": "function"
#     },
#     {
#       "constant": True,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         }
#       ],
#       "name": "getPatientDocuments",
#       "outputs": [
#         {
#           "name": "",
#           "type": "string[]"
#         }
#       ],
#       "payable": False,
#       "stateMutability": "view",
#       "type": "function"
#     },
#     {
#       "constant": False,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "name": "doctorAddress",
#           "type": "address"
#         }
#       ],
#       "name": "registerDoctors",
#       "outputs": [],
#       "payable": False,
#       "stateMutability": "nonpayable",
#       "type": "function"
#     },
#     {
#       "constant": True,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         }
#       ],
#       "name": "getDoctorCountPerPatient",
#       "outputs": [
#         {
#           "name": "",
#           "type": "uint256"
#         }
#       ],
#       "payable": False,
#       "stateMutability": "view",
#       "type": "function"
#     },
#     {
#       "constant": False,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "name": "targetUserAddress",
#           "type": "address"
#         },
#         {
#           "name": "documentHash",
#           "type": "string"
#         }
#       ],
#       "name": "revokeAllPermissionsForDocument",
#       "outputs": [],
#       "payable": False,
#       "stateMutability": "nonpayable",
#       "type": "function"
#     },
#     {
#       "constant": False,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "name": "targetUserAddress",
#           "type": "address"
#         },
#         {
#           "name": "documentHash",
#           "type": "string"
#         },
#         {
#           "name": "permissionToRevoke",
#           "type": "uint256"
#         }
#       ],
#       "name": "revokePermissionForDocument",
#       "outputs": [],
#       "payable": False,
#       "stateMutability": "nonpayable",
#       "type": "function"
#     },
#     {
#       "constant": False,
#       "inputs": [
#         {
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "name": "documentHash",
#           "type": "string"
#         },
#         {
#           "name": "doctorAddress",
#           "type": "address"
#         },
#         {
#           "name": "permission",
#           "type": "uint256"
#         }
#       ],
#       "name": "shareDocumentWithDoctor",
#       "outputs": [],
#       "payable": False,
#       "stateMutability": "nonpayable",
#       "type": "function"
#     },
#     {
#       "constant": True,
#       "inputs": [
#         {
#           "name": "doctorAddress",
#           "type": "address"
#         },
#         {
#           "name": "patientAddress",
#           "type": "address"
#         },
#         {
#           "name": "documentHash",
#           "type": "string"
#         }
#       ],
#       "name": "checkPermissionGrant",
#       "outputs": [
#         {
#           "name": "",
#           "type": "uint256[]"
#         }
#       ],
#       "payable": False,
#       "stateMutability": "view",
#       "type": "function"
#     }
#   ]
# userAddress = getUser()

w3.eth.defaultAccount = w3.eth.accounts[1]
# print (w3.eth.accounts[1])
from web3.contract import ConciseContract
contract_instance = w3.eth.contract(address=aclContractAddress, abi=aclContractABI, ContractFactoryClass=ConciseContract)

# print (aclContractAddress)
# print (contract_instance)


import time

def wait_for_receipt(w3, tx_hash, poll_interval):
   while True:
       tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
       if tx_receipt:
         return tx_receipt
       time.sleep(poll_interval)

from pprint import pprint
# pprint(vars(contract_instance.functions.test()))
# print (contract_instance.functions.test().call())

print(contract_instance.addDocumentForPatient(w3.eth.accounts[1],"qwer", transact={'from':w3.eth.accounts[1]}))
print(contract_instance.addDocumentForPatient(w3.eth.accounts[1],"1234", transact={'from':w3.eth.accounts[1]}))
print(contract_instance.addDocumentForPatient(w3.eth.accounts[1],"plmn", transact={'from':w3.eth.accounts[1]}))
# print(contract_instance.getPatientDocumentCount(w3.eth.accounts[1], transact={'from':w3.eth.accounts[1]}))
# print(contract_instance.isDocumentAdded(w3.eth.accounts[1],"qwer", transact={'from':w3.eth.accounts[1]}))
# print(contract_instance.isDocumentAdded(w3.eth.accounts[1],"1234", transact={'from':w3.eth.accounts[1]}))
print(contract_instance.getPatientDocumentCount(w3.eth.accounts[1]))
# print(contract_instance.getPatientDocuments(w3.eth.accounts[1]))
# contract_instance.functions.addDocumentForPatient(w3.eth.accounts[0],"abcd").call()
# contract_instance.functions.checkDocumentExists(w3.eth.accounts[0]).call()

# print (contract_instance.functions.registerDoctors(w3.eth.accounts[0], w3.eth.accounts[1]).call())
# print (contract_instance.functions.getDoctorCountPerPatient(w3.eth.accounts[0]).call())
# # tx_hash = contract_instance.functions.test().transact()
# tx_hash = contract_instance.functions.registerDoctors(w3.eth.accounts[0], w3.eth.accounts[1]).transact()
# pprint(tx_hash)
# receipt = wait_for_receipt(w3, tx_hash, 1)
# print("Transaction receipt mined: \n")
# pprint(vars(((receipt))))

# tx_hash1 = contract_instance.functions.getDoctorCountPerPatient(w3.eth.accounts[0]).transact()
# pprint(tx_hash1)
# receipt1 = wait_for_receipt(w3, tx_hash1, 1)
# print("Transaction receipt mined: \n")
# pprint(vars(((receipt1))))
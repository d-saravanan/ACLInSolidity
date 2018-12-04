pragma solidity ^0.4.24;

contract Patient {
    mapping(uint => address) Relationships;
    address[] Patients;
    string[] Documents;
    address[] Doctors;
    
    /*
    * Stored in the following format
    * patientAddress => documentHash => doctorAddress => Permissions[]
    */
    mapping(address => mapping(string => mapping(address => uint[]))) patientShareDocumentAccessRights;
    /*
    * Stored in the following format
    * doctorAddress => patientAddress => documentHash => Permissions.
    */
    mapping(address => mapping(address => mapping(string => uint[]))) doctorAccessRightsCheck;
    
    mapping(address => address[]) patientDoctorMapping;
    mapping(address => string[]) patientDocuments;
    event DocumentAddedForAPatient(address indexed patientAddress, string docHash);

    function getPatientDocumentCount(address patientAddress) public view returns (uint) {
        return patientDocuments[patientAddress].length;
    }

    function addDocumentForPatient(address patientAddress, string memory documentHash) public
        checkDocumentHashExists(patientAddress, documentHash)  {
        patientDocuments[patientAddress].push(documentHash);
        emit DocumentAddedForAPatient(patientAddress, documentHash);
    }

    function checkDocumentExists(address patientAddress) public view returns (bool) {
        string[] memory patientDocs = patientDocuments[patientAddress];
        return patientDocs.length > 0;
    }

    function isDocumentAdded(address patientAddress, string memory documentHash) public view returns (bool) {
        string[] memory patientDocs = patientDocuments[patientAddress];

        if(patientDocs.length < 1) {
            return false;
        }

        for(uint i = 0; i < patientDocs.length; i++) {
            if(keccak256(bytes(patientDocs[i])) == keccak256(bytes(documentHash))) {
                return true;
            }
        }
        return false;
    }

    modifier checkDocumentHashExists(address patientAddress, string memory documentHash) {
        string[] memory patientDocs = patientDocuments[patientAddress];

        if(patientDocs.length < 1) {
            _;
        }
        return;

        for(uint i = 0; i < patientDocs.length; i++) {
            if(keccak256(bytes(patientDocs[i])) == keccak256(bytes(documentHash))) {
                _;
            }
        }
    }

    function registerDoctors(address patientAddress, address doctorAddress) public doesDoctorPatientMappingExist(patientAddress, doctorAddress) {
        patientDoctorMapping[patientAddress].push(doctorAddress);
    }

    function getDoctorCountPerPatient(address patientAddress) public view returns (uint256) {
        return patientDoctorMapping[patientAddress].length;
    }

    modifier doesDoctorPatientMappingExist(address patientAddress, address doctorAddress) {
        address[] memory mappedDoctors = patientDoctorMapping[patientAddress];

        if(mappedDoctors.length < 1) {
            _;
            return;
        }

        bool canAdd = true;
        for(uint i = 0; i < mappedDoctors.length; i++) {
            if(mappedDoctors[i] == doctorAddress){
                canAdd = false;
            }
        }

        if(canAdd) _;

        return;
    }

    function revokeAllPermissionsForDocument(address patientAddress, address targetUserAddress, string memory documentHash) public {
        //remove all the access for the recepient to that patient document
        delete patientShareDocumentAccessRights[patientAddress][documentHash][targetUserAddress];
        delete doctorAccessRightsCheck[targetUserAddress][patientAddress][documentHash];
    }

    function revokePermissionForDocument(address patientAddress, address targetUserAddress, string memory documentHash, uint permissionToRevoke) 
    public {
        uint[] storage existingPermissions = patientShareDocumentAccessRights[patientAddress][documentHash][targetUserAddress];
        patientShareDocumentAccessRights[patientAddress][documentHash][targetUserAddress] = spliceArray(existingPermissions, permissionToRevoke);

        existingPermissions = doctorAccessRightsCheck[targetUserAddress][patientAddress][documentHash];
        doctorAccessRightsCheck[targetUserAddress][patientAddress][documentHash] = spliceArray(existingPermissions, permissionToRevoke);
    }

    function spliceArray(uint[] storage input, uint elementToRemove) private returns (uint[] memory) {
        uint index = getElementIndex(input, elementToRemove);
        input[index] = input[input.length - 1];
        delete input[input.length - 1];
        input.length = input.length - 1;
        return input;
    }

    function getElementIndex(uint[] memory data, uint needle) private returns (uint) {
        uint index = 0;
        for(uint i = 0; i < data.length; i++) {
            if(data[i] == needle) {
                index = i;
            }
        }
        return index;
    }
    /*function registerPatients(address patientAddress) public {
        //This function should have the admin modifier
        Patients.push(patientAddress);
    }
    
    function addRelationship(address relatedContractAddress, uint relationshipType) public {
        Relationships[relationshipType] = relatedContractAddress;
    }
    
    function initializeDoctorContract(address doctorContractAddress) public {
        doctorContract = Doctor(doctorContractAddress);
    }
    
    function addDoctor(address doctorAddress) public {
        Doctors.push(doctorAddress);
    }
    
    function addDocument(string memory document) public {
        Documents.push(document);
    }*/
    
    function shareDocumentWithDoctor(address patientAddress, string memory documentHash, address doctorAddress, uint permission) public {
        patientShareDocumentAccessRights[patientAddress][documentHash][doctorAddress].push(permission);
        doctorAccessRightsCheck[doctorAddress][patientAddress][documentHash].push(permission);
    }
    
    function checkPermissionGrant(address doctorAddress, address patientAddress, string memory documentHash) public view returns(uint[] memory) {
        return doctorAccessRightsCheck[doctorAddress][patientAddress][documentHash];
    }

    /*
    * steps to remove a document
    * once a document is submitted for removal, remove the document from the list of patient documents
    * store the mapping of removed documents by patient address
    * whenever the check is made for checkPermissionGrant and if the address has the same document hash, remove the hash
    */
    function removeDocument(address patientAddress, string memory documentHash) public {
        //remove the document from the patient document source mapping;
    }

    /*
    function callDoctor(address doctorAddress) public returns(string memory) {
        return doctorContract.sayHello();
    }
    
    event doctorMessage(string);
    */
    
}
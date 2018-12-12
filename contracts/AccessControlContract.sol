pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract AccessControlContract {

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

    function test() public pure returns (bool) {
        return true;
    }

    function removeDoctor(address patientAddress, address doctorAddress) public {
        address[] storage patientDoctorMap = patientDoctorMapping[patientAddress];
        address[] memory updatedMap = spliceAddressArray(patientDoctorMap, doctorAddress);
        delete patientDoctorMapping[patientAddress];
        patientDoctorMapping[patientAddress] = updatedMap;
    }

    function getPatientDocumentCount(address patientAddress) public view returns (uint) {
        return patientDocuments[patientAddress].length;
    }

    function addDocumentForPatient(address patientAddress, string memory documentHash) public {
        // checkDocumentHashExists(patientAddress, documentHash)  {
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

    function getPatientDocuments(address patientAddress) public view returns (string[] memory) {
        return patientDocuments[patientAddress];
    }

    modifier checkDocumentHashExists(address patientAddress, string memory documentHash) {
        string[] memory patientDocs = patientDocuments[patientAddress];

        if(patientDocs.length < 1) {
            _;
            return;
        }
        bool isFound = true;
        for(uint i = 0; i < patientDocs.length; i++) {
            if(keccak256(bytes(patientDocs[i])) != keccak256(bytes(documentHash))) {
                isFound = false;
            }
        }

        if(!isFound){
            _;
        }
    }
    event DoctorMapped(address patAddr, address docAddr);

    function registerDoctors(address patientAddress, address doctorAddress) public 
    doesDoctorPatientMappingExist(patientAddress, doctorAddress, true) {
        patientDoctorMapping[patientAddress].push(doctorAddress);
        emit DoctorMapped(patientAddress, doctorAddress);
    }

    function getDoctorCountPerPatient(address patientAddress) public view returns (uint256) {
        return patientDoctorMapping[patientAddress].length;
    }

    modifier doesDoctorPatientMappingExist(address patientAddress, address doctorAddress, bool forAdd) {
        address[] memory mappedDoctors = patientDoctorMapping[patientAddress];

        if(mappedDoctors.length < 1 && forAdd) {
            _;
            return;
        }

        bool canAdd = true;
        for(uint i = 0; i < mappedDoctors.length; i++) {
            if(mappedDoctors[i] == doctorAddress){
                canAdd = false;
            }
        }

        if(canAdd) {
            _;
            return;
        }

        emit doctorPatientMappingDoesNotExist(patientAddress, doctorAddress);
        return;
    }

    event doctorPatientMappingDoesNotExist(address indexed patientAddress, address indexed doctorAddress);

    modifier isDoctorMappedToPatient(address patientAddress, address doctorAddress) {
        address[] memory mappedDoctors = patientDoctorMapping[patientAddress];

        if(mappedDoctors.length < 1 ) {
            revert("No valid mapping exists between the doctor and the patient. Hence erring out.");
            // return;
        }

        for(uint i = 0; i < mappedDoctors.length; i++) {
            if(mappedDoctors[i] == doctorAddress) {
                _;
                return;
            }
        }
        revert("No valid mapping exists between the doctor and the patient. Hence erring out.");
    }

    function revokeAllPermissionsForDocument(address patientAddress, address targetUserAddress, string memory documentHash) public {
        //remove all the access for the recepient to that patient document
        delete patientShareDocumentAccessRights[patientAddress][documentHash][targetUserAddress];
        delete doctorAccessRightsCheck[targetUserAddress][patientAddress][documentHash];
    }

    function revokePermissionForDocument(address patientAddress, address targetUserAddress, string memory documentHash, uint permissionToRevoke) 
    public {
        uint[] storage existingPermissions = patientShareDocumentAccessRights[patientAddress][documentHash][targetUserAddress];
        patientShareDocumentAccessRights[patientAddress][documentHash][targetUserAddress] = spliceNumericArray(existingPermissions, permissionToRevoke);

        existingPermissions = doctorAccessRightsCheck[targetUserAddress][patientAddress][documentHash];
        doctorAccessRightsCheck[targetUserAddress][patientAddress][documentHash] = spliceNumericArray(existingPermissions, permissionToRevoke);
    }

    function spliceNumericArray(uint[] storage input, uint elementToRemove) private returns (uint[] memory) {
        uint index = getNumericElementIndex(input, elementToRemove);
        input[index] = input[input.length - 1];
        delete input[input.length - 1];
        input.length = input.length - 1;
        return input;
    }

    function getNumericElementIndex(uint[] memory data, uint needle) private returns (uint) {
        uint index = 0;
        for(uint i = 0; i < data.length; i++) {
            if(data[i] == needle) {
                index = i;
            }
        }
        return index;
    }

    function spliceAddressArray(address[] storage input, address elementToRemove) private returns (address[] memory) {
        uint index = getAddressElementIndex(input, elementToRemove);
        input[index] = input[input.length - 1];
        delete input[input.length - 1];
        input.length = input.length - 1;
        return input;
    }

    function getAddressElementIndex(address[] memory data, address needle) private returns (uint) {
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
    
    function shareDocumentWithDoctor(address patientAddress, string memory documentHash, address doctorAddress, uint permission) public 
    isDoctorMappedToPatient(patientAddress, doctorAddress) {
        patientShareDocumentAccessRights[patientAddress][documentHash][doctorAddress].push(permission);
        doctorAccessRightsCheck[doctorAddress][patientAddress][documentHash].push(permission);
    }
    
    function checkPermissionGrant(address doctorAddress, address patientAddress, string memory documentHash) public 
    isDoctorMappedToPatient(patientAddress, doctorAddress)  view returns(uint[] memory) {
        return doctorAccessRightsCheck[doctorAddress][patientAddress][documentHash];
    }

    /*
    * steps to remove a document
    * once a document is submitted for removal, remove the document from the list of patient documents
    * store the mapping of removed documents by patient address
    * whenever the check is made for checkPermissionGrant and if the address has the same document hash, remove the hash
    */
    // function removeDocument(address patientAddress, string memory documentHash) public {
        //remove the document from the patient document source mapping;
    // }

    /*
    function callDoctor(address doctorAddress) public returns(string memory) {
        return doctorContract.sayHello();
    }
    
    event doctorMessage(string);
    */
    
}
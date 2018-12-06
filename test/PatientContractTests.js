var aclContract = artifacts.require('Patient');

contract('Patient', function(accounts) {

    let catchRevert = require("./exceptions.js").catchRevert;

    const patient1Address = accounts[0], patient2Address = accounts[2];
    const doctor1Address = accounts[1], doctor2Address = accounts[3];
    const invalidAddress = accounts[5];
    const ecgReportHash = "QmWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t"; //Some patient data file hash from IPFS like a BLOOD_Test_Report
    const echoReportHash = "QmT4AeWE9Q9EaoyLJiqaZuYQ8mJeq4ZBncjjFH9dQ9uDVA";
    const bloodTestReportHash = "QmT9qk3CRYbFDWpDFYeAv8T8H1gnongwKhh5J68NLkLir6";
    const ViewDocumentPermission = 1, EditDocumentPermission = 2, DeleteDocumentPermission = 3;

    it("should print all the doctor and the patien addresses", function() {
        
        //let address = '0x0000000000000000000000000000000000000000';
        const emptyAddressRegex = /^0x0+$/;
        
        assert.equal(emptyAddressRegex.test(patient1Address), false);
        assert.equal(emptyAddressRegex.test(patient2Address), false);
        assert.equal(emptyAddressRegex.test(doctor1Address), false);
        assert.equal(emptyAddressRegex.test(doctor2Address), false);
    });

    /*
    * Test setup, creating a new instance for every test method to execute so that the same instance is not being updated for every test method run.
    */
    let instance;
    beforeEach('setup contract instance for each test case execution', async () => {
        instance = await aclContract.new();
    });

    //address patientAddress, string memory documentHash, address doctorAddress, uint permission => Sharing document with Doctor
    //address doctorAddress, address patientAddress, string memory documentHash => checking access for doctor
    it("should be able to get the permission for the document which was shared by a patient with a doctor", async () => {
        //Arrange
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);

        //Act
        let permissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        
        //Assert
        assert.equal(permissions.length , 1);
        assert.equal(doesPermissionExist(permissions, [ViewDocumentPermission]));
     });

    it("should allow to add a doctor for a patient", async () => {
        //Act
        await instance.registerDoctors(patient1Address, doctor1Address);
       //Act
       let doctorCount = await instance.getDoctorCountPerPatient(patient1Address);
       //Assert
       assert.equal(doctorCount.toNumber() ,1);
    })

    it("should succeed with 2 patients sharing their documents with a same doctor and doctor having permissions to view the documents", async () => {
        //Arrange
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.registerDoctors(patient2Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);
        await instance.shareDocumentWithDoctor(patient2Address, ecgReportHash, doctor1Address, ViewDocumentPermission);

        //Act
        let permissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        let permissions2 = await instance.checkPermissionGrant(doctor1Address, patient2Address, ecgReportHash);
        
        //Assert
        assert.equal(permissions.length , 1);
        assert.equal(doesPermissionExist(permissions, [ViewDocumentPermission]));

        assert.equal(permissions2.length , 1);
        assert.equal(doesPermissionExist(permissions2, [ViewDocumentPermission]));
    });

    it("should be able to share a document with more than 1 permission to a doctor and get the multiple permissions on validation", async () => {
        //Arrange 
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, EditDocumentPermission);
 
        //Act
        let permissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        
        //Assert
        assert.equal(permissions.length , 2);
        assert.equal(doesPermissionExist(permissions, [ViewDocumentPermission, EditDocumentPermission]));
    });

    it("should allow a single patient to share a document with more than 1 doctor with different permissions", async () => {
        //Arrange 
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.registerDoctors(patient1Address, doctor2Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor2Address, EditDocumentPermission);

        //Act
        let permissionsForDoctor1 = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        let permissionsForDoctor2 = await instance.checkPermissionGrant(doctor2Address, patient1Address, ecgReportHash);

        //Assert
        assert.equal(permissionsForDoctor1.length , 1);
        assert.equal(doesPermissionExist(permissionsForDoctor1, [ViewDocumentPermission]));

        assert.equal(permissionsForDoctor2.length , 1);
        assert.equal(doesPermissionExist(permissionsForDoctor2, [EditDocumentPermission]));
    });

    it("should not return permissions when no document is shared with a doctor", async () => {
        //Act
        await instance.registerDoctors(patient1Address, doctor1Address);
        let permissionsForDoctor1 = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        //Assert
        assert.equal(permissionsForDoctor1.length ,0);
    });

    it("should allow single patient sharing multiple documents with a single doctor with different permissions", async () => {
        //Arrange
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);
        await instance.shareDocumentWithDoctor(patient1Address, echoReportHash, doctor1Address, EditDocumentPermission);

        //Act
        let permissionSet1 = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        let permissionSet2 = await instance.checkPermissionGrant(doctor1Address, patient1Address, echoReportHash);

        //Assert
        assert.equal(permissionSet1.length , 1);
        assert.equal(doesPermissionExist(permissionSet1, [ViewDocumentPermission]));

        assert.equal(permissionSet2.length , 1);
        assert.equal(doesPermissionExist(permissionSet2, [EditDocumentPermission]));
    });

    it("should not allow access to a doctor that is not granted access, but another doctor has access to the document", async () => {
        //Arrange
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.registerDoctors(patient1Address, doctor2Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);

        //Act
        let permissionSet1 = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        let permissionSet2 = await instance.checkPermissionGrant(doctor2Address, patient1Address, echoReportHash);

        //Assert
        assert.equal(permissionSet1.length , 1);
        assert.equal(doesPermissionExist(permissionSet1, [ViewDocumentPermission]));

        assert.equal(permissionSet2.length , 0);
    });

    it("should not return any permission for a document hash that is not shared with the doctor by the patient", async () => {
        //Arrange
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);

        //Act
        let permissionSet1 = await instance.checkPermissionGrant(doctor1Address, patient1Address, echoReportHash);
        
        //Assert
        assert.equal(permissionSet1.length , 0);
    });

    it("should not return any permission for a patient that does not exist", async () => {
    
        //Arrange
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);

        //Act
        let checkPermissionGrantCheck = instance.checkPermissionGrant(doctor1Address, invalidAddress, echoReportHash);

        //Assert
        await catchRevert(checkPermissionGrantCheck);
    });

    it("should not return any permission for a doctor that does not exist", async () => {
        //Arrange
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);

        //Act
        let checkPermissionGrantCheck = instance.checkPermissionGrant(invalidAddress, patient1Address, echoReportHash);

        //Assert
        await catchRevert(checkPermissionGrantCheck);
    });

    /*
    * Testing the document dictionary
    */
    it("should be able to add a new document for a given patient and there should be non-empty collection", async () => {
        //Arrange
        await instance.addDocumentForPatient(patient1Address, ecgReportHash);

        //Act
        let permissionSet1 = await instance.checkDocumentExists(patient1Address);
        
        //Assert
        assert.equal(permissionSet1 , true);
    });

    it("should be able to add a document for a given patient and there should exist a document with the same hash", async () => {
        //Arrange
        await instance.addDocumentForPatient(patient1Address, ecgReportHash);

        //Act
        let permissionSet1 = await instance.isDocumentAdded(patient1Address, ecgReportHash);
        
        //Assert
        assert.equal(permissionSet1 , true);
    });

    it("should not allow adding a same document hash for a given patient", async () => {
        //Arrange
        await instance.addDocumentForPatient(patient1Address, ecgReportHash);
        await instance.addDocumentForPatient(patient1Address, ecgReportHash);
        
        //Act
        let documentCount = await instance.getPatientDocumentCount(patient1Address);
        
        //Assert
        assert.equal(documentCount.toNumber() , 1);
    });

    it("should not allow same doctor to be mapped multiple times to a given patient", async () => {
        //Arrange
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.registerDoctors(patient1Address, doctor1Address);

        //Act
        let doctorCount = await instance.getDoctorCountPerPatient(patient1Address);

        //Assert
        assert.equal(doctorCount.toNumber() , 1);
    });

    it("should not return the permissions for the document to which the user's permissions were revoked", async() => {
        //Arrange 1. Share the document with the Doctor
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);

        //Act
        let permissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        await instance.revokeAllPermissionsForDocument(patient1Address, doctor1Address, ecgReportHash);
        let updatedPermissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        
        //Assert
        assert.equal(permissions.length , 1);
        assert.equal(updatedPermissions.length, 0); // after revoke, no permissions.
    });

    it("should revoke a single permission for a shared document with a doctor", async () => {
        //Arrange 1. Share the document with the Doctor
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, EditDocumentPermission);

        let beforeRevokePermissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        
        //Act
        await instance.revokePermissionForDocument(patient1Address, doctor1Address, ecgReportHash, EditDocumentPermission);

        let afterRevokePermissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        assert.equal(beforeRevokePermissions.length, 2);
        assert.equal(afterRevokePermissions.length, 1);

        assert.equal(doesPermissionExist(afterRevokePermissions,[ViewDocumentPermission]));
    });

    it("should not return any permission for the doctor after the patient revokes all the permissions", async () => {
        //Arrange 1. Share the document with the Doctor
        await instance.registerDoctors(patient1Address, doctor1Address);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, ViewDocumentPermission);
        await instance.shareDocumentWithDoctor(patient1Address, ecgReportHash, doctor1Address, EditDocumentPermission);

        let beforeRevokePermissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        
        //Act
        await instance.revokePermissionForDocument(patient1Address, doctor1Address, ecgReportHash, EditDocumentPermission);
        await instance.revokePermissionForDocument(patient1Address, doctor1Address, ecgReportHash, ViewDocumentPermission);

        let afterRevokePermissions = await instance.checkPermissionGrant(doctor1Address, patient1Address, ecgReportHash);
        assert.equal(beforeRevokePermissions.length, 2);
        assert.equal(afterRevokePermissions.length, 0);
    });

    function doesPermissionExist(returnResponseArray, target) {
        returnResponseArray.filter(value => -1 !== target.indexOf(value.toNumber()));
    }
});
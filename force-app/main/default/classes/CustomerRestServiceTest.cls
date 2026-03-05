/**
 * Unit tests for CustomerRestService REST API
 * Tests GET, POST, PATCH, DELETE operations for Customers
 */
@IsTest
private class CustomerRestServiceTest {
    
    @TestSetup
    static void setupData() {
        Customer__c customer = new Customer__c(
            Name = 'John Doe',
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@example.com',
            Phone__c = '+359888123123',
            Birth_Date__c = Date.newInstance(1990, 5, 15),
            Loyalty_Points__c = 100,
            Is_Active__c = true
        );
        insert customer;
    }
    
    @IsTest
    static void testGetCustomers_WithoutSearch_ReturnsAllCustomers() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'GET';
        req.addParameter('page', '1');
        req.addParameter('pageSize', '10');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.getCustomers();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assertEquals(1, response.get('total'));
        System.assert(response.containsKey('records'));
    }
    
    @IsTest
    static void testGetCustomers_WithSearchFirstName_ReturnsFilteredCustomers() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'GET';
        req.addParameter('search', 'John');
        req.addParameter('page', '1');
        req.addParameter('pageSize', '10');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.getCustomers();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assertEquals(1, response.get('total'));
        List<Object> records = (List<Object>) response.get('records');
        System.assertEquals(1, records.size());
    }
    
    @IsTest
    static void testGetCustomers_WithSearchEmail_ReturnsFilteredCustomers() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'GET';
        req.addParameter('search', 'john.doe@example.com');
        req.addParameter('page', '1');
        req.addParameter('pageSize', '10');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.getCustomers();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assertEquals(1, response.get('total'));
    }
    
    @IsTest
    static void testGetCustomers_WithSearchNoMatch_ReturnsEmpty() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'GET';
        req.addParameter('search', 'NonexistentCustomer');
        req.addParameter('page', '1');
        req.addParameter('pageSize', '10');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.getCustomers();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assertEquals(0, response.get('total'));
    }
    
    @IsTest
    static void testGetCustomers_Pagination() {
        // Create multiple customers
        List<Customer__c> customers = new List<Customer__c>();
        for (Integer i = 0; i < 12; i++) {
            customers.add(new Customer__c(
                Name = 'Customer ' + i,
                First_Name__c = 'First ' + i,
                Last_Name__c = 'Last ' + i,
                Email__c = 'customer' + i + '@example.com',
                Is_Active__c = true
            ));
        }
        insert customers;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'GET';
        req.addParameter('page', '1');
        req.addParameter('pageSize', '5');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.getCustomers();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        List<Object> records = (List<Object>) response.get('records');
        
        System.assertEquals(5, records.size());
        System.assertEquals(13, response.get('total')); // 12 new + 1 from setup
    }
    
    @IsTest
    static void testCreateCustomer_WithValidData_CreatesSuccessfully() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{' +
            '"First_Name__c":"Jane",' +
            '"Last_Name__c":"Smith",' +
            '"Email__c":"jane.smith@example.com",' +
            '"Phone__c":"+359888222222"' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.createCustomer();
        Customer__c createdCustomer = (Customer__c) JSON.deserialize(result, Customer__c.class);
        
        System.assertNotEquals(null, createdCustomer.Id);
        System.assertEquals('Jane Smith', createdCustomer.Name);
        System.assertEquals('jane.smith@example.com', createdCustomer.Email__c);
        System.assertEquals(true, createdCustomer.Is_Active__c);
        System.assertEquals(201, RestContext.response.statusCode);
    }
    
    @IsTest
    static void testCreateCustomer_WithMissingFirstName_FailsValidation() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{' +
            '"Last_Name__c":"Smith",' +
            '"Email__c":"test@example.com"' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.createCustomer();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assert(response.containsKey('error'));
        System.assert(((String) response.get('error')).contains('required'));
    }
    
    @IsTest
    static void testCreateCustomer_WithInvalidEmail_FailsValidation() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{' +
            '"First_Name__c":"Test",' +
            '"Last_Name__c":"User",' +
            '"Email__c":""' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.createCustomer();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assert(response.containsKey('error'));
    }
    
    @IsTest
    static void testUpdateCustomer_WithValidData_UpdatesSuccessfully() {
        Customer__c customer = [SELECT Id FROM Customer__c LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers/' + customer.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{' +
            '"Phone__c":"+359888999999",' +
            '"Loyalty_Points__c":250' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.updateCustomer();
        Customer__c updatedCustomer = (Customer__c) JSON.deserialize(result, Customer__c.class);
        
        System.assertEquals('+359888999999', updatedCustomer.Phone__c);
        System.assertEquals(250, updatedCustomer.Loyalty_Points__c);
    }
    
    @IsTest
    static void testUpdateCustomer_PartialUpdate_UpdatesOnlyProvidedFields() {
        Customer__c originalCustomer = [SELECT Id, Phone__c, Loyalty_Points__c FROM Customer__c LIMIT 1];
        String originalPhone = originalCustomer.Phone__c;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers/' + originalCustomer.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{' +
            '"Loyalty_Points__c":500' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.updateCustomer();
        Customer__c updatedCustomer = (Customer__c) JSON.deserialize(result, Customer__c.class);
        
        System.assertEquals(originalPhone, updatedCustomer.Phone__c, 'Phone should not change');
        System.assertEquals(500, updatedCustomer.Loyalty_Points__c);
    }
    
    @IsTest
    static void testDeleteCustomer_WithValidId_DeletesSuccessfully() {
        Customer__c customer = [SELECT Id FROM Customer__c LIMIT 1];
        Id customerId = customer.Id;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers/' + customerId;
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        CustomerRestService.deleteCustomer();
        
        List<Customer__c> deletedCustomers = [SELECT Id FROM Customer__c WHERE Id = :customerId];
        System.assertEquals(0, deletedCustomers.size());
    }
    
    @IsTest
    static void testCreateCustomer_WithDefaultValues_SetsProperDefaults() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/customers';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{' +
            '"First_Name__c":"Default",' +
            '"Last_Name__c":"User",' +
            '"Email__c":"default@example.com"' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = CustomerRestService.createCustomer();
        Customer__c createdCustomer = (Customer__c) JSON.deserialize(result, Customer__c.class);
        
        System.assertEquals(true, createdCustomer.Is_Active__c, 'Should default to active');
    }
}

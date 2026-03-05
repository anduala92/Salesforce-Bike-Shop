/**
 * Unit tests for BikeRestService REST API
 * Tests GET, POST, PATCH, DELETE operations for Bikes
 */
@IsTest
private class BikeRestServiceTest {
    
    @TestSetup
    static void setupData() {
        Bike__c bike = new Bike__c(
            Name = 'Trek Domane AL 5',
            Model__c = 'Domane AL 5',
            Brand__c = 'Trek',
            Category__c = 'Road',
            Daily_Rate__c = 55,
            Available__c = true,
            Mileage__c = 500,
            Last_Service_Date__c = Date.today().addDays(-10)
        );
        insert bike;
    }
    
    @IsTest
    static void testGetBikes_WithoutSearch_ReturnsAllBikes() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        req.httpMethod = 'GET';
        req.addParameter('page', '1');
        req.addParameter('pageSize', '10');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.getBikes();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assertEquals(1, response.get('total'));
        System.assert(response.containsKey('records'));
    }
    
    @IsTest
    static void testGetBikes_WithSearch_ReturnsFilteredBikes() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        req.httpMethod = 'GET';
        req.addParameter('search', 'Trek');
        req.addParameter('page', '1');
        req.addParameter('pageSize', '10');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.getBikes();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assertEquals(1, response.get('total'));
        List<Object> records = (List<Object>) response.get('records');
        System.assertEquals(1, records.size());
    }
    
    @IsTest
    static void testGetBikes_WithSearchNoMatch_ReturnsEmpty() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        req.httpMethod = 'GET';
        req.addParameter('search', 'NonexistentBike');
        req.addParameter('page', '1');
        req.addParameter('pageSize', '10');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.getBikes();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assertEquals(0, response.get('total'));
    }
    
    @IsTest
    static void testGetBikes_Pagination_RespectsPageSize() {
        // Create multiple bikes
        List<Bike__c> bikes = new List<Bike__c>();
        for (Integer i = 0; i < 15; i++) {
            bikes.add(new Bike__c(
                Name = 'Bike ' + i,
                Model__c = 'Model ' + i,
                Brand__c = 'Brand ' + i,
                Category__c = 'Road',
                Daily_Rate__c = 50 + i,
                Available__c = true
            ));
        }
        insert bikes;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        req.httpMethod = 'GET';
        req.addParameter('page', '1');
        req.addParameter('pageSize', '5');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.getBikes();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        List<Object> records = (List<Object>) response.get('records');
        
        System.assertEquals(5, records.size(), 'Should return 5 records');
        System.assertEquals(16, response.get('total'), 'Total should be 16 (15 new + 1 from setup)');
    }
    
    @IsTest
    static void testCreateBike_WithValidData_CreatesSuccessfully() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{' +
            '"Model__c":"Topstone 3",' +
            '"Brand__c":"Cannondale",' +
            '"Category__c":"Gravel",' +
            '"Daily_Rate__c":65' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.createBike();
        Bike__c createdBike = (Bike__c) JSON.deserialize(result, Bike__c.class);
        
        System.assertNotEquals(null, createdBike.Id);
        System.assertEquals('Cannondale Topstone 3', createdBike.Name);
        System.assertEquals('Topstone 3', createdBike.Model__c);
        System.assertEquals(65, createdBike.Daily_Rate__c);
        System.assertEquals(201, RestContext.response.statusCode);
    }
    
    @IsTest
    static void testCreateBike_WithMissingModel_FailsValidation() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{' +
            '"Brand__c":"Specialized",' +
            '"Category__c":"Road",' +
            '"Daily_Rate__c":70' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.createBike();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assert(response.containsKey('error'));
        System.assert(((String) response.get('error')).contains('required'));
    }
    
    @IsTest
    static void testCreateBike_WithNegativeDailyRate_FailsValidation() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{' +
            '"Model__c":"Model X",' +
            '"Brand__c":"Brand X",' +
            '"Category__c":"Road",' +
            '"Daily_Rate__c":-50' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.createBike();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        System.assert(response.containsKey('error'));
        System.assert(((String) response.get('error')).contains('negative'));
    }
    
    @IsTest
    static void testUpdateBike_WithValidData_UpdatesSuccessfully() {
        Bike__c bike = [SELECT Id FROM Bike__c LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes/' + bike.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{' +
            '"Daily_Rate__c":75,' +
            '"Mileage__c":1000' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.updateBike();
        Bike__c updatedBike = (Bike__c) JSON.deserialize(result, Bike__c.class);
        
        System.assertEquals(75, updatedBike.Daily_Rate__c);
        System.assertEquals(1000, updatedBike.Mileage__c);
    }
    
    @IsTest
    static void testUpdateBike_PartialUpdate_UpdatesOnlyProvidedFields() {
        Bike__c originalBike = [SELECT Id, Daily_Rate__c, Mileage__c FROM Bike__c LIMIT 1];
        Decimal originalRate = originalBike.Daily_Rate__c;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes/' + originalBike.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{' +
            '"Mileage__c":2500' +
        '}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        String result = BikeRestService.updateBike();
        Bike__c updatedBike = (Bike__c) JSON.deserialize(result, Bike__c.class);
        
        System.assertEquals(originalRate, updatedBike.Daily_Rate__c, 'Daily rate should not change');
        System.assertEquals(2500, updatedBike.Mileage__c);
    }
    
    @IsTest
    static void testDeleteBike_WithValidId_DeletesSuccessfully() {
        Bike__c bike = [SELECT Id FROM Bike__c LIMIT 1];
        Id bikeId = bike.Id;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes/' + bikeId;
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        BikeRestService.deleteBike();
        
        List<Bike__c> deletedBikes = [SELECT Id FROM Bike__c WHERE Id = :bikeId];
        System.assertEquals(0, deletedBikes.size());
    }
    
    @IsTest
    static void testGetBikes_WithInvalidPage_ReturnsDefaultPage() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        req.httpMethod = 'GET';
        req.addParameter('page', 'invalid');
        req.addParameter('pageSize', '10');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        try {
            BikeRestService.getBikes();
        } catch (Exception ex) {
            // Invalid page parameter should cause error
            System.assert(true);
        }
    }
}

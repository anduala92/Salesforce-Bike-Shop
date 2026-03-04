@IsTest
private with sharing class BikeShopApiTest {
    @TestSetup
    static void setupData() {
        aiops_education__Bike__c bike = new aiops_education__Bike__c(
            Name = 'Cube Agree C62',
            aiops_education__Model__c = 'Agree C62',
            aiops_education__Brand__c = 'Cube',
            aiops_education__Category__c = 'Road',
            aiops_education__Daily_Rate__c = 45,
            aiops_education__Available__c = true,
            aiops_education__Mileage__c = 1200,
            aiops_education__Last_Service_Date__c = Date.today().addDays(-20)
        );
        insert bike;

        aiops_education__Customer__c customer = new aiops_education__Customer__c(
            Name = 'Ivan Petrov',
            aiops_education__First_Name__c = 'Ivan',
            aiops_education__Last_Name__c = 'Petrov',
            aiops_education__Email__c = 'ivan.petrov@example.com',
            aiops_education__Phone__c = '+359888123123',
            aiops_education__Birth_Date__c = Date.newInstance(1998, 5, 12),
            aiops_education__Loyalty_Points__c = 50,
            aiops_education__Is_Active__c = true
        );
        insert customer;

        aiops_education__Bike_Rental__c rental = new aiops_education__Bike_Rental__c(
            aiops_education__Bike__c = bike.Id,
            aiops_education__Customer__c = customer.Id,
            aiops_education__Start_Date__c = Date.today(),
            aiops_education__End_Date__c = Date.today().addDays(2),
            aiops_education__Daily_Price__c = 45,
            aiops_education__Total_Amount__c = 135,
            aiops_education__Status__c = 'Active',
            aiops_education__Paid__c = false
        );
        insert rental;
    }

    @IsTest
    static void bikeEndpoints_ShouldSupportCrudAndSearch() {
        RestRequest getReq = new RestRequest();
        getReq.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        getReq.httpMethod = 'GET';
        getReq.addParameter('search', 'Cube');
        getReq.addParameter('page', '1');
        getReq.addParameter('pageSize', '10');
        RestContext.request = getReq;
        RestContext.response = new RestResponse();

        String listResult = BikeRestService.getBikes();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(listResult);
        System.assertEquals(true, ((List<Object>) payload.get('records')).size() > 0);

        RestRequest postReq = new RestRequest();
        postReq.requestUri = '/services/apexrest/bikeshop/v1/bikes';
        postReq.httpMethod = 'POST';
        postReq.requestBody = Blob.valueOf('{"aiops_education__Model__c":"Domane","aiops_education__Brand__c":"Trek","aiops_education__Category__c":"Road","aiops_education__Daily_Rate__c":55}');
        RestContext.request = postReq;
        RestContext.response = new RestResponse();

        aiops_education__Bike__c created = (aiops_education__Bike__c) JSON.deserialize(BikeRestService.createBike(), aiops_education__Bike__c.class);
        System.assertNotEquals(null, created.Id);

        RestRequest patchReq = new RestRequest();
        patchReq.requestUri = '/services/apexrest/bikeshop/v1/bikes/' + created.Id;
        patchReq.httpMethod = 'PATCH';
        patchReq.requestBody = Blob.valueOf('{"aiops_education__Daily_Rate__c":65}');
        RestContext.request = patchReq;
        RestContext.response = new RestResponse();

        aiops_education__Bike__c updated = (aiops_education__Bike__c) JSON.deserialize(BikeRestService.updateBike(), aiops_education__Bike__c.class);
        System.assertEquals(65, updated.aiops_education__Daily_Rate__c);

        RestRequest deleteReq = new RestRequest();
        deleteReq.requestUri = '/services/apexrest/bikeshop/v1/bikes/' + created.Id;
        deleteReq.httpMethod = 'DELETE';
        RestContext.request = deleteReq;
        RestContext.response = new RestResponse();

        BikeRestService.deleteBike();
        System.assertEquals(0, [SELECT COUNT() FROM aiops_education__Bike__c WHERE Id = :created.Id]);
    }

    @IsTest
    static void customerEndpoints_ShouldSupportCrudAndSearch() {
        RestRequest getReq = new RestRequest();
        getReq.requestUri = '/services/apexrest/bikeshop/v1/customers';
        getReq.httpMethod = 'GET';
        getReq.addParameter('search', 'Ivan');
        getReq.addParameter('page', '1');
        getReq.addParameter('pageSize', '10');
        RestContext.request = getReq;
        RestContext.response = new RestResponse();

        String listResult = CustomerRestService.getCustomers();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(listResult);
        System.assertEquals(true, ((List<Object>) payload.get('records')).size() > 0);

        RestRequest postReq = new RestRequest();
        postReq.requestUri = '/services/apexrest/bikeshop/v1/customers';
        postReq.httpMethod = 'POST';
        postReq.requestBody = Blob.valueOf('{"aiops_education__First_Name__c":"Mila","aiops_education__Last_Name__c":"Georgieva","aiops_education__Email__c":"mila.georgieva@example.com"}');
        RestContext.request = postReq;
        RestContext.response = new RestResponse();

        aiops_education__Customer__c created = (aiops_education__Customer__c) JSON.deserialize(CustomerRestService.createCustomer(), aiops_education__Customer__c.class);
        System.assertNotEquals(null, created.Id);

        RestRequest patchReq = new RestRequest();
        patchReq.requestUri = '/services/apexrest/bikeshop/v1/customers/' + created.Id;
        patchReq.httpMethod = 'PATCH';
        patchReq.requestBody = Blob.valueOf('{"aiops_education__Phone__c":"+359888000111"}');
        RestContext.request = patchReq;
        RestContext.response = new RestResponse();

        aiops_education__Customer__c updated = (aiops_education__Customer__c) JSON.deserialize(CustomerRestService.updateCustomer(), aiops_education__Customer__c.class);
        System.assertEquals('+359888000111', updated.aiops_education__Phone__c);

        RestRequest deleteReq = new RestRequest();
        deleteReq.requestUri = '/services/apexrest/bikeshop/v1/customers/' + created.Id;
        deleteReq.httpMethod = 'DELETE';
        RestContext.request = deleteReq;
        RestContext.response = new RestResponse();

        CustomerRestService.deleteCustomer();
        System.assertEquals(0, [SELECT COUNT() FROM aiops_education__Customer__c WHERE Id = :created.Id]);
    }

    @IsTest
    static void rentalEndpoints_ShouldSupportCrudAndSearch() {
        aiops_education__Bike__c bike = [SELECT Id FROM aiops_education__Bike__c LIMIT 1];
        aiops_education__Customer__c customer = [SELECT Id FROM aiops_education__Customer__c LIMIT 1];

        RestRequest getReq = new RestRequest();
        getReq.requestUri = '/services/apexrest/bikeshop/v1/rentals';
        getReq.httpMethod = 'GET';
        getReq.addParameter('status', 'Active');
        getReq.addParameter('page', '1');
        getReq.addParameter('pageSize', '10');
        RestContext.request = getReq;
        RestContext.response = new RestResponse();

        String listResult = RentalRestService.getRentals();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(listResult);
        System.assertEquals(true, ((List<Object>) payload.get('records')).size() > 0);

        RestRequest postReq = new RestRequest();
        postReq.requestUri = '/services/apexrest/bikeshop/v1/rentals';
        postReq.httpMethod = 'POST';
        postReq.requestBody = Blob.valueOf('{"aiops_education__Bike__c":"' + bike.Id + '","aiops_education__Customer__c":"' + customer.Id + '","aiops_education__Start_Date__c":"2026-03-01","aiops_education__End_Date__c":"2026-03-03","aiops_education__Daily_Price__c":40,"aiops_education__Status__c":"Draft"}');
        RestContext.request = postReq;
        RestContext.response = new RestResponse();

        aiops_education__Bike_Rental__c created = (aiops_education__Bike_Rental__c) JSON.deserialize(RentalRestService.createRental(), aiops_education__Bike_Rental__c.class);
        System.assertNotEquals(null, created.Id);

        RestRequest patchReq = new RestRequest();
        patchReq.requestUri = '/services/apexrest/bikeshop/v1/rentals/' + created.Id;
        patchReq.httpMethod = 'PATCH';
        patchReq.requestBody = Blob.valueOf('{"aiops_education__Status__c":"Completed","aiops_education__Paid__c":true}');
        RestContext.request = patchReq;
        RestContext.response = new RestResponse();

        aiops_education__Bike_Rental__c updated = (aiops_education__Bike_Rental__c) JSON.deserialize(RentalRestService.updateRental(), aiops_education__Bike_Rental__c.class);
        System.assertEquals('Completed', updated.aiops_education__Status__c);
        System.assertEquals(true, updated.aiops_education__Paid__c);

        RestRequest deleteReq = new RestRequest();
        deleteReq.requestUri = '/services/apexrest/bikeshop/v1/rentals/' + created.Id;
        deleteReq.httpMethod = 'DELETE';
        RestContext.request = deleteReq;
        RestContext.response = new RestResponse();

        RentalRestService.deleteRental();
        System.assertEquals(0, [SELECT COUNT() FROM aiops_education__Bike_Rental__c WHERE Id = :created.Id]);
    }
}
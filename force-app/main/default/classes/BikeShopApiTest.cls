@IsTest
private with sharing class BikeShopApiTest {
    @TestSetup
    static void setupData() {
        Bike__c bike = new Bike__c(
            Name = 'Cube Agree C62',
            Model__c = 'Agree C62',
            Brand__c = 'Cube',
            Category__c = 'Road',
            Daily_Rate__c = 45,
            Available__c = true,
            Mileage__c = 1200,
            Last_Service_Date__c = Date.today().addDays(-20)
        );
        insert bike;

        Customer__c customer = new Customer__c(
            Name = 'Ivan Petrov',
            First_Name__c = 'Ivan',
            Last_Name__c = 'Petrov',
            Email__c = 'ivan.petrov@example.com',
            Phone__c = '+359888123123',
            Birth_Date__c = Date.newInstance(1998, 5, 12),
            Loyalty_Points__c = 50,
            Is_Active__c = true
        );
        insert customer;

        Bike_Rental__c rental = new Bike_Rental__c(
            Bike__c = bike.Id,
            Customer__c = customer.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(2),
            Daily_Price__c = 45,
            Total_Amount__c = 135,
            Status__c = 'Active',
            Paid__c = false
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
        postReq.requestBody = Blob.valueOf('{"Model__c":"Domane","Brand__c":"Trek","Category__c":"Road","Daily_Rate__c":55}');
        RestContext.request = postReq;
        RestContext.response = new RestResponse();

        Bike__c created = (Bike__c) JSON.deserialize(BikeRestService.createBike(), Bike__c.class);
        System.assertNotEquals(null, created.Id);

        RestRequest patchReq = new RestRequest();
        patchReq.requestUri = '/services/apexrest/bikeshop/v1/bikes/' + created.Id;
        patchReq.httpMethod = 'PATCH';
        patchReq.requestBody = Blob.valueOf('{"Daily_Rate__c":65}');
        RestContext.request = patchReq;
        RestContext.response = new RestResponse();

        Bike__c updated = (Bike__c) JSON.deserialize(BikeRestService.updateBike(), Bike__c.class);
        System.assertEquals(65, updated.Daily_Rate__c);

        RestRequest deleteReq = new RestRequest();
        deleteReq.requestUri = '/services/apexrest/bikeshop/v1/bikes/' + created.Id;
        deleteReq.httpMethod = 'DELETE';
        RestContext.request = deleteReq;
        RestContext.response = new RestResponse();

        BikeRestService.deleteBike();
        System.assertEquals(0, [SELECT COUNT() FROM Bike__c WHERE Id = :created.Id]);
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
        postReq.requestBody = Blob.valueOf('{"First_Name__c":"Mila","Last_Name__c":"Georgieva","Email__c":"mila.georgieva@example.com"}');
        RestContext.request = postReq;
        RestContext.response = new RestResponse();

        Customer__c created = (Customer__c) JSON.deserialize(CustomerRestService.createCustomer(), Customer__c.class);
        System.assertNotEquals(null, created.Id);

        RestRequest patchReq = new RestRequest();
        patchReq.requestUri = '/services/apexrest/bikeshop/v1/customers/' + created.Id;
        patchReq.httpMethod = 'PATCH';
        patchReq.requestBody = Blob.valueOf('{"Phone__c":"+359888000111"}');
        RestContext.request = patchReq;
        RestContext.response = new RestResponse();

        Customer__c updated = (Customer__c) JSON.deserialize(CustomerRestService.updateCustomer(), Customer__c.class);
        System.assertEquals('+359888000111', updated.Phone__c);

        RestRequest deleteReq = new RestRequest();
        deleteReq.requestUri = '/services/apexrest/bikeshop/v1/customers/' + created.Id;
        deleteReq.httpMethod = 'DELETE';
        RestContext.request = deleteReq;
        RestContext.response = new RestResponse();

        CustomerRestService.deleteCustomer();
        System.assertEquals(0, [SELECT COUNT() FROM Customer__c WHERE Id = :created.Id]);
    }

    @IsTest
    static void rentalEndpoints_ShouldSupportCrudAndSearch() {
        Bike__c bike = [SELECT Id FROM Bike__c LIMIT 1];
        Customer__c customer = [SELECT Id FROM Customer__c LIMIT 1];

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
        postReq.requestBody = Blob.valueOf('{"Bike__c":"' + bike.Id + '","Customer__c":"' + customer.Id + '","Start_Date__c":"2026-03-01","End_Date__c":"2026-03-03","Daily_Price__c":40,"Status__c":"Draft"}');
        RestContext.request = postReq;
        RestContext.response = new RestResponse();

        Bike_Rental__c created = (Bike_Rental__c) JSON.deserialize(RentalRestService.createRental(), Bike_Rental__c.class);
        System.assertNotEquals(null, created.Id);

        RestRequest patchReq = new RestRequest();
        patchReq.requestUri = '/services/apexrest/bikeshop/v1/rentals/' + created.Id;
        patchReq.httpMethod = 'PATCH';
        patchReq.requestBody = Blob.valueOf('{"Status__c":"Completed","Paid__c":true}');
        RestContext.request = patchReq;
        RestContext.response = new RestResponse();

        Bike_Rental__c updated = (Bike_Rental__c) JSON.deserialize(RentalRestService.updateRental(), Bike_Rental__c.class);
        System.assertEquals('Completed', updated.Status__c);
        System.assertEquals(true, updated.Paid__c);

        RestRequest deleteReq = new RestRequest();
        deleteReq.requestUri = '/services/apexrest/bikeshop/v1/rentals/' + created.Id;
        deleteReq.httpMethod = 'DELETE';
        RestContext.request = deleteReq;
        RestContext.response = new RestResponse();

        RentalRestService.deleteRental();
        System.assertEquals(0, [SELECT COUNT() FROM Bike_Rental__c WHERE Id = :created.Id]);
    }
}
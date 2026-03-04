@RestResource(urlMapping='/bikeshop/v1/rentals/*')
global with sharing class RentalRestService {
    @HttpGet
    global static String getRentals() {
        try {
            if (!Schema.sObjectType.aiops_education__Bike_Rental__c.isAccessible()) {
                throw new BikeShopApiUtil.ApiException('No read access to Rental.', 403);
            }

            Integer page = BikeShopApiUtil.getPage();
            Integer pageSize = BikeShopApiUtil.getPageSize();
            Integer offsetRows = (page - 1) * pageSize;
            String status = BikeShopApiUtil.getParam('status');
            String customerIdParam = BikeShopApiUtil.getParam('customerId');
            List<aiops_education__Bike_Rental__c> rows;
            Integer total;

            if (String.isBlank(status) && String.isBlank(customerIdParam)) {
                total = [SELECT COUNT() FROM aiops_education__Bike_Rental__c];
                rows = [
                    SELECT Id, Name, aiops_education__Bike__c, aiops_education__Bike__r.Name, aiops_education__Customer__c, aiops_education__Customer__r.Name, aiops_education__Start_Date__c, aiops_education__End_Date__c, aiops_education__Daily_Price__c, aiops_education__Total_Amount__c, aiops_education__Status__c, aiops_education__Paid__c
                    FROM aiops_education__Bike_Rental__c
                    ORDER BY CreatedDate DESC
                    LIMIT :pageSize
                    OFFSET :offsetRows
                ];
            } else if (!String.isBlank(status) && !String.isBlank(customerIdParam)) {
                Id customerId = (Id) customerIdParam;
                total = [SELECT COUNT() FROM aiops_education__Bike_Rental__c WHERE aiops_education__Status__c = :status AND aiops_education__Customer__c = :customerId];
                rows = [
                    SELECT Id, Name, aiops_education__Bike__c, aiops_education__Bike__r.Name, aiops_education__Customer__c, aiops_education__Customer__r.Name, aiops_education__Start_Date__c, aiops_education__End_Date__c, aiops_education__Daily_Price__c, aiops_education__Total_Amount__c, aiops_education__Status__c, aiops_education__Paid__c
                    FROM aiops_education__Bike_Rental__c
                    WHERE aiops_education__Status__c = :status AND aiops_education__Customer__c = :customerId
                    ORDER BY CreatedDate DESC
                    LIMIT :pageSize
                    OFFSET :offsetRows
                ];
            } else if (!String.isBlank(status)) {
                total = [SELECT COUNT() FROM aiops_education__Bike_Rental__c WHERE aiops_education__Status__c = :status];
                rows = [
                    SELECT Id, Name, aiops_education__Bike__c, aiops_education__Bike__r.Name, aiops_education__Customer__c, aiops_education__Customer__r.Name, aiops_education__Start_Date__c, aiops_education__End_Date__c, aiops_education__Daily_Price__c, aiops_education__Total_Amount__c, aiops_education__Status__c, aiops_education__Paid__c
                    FROM aiops_education__Bike_Rental__c
                    WHERE aiops_education__Status__c = :status
                    ORDER BY CreatedDate DESC
                    LIMIT :pageSize
                    OFFSET :offsetRows
                ];
            } else {
                Id customerId = (Id) customerIdParam;
                total = [SELECT COUNT() FROM aiops_education__Bike_Rental__c WHERE aiops_education__Customer__c = :customerId];
                rows = [
                    SELECT Id, Name, aiops_education__Bike__c, aiops_education__Bike__r.Name, aiops_education__Customer__c, aiops_education__Customer__r.Name, aiops_education__Start_Date__c, aiops_education__End_Date__c, aiops_education__Daily_Price__c, aiops_education__Total_Amount__c, aiops_education__Status__c, aiops_education__Paid__c
                    FROM aiops_education__Bike_Rental__c
                    WHERE aiops_education__Customer__c = :customerId
                    ORDER BY CreatedDate DESC
                    LIMIT :pageSize
                    OFFSET :offsetRows
                ];
            }

            return JSON.serialize(BikeShopApiUtil.listResponse(rows, total, page, pageSize));
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }

    @HttpPost
    global static String createRental() {
        try {
            if (!Schema.sObjectType.aiops_education__Bike_Rental__c.isCreateable()) {
                throw new BikeShopApiUtil.ApiException('No create access to Rental.', 403);
            }

            Map<String, Object> body = BikeShopApiUtil.parseBody();
            Id bikeId = BikeShopApiUtil.getId(body, 'aiops_education__Bike__c');
            Id customerId = BikeShopApiUtil.getId(body, 'aiops_education__Customer__c');
            Date startDate = BikeShopApiUtil.getDate(body, 'aiops_education__Start_Date__c');
            Date endDate = BikeShopApiUtil.getDate(body, 'aiops_education__End_Date__c');
            Decimal dailyPrice = BikeShopApiUtil.getDecimal(body, 'aiops_education__Daily_Price__c');
            String status = BikeShopApiUtil.getString(body, 'aiops_education__Status__c');

            if (bikeId == null) {
                throw new BikeShopApiUtil.ApiException('Bike is required.', 400);
            }
            if (customerId == null) {
                throw new BikeShopApiUtil.ApiException('Customer is required.', 400);
            }
            if (startDate == null || endDate == null) {
                throw new BikeShopApiUtil.ApiException('Start and End dates are required.', 400);
            }
            if (endDate < startDate) {
                throw new BikeShopApiUtil.ApiException('End Date cannot be before Start Date.', 400);
            }
            BikeShopApiUtil.validatePositive(dailyPrice, 'Daily Price', true);
            BikeShopApiUtil.validateText(status, 40, 'Status', true);

            Integer rentalDays = startDate.daysBetween(endDate) + 1;
            Decimal totalAmount = dailyPrice * rentalDays;

            aiops_education__Bike_Rental__c rental = new aiops_education__Bike_Rental__c();
            rental.aiops_education__Bike__c = bikeId;
            rental.aiops_education__Customer__c = customerId;
            rental.aiops_education__Start_Date__c = startDate;
            rental.aiops_education__End_Date__c = endDate;
            rental.aiops_education__Daily_Price__c = dailyPrice;
            rental.aiops_education__Total_Amount__c = body.containsKey('aiops_education__Total_Amount__c') ? BikeShopApiUtil.getDecimal(body, 'aiops_education__Total_Amount__c') : totalAmount;
            rental.aiops_education__Status__c = status;
            rental.aiops_education__Paid__c = body.containsKey('aiops_education__Paid__c') ? BikeShopApiUtil.getBoolean(body, 'aiops_education__Paid__c') : false;

            insert rental;
            RestContext.response.statusCode = 201;
            return JSON.serialize(rental);
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }

    @HttpPatch
    global static String updateRental() {
        try {
            if (!Schema.sObjectType.aiops_education__Bike_Rental__c.isUpdateable()) {
                throw new BikeShopApiUtil.ApiException('No update access to Rental.', 403);
            }

            Id rentalId = BikeShopApiUtil.getIdFromUri();
            aiops_education__Bike_Rental__c rental = [
                SELECT Id, aiops_education__Bike__c, aiops_education__Customer__c, aiops_education__Start_Date__c, aiops_education__End_Date__c, aiops_education__Daily_Price__c, aiops_education__Total_Amount__c, aiops_education__Status__c, aiops_education__Paid__c
                FROM aiops_education__Bike_Rental__c
                WHERE Id = :rentalId
                LIMIT 1
            ];

            Map<String, Object> body = BikeShopApiUtil.parseBody();
            if (body.containsKey('aiops_education__Bike__c')) {
                rental.aiops_education__Bike__c = BikeShopApiUtil.getId(body, 'aiops_education__Bike__c');
            }
            if (body.containsKey('aiops_education__Customer__c')) {
                rental.aiops_education__Customer__c = BikeShopApiUtil.getId(body, 'aiops_education__Customer__c');
            }
            if (body.containsKey('aiops_education__Start_Date__c')) {
                rental.aiops_education__Start_Date__c = BikeShopApiUtil.getDate(body, 'aiops_education__Start_Date__c');
            }
            if (body.containsKey('aiops_education__End_Date__c')) {
                rental.aiops_education__End_Date__c = BikeShopApiUtil.getDate(body, 'aiops_education__End_Date__c');
            }
            if (rental.aiops_education__End_Date__c < rental.aiops_education__Start_Date__c) {
                throw new BikeShopApiUtil.ApiException('End Date cannot be before Start Date.', 400);
            }
            if (body.containsKey('aiops_education__Daily_Price__c')) {
                Decimal dailyPrice = BikeShopApiUtil.getDecimal(body, 'aiops_education__Daily_Price__c');
                BikeShopApiUtil.validatePositive(dailyPrice, 'Daily Price', true);
                rental.aiops_education__Daily_Price__c = dailyPrice;
            }
            if (body.containsKey('aiops_education__Status__c')) {
                String status = BikeShopApiUtil.getString(body, 'aiops_education__Status__c');
                BikeShopApiUtil.validateText(status, 40, 'Status', true);
                rental.aiops_education__Status__c = status;
            }
            if (body.containsKey('aiops_education__Paid__c')) {
                rental.aiops_education__Paid__c = BikeShopApiUtil.getBoolean(body, 'aiops_education__Paid__c');
            }

            Integer rentalDays = rental.aiops_education__Start_Date__c.daysBetween(rental.aiops_education__End_Date__c) + 1;
            rental.aiops_education__Total_Amount__c = rental.aiops_education__Daily_Price__c * rentalDays;

            update rental;
            return JSON.serialize(rental);
        } catch (QueryException qex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(new BikeShopApiUtil.ApiException('Rental not found.', 404)));
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }

    @HttpDelete
    global static String deleteRental() {
        try {
            if (!Schema.sObjectType.aiops_education__Bike_Rental__c.isDeletable()) {
                throw new BikeShopApiUtil.ApiException('No delete access to Rental.', 403);
            }

            Id rentalId = BikeShopApiUtil.getIdFromUri();
            delete [SELECT Id FROM aiops_education__Bike_Rental__c WHERE Id = :rentalId LIMIT 1];
            RestContext.response.statusCode = 204;
            return null;
        } catch (QueryException qex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(new BikeShopApiUtil.ApiException('Rental not found.', 404)));
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }
}
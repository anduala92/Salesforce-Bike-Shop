public with sharing class BikeShopLwcController {
    public class PagedResult {
        @AuraEnabled public Integer page;
        @AuraEnabled public Integer pageSize;
        @AuraEnabled public Integer total;
        @AuraEnabled public List<SObject> records;
    }

    private static Integer normalizePage(Integer pageNumber) {
        if (pageNumber == null || pageNumber < 1) {
            return 1;
        }
        return pageNumber;
    }

    private static Integer normalizePageSize(Integer pageSize) {
        if (pageSize == null || pageSize < 1) {
            return 10;
        }
        return pageSize > 100 ? 100 : pageSize;
    }

    @AuraEnabled(cacheable=true)
    public static PagedResult getBikes(Integer pageNumber, Integer pageSize, String search) {
        Integer page = normalizePage(pageNumber);
        Integer size = normalizePageSize(pageSize);
        Integer offsetRows = (page - 1) * size;

        List<aiops_education__Bike__c> rows;
        Integer total;

        if (String.isBlank(search)) {
            total = [SELECT COUNT() FROM aiops_education__Bike__c];
            rows = [
                SELECT Id, Name, aiops_education__Model__c, aiops_education__Brand__c, aiops_education__Category__c,
                       aiops_education__Daily_Rate__c, aiops_education__Available__c, aiops_education__Mileage__c,
                       aiops_education__Last_Service_Date__c
                FROM aiops_education__Bike__c
                ORDER BY CreatedDate DESC
                LIMIT :size
                OFFSET :offsetRows
            ];
        } else {
            String likeSearch = '%' + search + '%';
            total = [
                SELECT COUNT()
                FROM aiops_education__Bike__c
                WHERE Name LIKE :likeSearch
                   OR aiops_education__Model__c LIKE :likeSearch
                   OR aiops_education__Brand__c LIKE :likeSearch
            ];
            rows = [
                SELECT Id, Name, aiops_education__Model__c, aiops_education__Brand__c, aiops_education__Category__c,
                       aiops_education__Daily_Rate__c, aiops_education__Available__c, aiops_education__Mileage__c,
                       aiops_education__Last_Service_Date__c
                FROM aiops_education__Bike__c
                WHERE Name LIKE :likeSearch
                   OR aiops_education__Model__c LIKE :likeSearch
                   OR aiops_education__Brand__c LIKE :likeSearch
                ORDER BY CreatedDate DESC
                LIMIT :size
                OFFSET :offsetRows
            ];
        }

        PagedResult result = new PagedResult();
        result.page = page;
        result.pageSize = size;
        result.total = total;
        result.records = rows;
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static PagedResult getCustomers(Integer pageNumber, Integer pageSize, String search) {
        Integer page = normalizePage(pageNumber);
        Integer size = normalizePageSize(pageSize);
        Integer offsetRows = (page - 1) * size;

        List<aiops_education__Customer__c> rows;
        Integer total;

        if (String.isBlank(search)) {
            total = [SELECT COUNT() FROM aiops_education__Customer__c];
            rows = [
                SELECT Id, Name, aiops_education__First_Name__c, aiops_education__Last_Name__c, aiops_education__Email__c,
                       aiops_education__Phone__c, aiops_education__Birth_Date__c, aiops_education__Loyalty_Points__c,
                       aiops_education__Is_Active__c
                FROM aiops_education__Customer__c
                ORDER BY CreatedDate DESC
                LIMIT :size
                OFFSET :offsetRows
            ];
        } else {
            String likeSearch = '%' + search + '%';
            total = [
                SELECT COUNT()
                FROM aiops_education__Customer__c
                WHERE aiops_education__First_Name__c LIKE :likeSearch
                   OR aiops_education__Last_Name__c LIKE :likeSearch
                   OR aiops_education__Email__c LIKE :likeSearch
            ];
            rows = [
                SELECT Id, Name, aiops_education__First_Name__c, aiops_education__Last_Name__c, aiops_education__Email__c,
                       aiops_education__Phone__c, aiops_education__Birth_Date__c, aiops_education__Loyalty_Points__c,
                       aiops_education__Is_Active__c
                FROM aiops_education__Customer__c
                WHERE aiops_education__First_Name__c LIKE :likeSearch
                   OR aiops_education__Last_Name__c LIKE :likeSearch
                   OR aiops_education__Email__c LIKE :likeSearch
                ORDER BY CreatedDate DESC
                LIMIT :size
                OFFSET :offsetRows
            ];
        }

        PagedResult result = new PagedResult();
        result.page = page;
        result.pageSize = size;
        result.total = total;
        result.records = rows;
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static PagedResult getRentals(Integer pageNumber, Integer pageSize, String status) {
        Integer page = normalizePage(pageNumber);
        Integer size = normalizePageSize(pageSize);
        Integer offsetRows = (page - 1) * size;

        List<aiops_education__Bike_Rental__c> rows;
        Integer total;

        if (String.isBlank(status)) {
            total = [SELECT COUNT() FROM aiops_education__Bike_Rental__c];
            rows = [
                SELECT Id, Name, aiops_education__Bike__c, aiops_education__Bike__r.Name, aiops_education__Customer__c,
                       aiops_education__Customer__r.Name, aiops_education__Start_Date__c, aiops_education__End_Date__c,
                       aiops_education__Daily_Price__c, aiops_education__Total_Amount__c, aiops_education__Status__c,
                       aiops_education__Paid__c
                FROM aiops_education__Bike_Rental__c
                ORDER BY CreatedDate DESC
                LIMIT :size
                OFFSET :offsetRows
            ];
        } else {
            total = [
                SELECT COUNT()
                FROM aiops_education__Bike_Rental__c
                WHERE aiops_education__Status__c = :status
            ];
            rows = [
                SELECT Id, Name, aiops_education__Bike__c, aiops_education__Bike__r.Name, aiops_education__Customer__c,
                       aiops_education__Customer__r.Name, aiops_education__Start_Date__c, aiops_education__End_Date__c,
                       aiops_education__Daily_Price__c, aiops_education__Total_Amount__c, aiops_education__Status__c,
                       aiops_education__Paid__c
                FROM aiops_education__Bike_Rental__c
                WHERE aiops_education__Status__c = :status
                ORDER BY CreatedDate DESC
                LIMIT :size
                OFFSET :offsetRows
            ];
        }

        PagedResult result = new PagedResult();
        result.page = page;
        result.pageSize = size;
        result.total = total;
        result.records = rows;
        return result;
    }

    @AuraEnabled
    public static aiops_education__Bike__c saveBike(Map<String, Object> payload) {
        if (payload == null) {
            payload = new Map<String, Object>();
        }

        Id recordId = payload.containsKey('Id') ? (Id) String.valueOf(payload.get('Id')) : null;
        aiops_education__Bike__c bike;

        if (recordId == null) {
            bike = new aiops_education__Bike__c();
        } else {
            bike = [
                SELECT Id, Name, aiops_education__Model__c, aiops_education__Brand__c, aiops_education__Category__c,
                       aiops_education__Daily_Rate__c, aiops_education__Available__c, aiops_education__Mileage__c,
                       aiops_education__Last_Service_Date__c
                FROM aiops_education__Bike__c
                WHERE Id = :recordId
                LIMIT 1
            ];
        }

        if (payload.containsKey('Name')) bike.Name = String.valueOf(payload.get('Name'));
        if (payload.containsKey('aiops_education__Model__c')) bike.aiops_education__Model__c = String.valueOf(payload.get('aiops_education__Model__c'));
        if (payload.containsKey('aiops_education__Brand__c')) bike.aiops_education__Brand__c = String.valueOf(payload.get('aiops_education__Brand__c'));
        if (payload.containsKey('aiops_education__Category__c')) bike.aiops_education__Category__c = String.valueOf(payload.get('aiops_education__Category__c'));
        if (payload.containsKey('aiops_education__Daily_Rate__c') && payload.get('aiops_education__Daily_Rate__c') != null) bike.aiops_education__Daily_Rate__c = Decimal.valueOf(String.valueOf(payload.get('aiops_education__Daily_Rate__c')));
        if (payload.containsKey('aiops_education__Available__c')) bike.aiops_education__Available__c = (Boolean) payload.get('aiops_education__Available__c');
        if (payload.containsKey('aiops_education__Mileage__c') && payload.get('aiops_education__Mileage__c') != null) bike.aiops_education__Mileage__c = Integer.valueOf(String.valueOf(payload.get('aiops_education__Mileage__c')));
        if (payload.containsKey('aiops_education__Last_Service_Date__c') && payload.get('aiops_education__Last_Service_Date__c') != null) bike.aiops_education__Last_Service_Date__c = Date.valueOf(String.valueOf(payload.get('aiops_education__Last_Service_Date__c')));

        if (String.isBlank(bike.Name) && !String.isBlank(bike.aiops_education__Brand__c) && !String.isBlank(bike.aiops_education__Model__c)) {
            bike.Name = bike.aiops_education__Brand__c + ' ' + bike.aiops_education__Model__c;
        }

        upsert bike;
        return bike;
    }

    @AuraEnabled
    public static void deleteBike(Id bikeId) {
        delete [SELECT Id FROM aiops_education__Bike__c WHERE Id = :bikeId LIMIT 1];
    }

    @AuraEnabled
    public static aiops_education__Customer__c saveCustomer(Map<String, Object> payload) {
        if (payload == null) {
            payload = new Map<String, Object>();
        }

        Id recordId = payload.containsKey('Id') ? (Id) String.valueOf(payload.get('Id')) : null;
        aiops_education__Customer__c customer;

        if (recordId == null) {
            customer = new aiops_education__Customer__c();
        } else {
            customer = [
                SELECT Id, Name, aiops_education__First_Name__c, aiops_education__Last_Name__c, aiops_education__Email__c,
                       aiops_education__Phone__c, aiops_education__Birth_Date__c, aiops_education__Loyalty_Points__c,
                       aiops_education__Is_Active__c
                FROM aiops_education__Customer__c
                WHERE Id = :recordId
                LIMIT 1
            ];
        }

        if (payload.containsKey('Name')) customer.Name = String.valueOf(payload.get('Name'));
        if (payload.containsKey('aiops_education__First_Name__c')) customer.aiops_education__First_Name__c = String.valueOf(payload.get('aiops_education__First_Name__c'));
        if (payload.containsKey('aiops_education__Last_Name__c')) customer.aiops_education__Last_Name__c = String.valueOf(payload.get('aiops_education__Last_Name__c'));
        if (payload.containsKey('aiops_education__Email__c')) customer.aiops_education__Email__c = String.valueOf(payload.get('aiops_education__Email__c'));
        if (payload.containsKey('aiops_education__Phone__c')) customer.aiops_education__Phone__c = String.valueOf(payload.get('aiops_education__Phone__c'));
        if (payload.containsKey('aiops_education__Birth_Date__c') && payload.get('aiops_education__Birth_Date__c') != null) customer.aiops_education__Birth_Date__c = Date.valueOf(String.valueOf(payload.get('aiops_education__Birth_Date__c')));
        if (payload.containsKey('aiops_education__Loyalty_Points__c') && payload.get('aiops_education__Loyalty_Points__c') != null) customer.aiops_education__Loyalty_Points__c = Integer.valueOf(String.valueOf(payload.get('aiops_education__Loyalty_Points__c')));
        if (payload.containsKey('aiops_education__Is_Active__c')) customer.aiops_education__Is_Active__c = (Boolean) payload.get('aiops_education__Is_Active__c');

        if (String.isBlank(customer.Name) && !String.isBlank(customer.aiops_education__First_Name__c) && !String.isBlank(customer.aiops_education__Last_Name__c)) {
            customer.Name = customer.aiops_education__First_Name__c + ' ' + customer.aiops_education__Last_Name__c;
        }

        // Validate email uniqueness
        if (!String.isBlank(customer.aiops_education__Email__c)) {
            String email = customer.aiops_education__Email__c.toLowerCase();
            List<aiops_education__Customer__c> existingCustomers = [
                SELECT Id FROM aiops_education__Customer__c 
                WHERE aiops_education__Email__c = :customer.aiops_education__Email__c
                AND Id != :customer.Id
                LIMIT 1
            ];
            if (!existingCustomers.isEmpty()) {
                throw new AuraHandledException('Email already exists. Please use a different email address.');
            }
        }

        upsert customer;
        return customer;
    }

    @AuraEnabled
    public static void deleteCustomer(Id customerId) {
        delete [SELECT Id FROM aiops_education__Customer__c WHERE Id = :customerId LIMIT 1];
    }

    @AuraEnabled
    public static aiops_education__Bike_Rental__c saveRental(Map<String, Object> payload) {
        if (payload == null) {
            payload = new Map<String, Object>();
        }

        Id recordId = payload.containsKey('Id') ? (Id) String.valueOf(payload.get('Id')) : null;
        aiops_education__Bike_Rental__c rental;

        if (recordId == null) {
            rental = new aiops_education__Bike_Rental__c();
        } else {
            rental = [
                SELECT Id, aiops_education__Bike__c, aiops_education__Customer__c, aiops_education__Start_Date__c,
                       aiops_education__End_Date__c, aiops_education__Daily_Price__c, aiops_education__Total_Amount__c,
                       aiops_education__Status__c, aiops_education__Paid__c
                FROM aiops_education__Bike_Rental__c
                WHERE Id = :recordId
                LIMIT 1
            ];
        }

        if (payload.containsKey('aiops_education__Bike__c')) rental.aiops_education__Bike__c = (Id) String.valueOf(payload.get('aiops_education__Bike__c'));
        if (payload.containsKey('aiops_education__Customer__c')) rental.aiops_education__Customer__c = (Id) String.valueOf(payload.get('aiops_education__Customer__c'));
        
        // Парсиране на дати - получаваме YYYY-MM-DDTHH:MM:SSZ от JavaScript
        if (payload.containsKey('aiops_education__Start_Date__c') && payload.get('aiops_education__Start_Date__c') != null) {
            String startDateStr = String.valueOf(payload.get('aiops_education__Start_Date__c')).trim();
            System.debug('DEBUG: Received Start Date String: ' + startDateStr);
            // Вземи само датата (YYYY-MM-DD) игнорирай време и Z
            if (startDateStr.contains('T')) {
                startDateStr = startDateStr.split('T')[0];
            }
            System.debug('DEBUG: Parsed Start Date String: ' + startDateStr);
            rental.aiops_education__Start_Date__c = Date.valueOf(startDateStr);
            System.debug('DEBUG: Converted Start Date: ' + rental.aiops_education__Start_Date__c);
        }
        if (payload.containsKey('aiops_education__End_Date__c') && payload.get('aiops_education__End_Date__c') != null) {
            String endDateStr = String.valueOf(payload.get('aiops_education__End_Date__c')).trim();
            System.debug('DEBUG: Received End Date String: ' + endDateStr);
            // Вземи само датата (YYYY-MM-DD) игнорирай време и Z
            if (endDateStr.contains('T')) {
                endDateStr = endDateStr.split('T')[0];
            }
            System.debug('DEBUG: Parsed End Date String: ' + endDateStr);
            rental.aiops_education__End_Date__c = Date.valueOf(endDateStr);
            System.debug('DEBUG: Converted End Date: ' + rental.aiops_education__End_Date__c);
        }
        
        if (payload.containsKey('aiops_education__Daily_Price__c') && payload.get('aiops_education__Daily_Price__c') != null) rental.aiops_education__Daily_Price__c = Decimal.valueOf(String.valueOf(payload.get('aiops_education__Daily_Price__c')));
        if (payload.containsKey('aiops_education__Status__c')) rental.aiops_education__Status__c = String.valueOf(payload.get('aiops_education__Status__c'));
        if (payload.containsKey('aiops_education__Paid__c')) rental.aiops_education__Paid__c = (Boolean) payload.get('aiops_education__Paid__c');

        if (rental.aiops_education__Start_Date__c != null && rental.aiops_education__End_Date__c != null && rental.aiops_education__Daily_Price__c != null) {
            Integer rentalDays = rental.aiops_education__Start_Date__c.daysBetween(rental.aiops_education__End_Date__c) + 1;
            rental.aiops_education__Total_Amount__c = rental.aiops_education__Daily_Price__c * rentalDays;
        }

        upsert rental;
        return rental;
    }

    @AuraEnabled
    public static void deleteRental(Id rentalId) {
        delete [SELECT Id FROM aiops_education__Bike_Rental__c WHERE Id = :rentalId LIMIT 1];
    }

    @AuraEnabled
    public static List<Map<String, String>> getBikeOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        List<aiops_education__Bike__c> bikes = [
            SELECT Id, Name, aiops_education__Daily_Rate__c 
            FROM aiops_education__Bike__c 
            WHERE aiops_education__Available__c = true
            ORDER BY Name ASC
        ];
        for (aiops_education__Bike__c bike : bikes) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', bike.Name);
            option.put('value', bike.Id);
            option.put('dailyRate', String.valueOf(bike.aiops_education__Daily_Rate__c));
            options.add(option);
        }
        return options;
    }

    @AuraEnabled
    public static List<Map<String, String>> getCustomerOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        List<aiops_education__Customer__c> customers = [
            SELECT Id, Name 
            FROM aiops_education__Customer__c 
            WHERE aiops_education__Is_Active__c = true
            ORDER BY Name ASC
        ];
        for (aiops_education__Customer__c customer : customers) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', customer.Name);
            option.put('value', customer.Id);
            options.add(option);
        }
        return options;
    }

    @AuraEnabled
    public static Map<String, Object> checkBikeAvailability(Id bikeId, Date startDate, Date endDate, Id excludeRentalId) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('isAvailable', true);
        result.put('conflictingRentals', new List<Map<String, Object>>());
        
        if (bikeId == null || startDate == null || endDate == null) {
            return result;
        }
        
        // Check for overlapping rentals with the same bike
        List<aiops_education__Bike_Rental__c> conflicts = [
            SELECT Id, Name, aiops_education__Start_Date__c, aiops_education__End_Date__c,
                   aiops_education__Customer__r.Name
            FROM aiops_education__Bike_Rental__c
            WHERE aiops_education__Bike__c = :bikeId
            AND aiops_education__Start_Date__c <= :endDate
            AND aiops_education__End_Date__c >= :startDate
            AND aiops_education__Status__c != 'Cancelled'
        ];
        
        // Filter out the excluded rental if provided
        if (excludeRentalId != null) {
            List<aiops_education__Bike_Rental__c> filteredConflicts = new List<aiops_education__Bike_Rental__c>();
            for (aiops_education__Bike_Rental__c rental : conflicts) {
                if (rental.Id != excludeRentalId) {
                    filteredConflicts.add(rental);
                }
            }
            conflicts = filteredConflicts;
        }
        
        if (!conflicts.isEmpty()) {
            result.put('isAvailable', false);
            List<Map<String, Object>> conflictList = new List<Map<String, Object>>();
            for (aiops_education__Bike_Rental__c rental : conflicts) {
                Map<String, Object> conflict = new Map<String, Object>();
                conflict.put('rentalId', rental.Id);
                conflict.put('rentalName', rental.Name);
                conflict.put('startDate', rental.aiops_education__Start_Date__c);
                conflict.put('endDate', rental.aiops_education__End_Date__c);
                conflict.put('customerName', rental.aiops_education__Customer__r.Name);
                conflictList.add(conflict);
            }
            result.put('conflictingRentals', conflictList);
        }
        
        return result;
    }

    @AuraEnabled
    public static List<String> getStatusOptions() {
        List<String> statusOptions = new List<String>();
        statusOptions.add('Draft');
        statusOptions.add('Active');
        statusOptions.add('Completed');
        statusOptions.add('Cancelled');
        return statusOptions;
    }
}

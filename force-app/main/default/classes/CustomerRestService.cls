@RestResource(urlMapping='/bikeshop/v1/customers/*')
global with sharing class CustomerRestService {
    @HttpGet
    global static String getCustomers() {
        try {
            if (!Schema.sObjectType.aiops_education__Customer__c.isAccessible()) {
                throw new BikeShopApiUtil.ApiException('No read access to Customer.', 403);
            }

            Integer page = BikeShopApiUtil.getPage();
            Integer pageSize = BikeShopApiUtil.getPageSize();
            Integer offsetRows = (page - 1) * pageSize;
            String search = BikeShopApiUtil.getParam('search');
            List<aiops_education__Customer__c> rows;
            Integer total;

            if (String.isBlank(search)) {
                total = [SELECT COUNT() FROM aiops_education__Customer__c];
                rows = [
                    SELECT Id, Name, aiops_education__First_Name__c, aiops_education__Last_Name__c, aiops_education__Email__c, aiops_education__Phone__c, aiops_education__Birth_Date__c, aiops_education__Loyalty_Points__c, aiops_education__Is_Active__c
                    FROM aiops_education__Customer__c
                    ORDER BY CreatedDate DESC
                    LIMIT :pageSize
                    OFFSET :offsetRows
                ];
            } else {
                String likeSearch = '%' + search + '%';
                total = [
                    SELECT COUNT()
                    FROM aiops_education__Customer__c
                    WHERE aiops_education__First_Name__c LIKE :likeSearch OR aiops_education__Last_Name__c LIKE :likeSearch OR aiops_education__Email__c LIKE :likeSearch
                ];
                rows = [
                    SELECT Id, Name, aiops_education__First_Name__c, aiops_education__Last_Name__c, aiops_education__Email__c, aiops_education__Phone__c, aiops_education__Birth_Date__c, aiops_education__Loyalty_Points__c, aiops_education__Is_Active__c
                    FROM aiops_education__Customer__c
                    WHERE aiops_education__First_Name__c LIKE :likeSearch OR aiops_education__Last_Name__c LIKE :likeSearch OR aiops_education__Email__c LIKE :likeSearch
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
    global static String createCustomer() {
        try {
            if (!Schema.sObjectType.aiops_education__Customer__c.isCreateable()) {
                throw new BikeShopApiUtil.ApiException('No create access to Customer.', 403);
            }

            Map<String, Object> body = BikeShopApiUtil.parseBody();
            String firstName = BikeShopApiUtil.getString(body, 'aiops_education__First_Name__c');
            String lastName = BikeShopApiUtil.getString(body, 'aiops_education__Last_Name__c');
            String email = BikeShopApiUtil.getString(body, 'aiops_education__Email__c');

            BikeShopApiUtil.validateText(firstName, 50, 'First Name', true);
            BikeShopApiUtil.validateText(lastName, 50, 'Last Name', true);
            BikeShopApiUtil.validateText(email, 80, 'Email', true);

            aiops_education__Customer__c customer = new aiops_education__Customer__c();
            customer.Name = String.isBlank(BikeShopApiUtil.getString(body, 'Name')) ? (firstName + ' ' + lastName) : BikeShopApiUtil.getString(body, 'Name');
            customer.aiops_education__First_Name__c = firstName;
            customer.aiops_education__Last_Name__c = lastName;
            customer.aiops_education__Email__c = email;
            customer.aiops_education__Phone__c = BikeShopApiUtil.getString(body, 'aiops_education__Phone__c');
            customer.aiops_education__Birth_Date__c = BikeShopApiUtil.getDate(body, 'aiops_education__Birth_Date__c');
            customer.aiops_education__Loyalty_Points__c = BikeShopApiUtil.getInteger(body, 'aiops_education__Loyalty_Points__c');
            customer.aiops_education__Is_Active__c = body.containsKey('aiops_education__Is_Active__c') ? BikeShopApiUtil.getBoolean(body, 'aiops_education__Is_Active__c') : true;

            insert customer;
            RestContext.response.statusCode = 201;
            return JSON.serialize(customer);
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }

    @HttpPatch
    global static String updateCustomer() {
        try {
            if (!Schema.sObjectType.aiops_education__Customer__c.isUpdateable()) {
                throw new BikeShopApiUtil.ApiException('No update access to Customer.', 403);
            }

            Id customerId = BikeShopApiUtil.getIdFromUri();
            aiops_education__Customer__c customer = [
                SELECT Id, Name, aiops_education__First_Name__c, aiops_education__Last_Name__c, aiops_education__Email__c, aiops_education__Phone__c, aiops_education__Birth_Date__c, aiops_education__Loyalty_Points__c, aiops_education__Is_Active__c
                FROM aiops_education__Customer__c
                WHERE Id = :customerId
                LIMIT 1
            ];

            Map<String, Object> body = BikeShopApiUtil.parseBody();
            if (body.containsKey('aiops_education__First_Name__c')) {
                String firstName = BikeShopApiUtil.getString(body, 'aiops_education__First_Name__c');
                BikeShopApiUtil.validateText(firstName, 50, 'First Name', true);
                customer.aiops_education__First_Name__c = firstName;
            }
            if (body.containsKey('aiops_education__Last_Name__c')) {
                String lastName = BikeShopApiUtil.getString(body, 'aiops_education__Last_Name__c');
                BikeShopApiUtil.validateText(lastName, 50, 'Last Name', true);
                customer.aiops_education__Last_Name__c = lastName;
            }
            if (body.containsKey('aiops_education__Email__c')) {
                String email = BikeShopApiUtil.getString(body, 'aiops_education__Email__c');
                BikeShopApiUtil.validateText(email, 80, 'Email', true);
                customer.aiops_education__Email__c = email;
            }
            if (body.containsKey('aiops_education__Phone__c')) {
                customer.aiops_education__Phone__c = BikeShopApiUtil.getString(body, 'aiops_education__Phone__c');
            }
            if (body.containsKey('aiops_education__Birth_Date__c')) {
                customer.aiops_education__Birth_Date__c = BikeShopApiUtil.getDate(body, 'aiops_education__Birth_Date__c');
            }
            if (body.containsKey('aiops_education__Loyalty_Points__c')) {
                customer.aiops_education__Loyalty_Points__c = BikeShopApiUtil.getInteger(body, 'aiops_education__Loyalty_Points__c');
            }
            if (body.containsKey('aiops_education__Is_Active__c')) {
                customer.aiops_education__Is_Active__c = BikeShopApiUtil.getBoolean(body, 'aiops_education__Is_Active__c');
            }
            if (body.containsKey('Name')) {
                String nameValue = BikeShopApiUtil.getString(body, 'Name');
                BikeShopApiUtil.validateText(nameValue, 80, 'Name', true);
                customer.Name = nameValue;
            }

            update customer;
            return JSON.serialize(customer);
        } catch (QueryException qex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(new BikeShopApiUtil.ApiException('Customer not found.', 404)));
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }

    @HttpDelete
    global static String deleteCustomer() {
        try {
            if (!Schema.sObjectType.aiops_education__Customer__c.isDeletable()) {
                throw new BikeShopApiUtil.ApiException('No delete access to Customer.', 403);
            }

            Id customerId = BikeShopApiUtil.getIdFromUri();
            delete [SELECT Id FROM aiops_education__Customer__c WHERE Id = :customerId LIMIT 1];
            RestContext.response.statusCode = 204;
            return null;
        } catch (QueryException qex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(new BikeShopApiUtil.ApiException('Customer not found.', 404)));
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }
}
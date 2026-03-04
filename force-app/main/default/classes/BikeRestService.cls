@RestResource(urlMapping='/bikeshop/v1/bikes/*')
global with sharing class BikeRestService {
    @HttpGet
    global static String getBikes() {
        try {
            if (!Schema.sObjectType.aiops_education__Bike__c.isAccessible()) {
                throw new BikeShopApiUtil.ApiException('No read access to Bike.', 403);
            }

            Integer page = BikeShopApiUtil.getPage();
            Integer pageSize = BikeShopApiUtil.getPageSize();
            Integer offsetRows = (page - 1) * pageSize;
            String search = BikeShopApiUtil.getParam('search');

            List<aiops_education__Bike__c> rows;
            Integer total;

            if (String.isBlank(search)) {
                total = [SELECT COUNT() FROM aiops_education__Bike__c];
                rows = [
                    SELECT Id, Name, aiops_education__Model__c, aiops_education__Brand__c, aiops_education__Category__c, aiops_education__Daily_Rate__c, aiops_education__Available__c, aiops_education__Mileage__c, aiops_education__Last_Service_Date__c
                    FROM aiops_education__Bike__c
                    ORDER BY CreatedDate DESC
                    LIMIT :pageSize
                    OFFSET :offsetRows
                ];
            } else {
                String likeSearch = '%' + search + '%';
                total = [SELECT COUNT() FROM aiops_education__Bike__c WHERE aiops_education__Model__c LIKE :likeSearch OR aiops_education__Brand__c LIKE :likeSearch OR Name LIKE :likeSearch];
                rows = [
                    SELECT Id, Name, aiops_education__Model__c, aiops_education__Brand__c, aiops_education__Category__c, aiops_education__Daily_Rate__c, aiops_education__Available__c, aiops_education__Mileage__c, aiops_education__Last_Service_Date__c
                    FROM aiops_education__Bike__c
                    WHERE aiops_education__Model__c LIKE :likeSearch OR aiops_education__Brand__c LIKE :likeSearch OR Name LIKE :likeSearch
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
    global static String createBike() {
        try {
            if (!Schema.sObjectType.aiops_education__Bike__c.isCreateable()) {
                throw new BikeShopApiUtil.ApiException('No create access to Bike.', 403);
            }

            Map<String, Object> body = BikeShopApiUtil.parseBody();
            String model = BikeShopApiUtil.getString(body, 'aiops_education__Model__c');
            String brand = BikeShopApiUtil.getString(body, 'aiops_education__Brand__c');
            String category = BikeShopApiUtil.getString(body, 'aiops_education__Category__c');
            Decimal dailyRate = BikeShopApiUtil.getDecimal(body, 'aiops_education__Daily_Rate__c');

            BikeShopApiUtil.validateText(model, 80, 'Model', true);
            BikeShopApiUtil.validateText(brand, 80, 'Brand', true);
            BikeShopApiUtil.validateText(category, 40, 'Category', true);
            BikeShopApiUtil.validatePositive(dailyRate, 'Daily Rate', true);

            aiops_education__Bike__c bike = new aiops_education__Bike__c();
            bike.Name = String.isBlank(BikeShopApiUtil.getString(body, 'Name')) ? brand + ' ' + model : BikeShopApiUtil.getString(body, 'Name');
            bike.aiops_education__Model__c = model;
            bike.aiops_education__Brand__c = brand;
            bike.aiops_education__Category__c = category;
            bike.aiops_education__Daily_Rate__c = dailyRate;
            bike.aiops_education__Available__c = body.containsKey('aiops_education__Available__c') ? BikeShopApiUtil.getBoolean(body, 'aiops_education__Available__c') : true;
            bike.aiops_education__Mileage__c = BikeShopApiUtil.getInteger(body, 'aiops_education__Mileage__c');
            bike.aiops_education__Last_Service_Date__c = BikeShopApiUtil.getDate(body, 'aiops_education__Last_Service_Date__c');

            insert bike;
            RestContext.response.statusCode = 201;
            return JSON.serialize(bike);
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }

    @HttpPatch
    global static String updateBike() {
        try {
            if (!Schema.sObjectType.aiops_education__Bike__c.isUpdateable()) {
                throw new BikeShopApiUtil.ApiException('No update access to Bike.', 403);
            }

            Id bikeId = BikeShopApiUtil.getIdFromUri();
            aiops_education__Bike__c bike = [SELECT Id, Name, aiops_education__Model__c, aiops_education__Brand__c, aiops_education__Category__c, aiops_education__Daily_Rate__c, aiops_education__Available__c, aiops_education__Mileage__c, aiops_education__Last_Service_Date__c FROM aiops_education__Bike__c WHERE Id = :bikeId LIMIT 1];

            Map<String, Object> body = BikeShopApiUtil.parseBody();
            if (body.containsKey('Name')) {
                String nameValue = BikeShopApiUtil.getString(body, 'Name');
                BikeShopApiUtil.validateText(nameValue, 80, 'Name', true);
                bike.Name = nameValue;
            }
            if (body.containsKey('aiops_education__Model__c')) {
                String modelValue = BikeShopApiUtil.getString(body, 'aiops_education__Model__c');
                BikeShopApiUtil.validateText(modelValue, 80, 'Model', true);
                bike.aiops_education__Model__c = modelValue;
            }
            if (body.containsKey('aiops_education__Brand__c')) {
                String brandValue = BikeShopApiUtil.getString(body, 'aiops_education__Brand__c');
                BikeShopApiUtil.validateText(brandValue, 80, 'Brand', true);
                bike.aiops_education__Brand__c = brandValue;
            }
            if (body.containsKey('aiops_education__Category__c')) {
                String categoryValue = BikeShopApiUtil.getString(body, 'aiops_education__Category__c');
                BikeShopApiUtil.validateText(categoryValue, 40, 'Category', true);
                bike.aiops_education__Category__c = categoryValue;
            }
            if (body.containsKey('aiops_education__Daily_Rate__c')) {
                Decimal rateValue = BikeShopApiUtil.getDecimal(body, 'aiops_education__Daily_Rate__c');
                BikeShopApiUtil.validatePositive(rateValue, 'Daily Rate', true);
                bike.aiops_education__Daily_Rate__c = rateValue;
            }
            if (body.containsKey('aiops_education__Available__c')) {
                bike.aiops_education__Available__c = BikeShopApiUtil.getBoolean(body, 'aiops_education__Available__c');
            }
            if (body.containsKey('aiops_education__Mileage__c')) {
                bike.aiops_education__Mileage__c = BikeShopApiUtil.getInteger(body, 'aiops_education__Mileage__c');
            }
            if (body.containsKey('aiops_education__Last_Service_Date__c')) {
                bike.aiops_education__Last_Service_Date__c = BikeShopApiUtil.getDate(body, 'aiops_education__Last_Service_Date__c');
            }

            update bike;
            return JSON.serialize(bike);
        } catch (QueryException qex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(new BikeShopApiUtil.ApiException('Bike not found.', 404)));
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }

    @HttpDelete
    global static String deleteBike() {
        try {
            if (!Schema.sObjectType.aiops_education__Bike__c.isDeletable()) {
                throw new BikeShopApiUtil.ApiException('No delete access to Bike.', 403);
            }

            Id bikeId = BikeShopApiUtil.getIdFromUri();
            delete [SELECT Id FROM aiops_education__Bike__c WHERE Id = :bikeId LIMIT 1];
            RestContext.response.statusCode = 204;
            return null;
        } catch (QueryException qex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(new BikeShopApiUtil.ApiException('Bike not found.', 404)));
        } catch (Exception ex) {
            return JSON.serialize(BikeShopApiUtil.errorResponse(ex));
        }
    }
}
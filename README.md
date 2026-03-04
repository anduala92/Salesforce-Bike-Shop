# Bike Shop Coursework (Salesforce)

## Данни за студент
- Факултетен номер: `2401322033`
- Име на проект: `Bike Shop Management System`

## Кратко описание
Приложение на тема **Bike Shop**, реализирано в Salesforce, с две части:
- **Back-end**: Apex REST уеб услуги (`/services/apexrest/bikeshop/v1/...`)
- **Front-end**: Lightning Web Component `bikeShopApp`, използващ REST услугите

## Изпълнение на изискванията

### 1) База данни
- Използвани са 3 свързани таблици (custom objects):
	- `Bike__c`
	- `Customer__c`
	- `Bike_Rental__c` (връзка към `Bike__c` и `Customer__c`)
- Всяка таблица има минимум 6 колони, с минимум 4 различни типа.
- Всяка таблица има поне 1 задължително поле, различно от primary key (`Model__c`, `First_Name__c`, `Last_Name__c`, `Email__c`, `Bike__c`, `Customer__c`, `Start_Date__c`, `End_Date__c`, и др.).
- Текстовите полета имат ограничение за дължина (`length`/`maxLength`).

### 2) Back-end уеб услуги (REST)
- `BikeRestService` → CRUD + search + pagination за `Bike__c`
- `CustomerRestService` → CRUD + search + pagination за `Customer__c`
- `RentalRestService` → CRUD + filter/search + pagination за `Bike_Rental__c`
- Валидация на входните данни е имплементирана в `BikeShopApiUtil` и REST услугите.

### 3) Защита
- Услугите са защитени чрез стандартната Salesforce автентикация (OAuth / Session token).
- Класовете са `with sharing`.
- Проверява се достъпът по CRUD на ниво обект (`isAccessible`, `isCreateable`, `isUpdateable`, `isDeletable`).

### 4) Open API specification
- OpenAPI файл: `docs/openapi.yaml`

### 5) Front-end
- LWC компонент: `force-app/main/default/lwc/bikeShopApp`
- Интерфейс с табове за Bikes, Customers и Rentals.
- Поддържа CRUD, търсене/филтриране и странициране чрез REST API.

### 6) Unit тестове (допълнителни точки)
- Apex тестове: `BikeShopApiTest.cls`

## Инсталация и стартиране

### Предварителни изисквания
- Node.js 18+
- Salesforce CLI (`sf`)
- Вече свързана Developer Org / Scratch Org

### 1. Инсталиране на npm зависимости
```bash
cd "/Users/aleksandar.aleksandrov/Desktop/PU Bike/Salesforce-Bike-Shop"
npm install
```

### 2. Деплой в свързания org
```bash
sf project deploy start --source-dir force-app
```

### 3. Пускане на Apex тестовете
```bash
sf apex run test --tests BikeShopApiTest --result-format human --code-coverage
```

### 4. Използване на UI
1. В Salesforce Setup създай `Lightning App Page`.
2. Добави LWC компонента `Bike Shop App`.
3. Отвори страницата и използвай табовете за работа с данните.

## REST ендпойнти
- `GET/POST /services/apexrest/bikeshop/v1/bikes`
- `PATCH/DELETE /services/apexrest/bikeshop/v1/bikes/{id}`
- `GET/POST /services/apexrest/bikeshop/v1/customers`
- `PATCH/DELETE /services/apexrest/bikeshop/v1/customers/{id}`
- `GET/POST /services/apexrest/bikeshop/v1/rentals`
- `PATCH/DELETE /services/apexrest/bikeshop/v1/rentals/{id}`

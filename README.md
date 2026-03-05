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

### 4) Open API specification (Swagger документация)
- **OpenAPI файл**: `docs/openapi.yaml` (OpenAPI 3.0.3 спецификация)
- **Покрива**:
  - Всички три REST услуги (Bikes, Customers, Rentals)
  - Всички CRUD операции (GET, POST, PATCH, DELETE)
  - Пагинирање и търсене
  - Валидация на входни данни
  - Статус кодове и отговорни схеми
  - OAuth 2.0 Bearer Token автентикация
  - Примери за заявки и отговори
- **Визуализирай с**: [Swagger UI](https://editor.swagger.io/) - копирай съдържанието на `docs/openapi.yaml` там

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
- Postman (за REST API тестване)

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

### 5. Преглед на OpenAPI документацията (Swagger)
1. Отвори файла `docs/openapi.yaml` в VS Code
2. Или го отвори в [Swagger Editor](https://editor.swagger.io/):
   - Копирай съдържанието на `docs/openapi.yaml`
   - Paste го в левия панел на Swagger Editor
   - Вижда ще се генерира интерактивна документация с примери
3. Документацията описва всички endpoints, параметри, и примери за заявки/отговори

### 6. Тестване в Postman с готова колекция
1. Отвори Postman
2. **Import** → **Upload Files** → избери `docs/postman-collection.json`
3. Collection "Bike Shop REST API" ще се импортира с 15 готови заявки
4. Във всяка заявка сетвай переменната `{{SALESFORCE_TOKEN}}`:
   - Отвори VS Code терминал и изпълни: `sf org display`
   - Копирай "Access Token" стойността
   - В Postman: **Collections** → **Variables** → `SALESFORCE_TOKEN` → paste стойността
5. Сега можеш да изпълниш всяка заявка директно от колекцията

---

## 🆕 Ново: Деплой в нова среда + OAuth конфигурация за Postman

Ако преминаваш към нова Salesforce среда и искаш да тестваш REST API през Postman с OAuth 2.0 аутентикация, следвай тази инструкция:

### FASE 1: Подготовка на новата среда

#### **Стъпка 1.1: Свържи се с новата org**
```bash
sf org login web --alias "PU Bike" --set-default
```
- Ще се отвори браузър
- Логирай се със своя Salesforce акаунт в новата среда
- Одобри достъпа
- Алиасът се запазва локално

#### **Стъпка 1.2: Провери текущия org**
```bash
sf org display
```
Трябва да видиш:
- `Alias: PU Bike`
- `Instance URL: https://...develop.my.salesforce.com`
- `Access Token: 00D...` (дълъг token)

### FASE 2: Премахване на namespace префикса (ВАЖНО!)

Ако проектът идва от среда със **namespace префикс** (например `aiops_education__`), трябва да го премахнеш:

#### **Стъпка 2.1: Automատична замяна на префикса**
```bash
cd "/Users/aleksandar.aleksandrov/Desktop/PU Bike/Salesforce-Bike-Shop"
find . -type f \( -name "*.cls" -o -name "*.js" -o -name "*.html" -o -name "*.json" -o -name "*.xml" \) \
  -not -path "*/node_modules/*" \
  -exec sed -i '' 's/aiops_education__//g' {} \;
```

Това премахва префикса от:
- ✅ Apex класове (`.cls`)
- ✅ JavaScript файлове (`.js`)
- ✅ HTML шаблони (`.html`)
- ✅ Metadata XML файлове (`.xml`)
- ✅ JSON конфигурации (`.json`)

#### **Стъпка 2.2: Проверка на премахването**
```bash
grep -r "aiops_education__" . --include="*.cls" --include="*.js" --include="*.html" | wc -l
```
Трябва да връща `0` (нулеви съвпадения)

### FASE 3: Деплой на проекта

#### **Стъпка 3.1: Полен деплой**
```bash
sf project deploy start --wait 10
```

Очакуван резултат:
```
Status: Succeeded
Components: 41/41 (100%)
```

#### **Стъпка 3.2: Проверка за грешки**
Ако имаш грешки като:
```
We couldn't retrieve the design time component information for component aiops_education:bikeShopApp.
In field: object - no CustomObject named aiops_education__Bike__c found
```

Това означава, че **префиксът не е премахнат напълно**. Повтори Стъпка 2.1.

### FASE 4: Присвояване на разрешения

#### **Стъпка 4.1: Присвой Permission Set на потребителя**
```bash
sf org assign permset --name Bike_Shop_App_Access
```

Резултат:
```
Permission Set Assignment
✔ Bike_Shop_App_Access assigned to stu2401322033.c9195e8f6294@agentforce.com
```

Това дава достъп до:
- ✅ Bike Shop приложението
- ✅ CRUD операции на Bike, Customer, Bike_Rental обекти
- ✅ API разрешения

### FASE 5: Създаване на Connected App за OAuth

Този процес **трябва да се направи ръчно през UI**, защото metadata деплоя има ограничения.

#### **Стъпка 5.1: Отвори App Manager**
1. В Salesforce, натисни **Ctrl+K** (или кликни иконката за търсене)
2. Търси: `App Manager`
3. Кликни на първия резултат

#### **Стъпка 5.2: Създай нова Connected App**
1. Кликни **"New Connected App"** (горе вдясно)
2. Попълни формата:
   - **Connected App Name**: `BikeShop Postman App`
   - **API Name**: `BikeShop_Postman_App` (автоматично)
   - **Contact Email**: `твоя-почта@example.com`
   - **Description**: `OAuth app for Bike Shop REST API testing via Postman`

#### **Стъпка 5.3: Включи OAuth настройки**
1. Марки чекбокса: **"Enable OAuth Settings"**
2. **Callback URL**: `https://oauth.pstmn.io/v1/callback`
3. **Selected OAuth Scopes** - Добави тези три:
   - ✅ `Access the Identity URL service`
   - ✅ `Perform requests on your behalf at any time`
   - ✅ `Access your basic information`
4. Кликни **Save**

#### **Стъпка 5.4: Генерирай Consumer Key и Secret**
1. После refresh на страницата, намери секцията **"OAuth 2.0 Credential ID:"**
2. До Consumer Secret има бутон **"Click to reveal"**
3. Копирай двете стойности и ги запази в сигурно място:
   ```
   Consumer Key: 3MVG9...XHoU...TXwwHz...
   Consumer Secret: 1234567890ABC...XYZ...
   ```

### FASE 6: Конфигурация на Postman

#### **Стъпка 6.1: Импортирай Postman колекция**
1. Отвори Postman
2. Кликни **Import** (горе вляво)
3. Избери файла: `BikeShop_API_Collection_No_Namespace.postman_collection.json`
4. Кликни **Import**

#### **Стъпка 6.2: Обнови променливите на колекцията**
1. В Postman, под колекцията `Bike Shop SOQL REST API Collection`, кликни **Variables** таб
2. Обнови следните **CURRENT VALUE** стойности:
   ```
   baseUrl = https://твоя-org.develop.my.salesforce.com
   clientId = (Consumer Key от Стъпка 5.4)
   clientSecret = (Consumer Secret от Стъпка 5.4)
   tokenUrl = https://твоя-org.develop.my.salesforce.com/services/oauth2/token
   authorizationUrl = https://твоя-org.develop.my.salesforce.com/services/oauth2/authorize
   ```
3. Кликни **Save** (Ctrl+S)

Пример как да видиш твоя URL:
```bash
sf org display | grep "Instance URL"
# Резултат: Instance URL: https://stu2401322033.c9195e8f6294.develop.my.salesforce.com
```

#### **Стъпка 6.3: Настрой OAuth 2.0 в Postman**
1. В Postman колекцията, отвори **Authorization** таб (в корена на колекцията)
2. Избери **Type**: `OAuth 2.0`
3. Кликни **Get New Access Token**
4. Попълни формата:
   ```
   Token Name = BikeShop OAuth Token
   Grant Type = Authorization Code
   Callback URL = https://oauth.pstmn.io/v1/callback
   Authorize using browser = ✅ (checked)
   Auth URL = {{authorizationUrl}}
   Access Token URL = {{tokenUrl}}
   Client ID = {{clientId}}
   Client Secret = {{clientSecret}}
   Scope = api refresh_token web
   Client Authentication = Send as Basic Auth header
   ```
5. Кликни **Get New Access Token**

#### **Стъпка 6.4: Одобри достъпа в браузър**
1. Ще се отвори нов браузър с Salesforce login страница
2. Логирай се със своя Salesforce учетна запис
3. Прочети разрешенията и кликни **Allow** / **Approve**
4. Ще видиш: "Authorization successful" или подобно съобщение
5. Вълнизъ се връщаш в Postman

#### **Стъпка 6.5: Проверка на токена**
Постман трябва да покажа:
```
✅ Token: 00DgK000006i5Gf!AQEAQCf3VfaYKW53xG...
✅ Token expires in: 7200 (2 часа)
```

Кликни **Use Token** или **Proceed**

### FASE 7: ВАЖНО - Настройка на Token Expiration

Ако получиш грешка как `Invalid Session ID` или `unauthorized` със списък URL-и, това означава че **токенът е изтекъл**.

**Решение: Включи Auto Refresh на токена**

1. В Postman, отвори колекцията → **Authorization** таб
2. Прокручи надолу до **Advanced Options**
3. Включи: ✅ `Automatically refresh access token`
4. Save

Това гарантира, че Postman автоматично ще обновява токена преди той да изтече.

### FASE 8: Тестване на REST API

#### **Стъпка 8.1: Направи първия тест**
1. В колекцията, отвори фолдера **BIKES API**
2. Избери request-а: **Get All Bikes**
3. Кликни **Send** (синия бутон)

#### **Стъпка 8.2: Проверка на резултата**
Ако е успешно, трябва да видиш:
```json
{
  "totalSize": 2,
  "done": true,
  "records": [
    {
      "attributes": {
        "type": "Bike__c",
        "url": "/services/data/v66.0/sobjects/Bike__c/a03gK00000SeTUcQAN"
      },
      "Id": "a03gK00000SeTUcQAN",
      "Name": "Gambler Scott",
      "Model__c": "Gambler",
      "Brand__c": "Scott",
      ...
    }
  ]
}
```

Status трябва да е **200 OK** или **201 Created** (не 401, 403, 404)

---

## REST ендпойнти

### Bikes
- `GET /services/apexrest/bikeshop/v1/bikes?page=1&pageSize=10` - Вземи всички велосипеди
- `GET /services/apexrest/bikeshop/v1/bikes/{id}` - Вземи един велосипед
- `POST /services/apexrest/bikeshop/v1/bikes` - Създай нов велосипед
- `PATCH /services/apexrest/bikeshop/v1/bikes/{id}` - Обнови велосипед
- `DELETE /services/apexrest/bikeshop/v1/bikes/{id}` - Изтрий велосипед

### Customers
- `GET /services/apexrest/bikeshop/v1/customers?page=1&pageSize=10` - Вземи всички клиенти
- `POST /services/apexrest/bikeshop/v1/customers` - Създай нов клиент
- `PATCH /services/apexrest/bikeshop/v1/customers/{id}` - Обнови клиент
- `DELETE /services/apexrest/bikeshop/v1/customers/{id}` - Изтрий клиент

### Rentals
- `GET /services/apexrest/bikeshop/v1/rentals?page=1&pageSize=10` - Вземи всички наеми
- `POST /services/apexrest/bikeshop/v1/rentals` - Създай нов наем
- `PATCH /services/apexrest/bikeshop/v1/rentals/{id}` - Обнови наем
- `DELETE /services/apexrest/bikeshop/v1/rentals/{id}` - Изтрий наем

---

## 🔧 Отстраняване на проблеми

### Проблем: `We couldn't retrieve the design time component information`
**Причина**: Namespace префиксът не е премахнат
**Решение**: Повтори Fase 2 (sed замяна)

### Проблем: `No CustomObject named Bike__c found`
**Причина**: Обектите още имат стар префикс в permissionset
**Решение**: Провери `force-app/main/default/permissionsets/*.xml` и премахни префиксите

### Проблем: `Invalid Session ID` / `unauthorized` в Postman
**Причина**: Токенът е изтекъл (стандартно - 2 часа)
**Решение**: 
1. Включи auto-refresh на токена (Fase 7)
2. ИЛИ ръчно генерирай нов токен (Fase 6.3-6.5)

### Проблем: `404 Not Found` на REST endpoints
**Причина**: Apex REST Services са отключени в org
**Решение**: 
1. Отвори Setup → Развернат търсачка → `REST API`
2. Убедис се, че е включено
3. Алтернатива: Използвай SOQL REST API вместо Apex REST (`/services/data/v66.0/query`)

---

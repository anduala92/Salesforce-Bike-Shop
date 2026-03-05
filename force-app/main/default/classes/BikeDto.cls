public class BikeDto {
    public String id;
    public String name;
    public String model;
    public String brand;
    public String category;
    public Decimal dailyRate;
    public Boolean available;
    public Integer mileage;
    public String lastServiceDate;

    public BikeDto(Bike__c bike) {
        this.id = bike.Id;
        this.name = bike.Name;
        this.model = bike.Model__c;
        this.brand = bike.Brand__c;
        this.category = bike.Category__c;
        this.dailyRate = bike.Daily_Rate__c;
        this.available = bike.Available__c;
        this.mileage = bike.Mileage__c == null ? 0 : Integer.valueOf(bike.Mileage__c);
        this.lastServiceDate = bike.Last_Service_Date__c == null ? null : bike.Last_Service_Date__c.format();
    }
}

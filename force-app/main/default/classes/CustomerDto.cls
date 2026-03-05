public class CustomerDto {
    public String id;
    public String name;
    public String firstName;
    public String lastName;
    public String email;
    public String phone;
    public String birthDate;
    public Integer loyaltyPoints;
    public Boolean isActive;

    public CustomerDto(Customer__c customer) {
        this.id = customer.Id;
        this.name = customer.Name;
        this.firstName = customer.First_Name__c;
        this.lastName = customer.Last_Name__c;
        this.email = customer.Email__c;
        this.phone = customer.Phone__c;
        this.birthDate = customer.Birth_Date__c == null ? null : customer.Birth_Date__c.format();
        this.loyaltyPoints = customer.Loyalty_Points__c == null ? 0 : Integer.valueOf(customer.Loyalty_Points__c);
        this.isActive = customer.Is_Active__c;
    }
}

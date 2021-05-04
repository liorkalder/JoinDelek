
create table City (
city nvarchar(20) primary key)

create table CityStreets (
city nvarchar(20) references City(city),
streetName nvarchar(50),
primary key(city,streetName))

create table Departments (
departmentName nvarchar(30) primary key)

-- Departments: שיווק, בקרת אשראי, תפעול הסכמים, כללי, לקוח

create table Roles (
roleTitle nvarchar(30) primary key)

-- Roles: משווק, מנהל, נציג, כללי, לקוח

create table Position (
positionNo int IDENTITY primary key,
departmentName nvarchar(30) references Departments(departmentName) constraint Position_departmentName_notNull not null,
roleTitle nvarchar(30) references Roles(roleTitle) constraint Position_roleTitle_notNull not null, 
constraint Position_uniqueRolePerDeparment unique (roleTitle,departmentName))

create table Users (
userEmail varchar(50) primary key constraint Users_userEmail_validation check (userEmail like '_%@_%._%'), 
firstName nvarchar(20) constraint Users_firstName_notNull not null,
lastName nvarchar(20) constraint Users_lastName_notNull not null,
positionNo int references Position(positionNo) constraint Users_positionNo_notNull not null)

create table Banks (
bankNo char(2) primary key constraint BanksAndBranches_bankNo_validation check (bankNo like ('[0-9][0-9]')),
bankName nvarchar(20) constraint BanksAndBranches_bankName_notNull not null)

create table BanksBranches(
bankNo char(2) references Banks(bankNo),
branchNo char(3) constraint BanksAndBranches_branchNo_validation check (branchNo like replicate('[0-9]',3)),
branchName nvarchar(20) constraint BanksAndBranches_branchName_notNull not null, 
Primary key (bankNo,branchNo))

create table Customers (
customerNo int IDENTITY(1000,1) primary key, 
type char(1) constraint Custumers_type_notNull not null constraint Custumers_type_P_or_B check (type in ('P','B')),
recruitBy varchar(50) references Users(userEmail) constraint Custumers_recruitBy_notNull not null,
ID char(9) constraint Custumers_ID_notNull not null constraint Custumers_ID_unique unique 
constraint Custumers_ID_validation check (ID like replicate('[0-9]',9)),
benzineConsumption int constraint Customers_benzineConsumption_positiveNo check (benzineConsumption >= 0),
solerConsumption int constraint Customers_solerConsumption_positiveNo check (solerConsumption >= 0),
benzineDiscount tinyint constraint Customers_benzineDiscount_range20to45 check (benzineDiscount between 20 and 45),
solerDiscount tinyint constraint Customers_solerDiscount_range180to230 check (solerDiscount between 180 and 230),
obligo int constraint Customers_obligo_range0to10000 check (obligo between 0 and 10000),
creditTermsCurrent tinyint constraint Customers_creditCurrent_0_15_30_45_60_90 check (creditTermsCurrent in (0,15,30,45,60,90)), 
constraint Customers_consumption_Exists check (benzineConsumption is not null or solerConsumption is not null),
city nvarchar(20),
streetName nvarchar(50), 
houseNo nvarchar(5), 
apartmentNo nvarchar(5),
zipCode int constraint Customer_zipCode_largerThanZero check (zipCode>0),
foreign key (city,streetName) references CityStreets(city,streetName),
modeOfPayment nvarchar(10) constraint Customers_modeOfPayment_Credit_Or_Bank 
check (modeOfPayment in ('credit','bank')),
creditCardNo varchar(16)  constraint Customers_creditCardNo_validation 
check (creditCardNo like replicate('[0-9]',16) or creditCardNo like replicate('[0-9]',15) or 
creditCardNo like replicate('[0-9]',14) or creditCardNo like replicate('[0-9]',13)),
creditCardOwnerFirstName nvarchar(20), 
creditCardOwnerLastName nvarchar(20),
creditCardOwnerID char(9) constraint Customers_creditCardOwnerID_validation 
check (creditCardOwnerID like replicate('[0-9]',9)),
expirationYear int constraint Customers_expirationYear_currentDateTo20Yr 
check (ExpirationYear between year(GETDATE()) and (year(GETDATE()) + 20)),
expirationMonth char(2) constraint Customers_expirationMonth_validation 
check (expirationMonth like ('[0-9][0-9]') and expirationMonth <13),
cvv char(3) constraint Customers_cvv_validation check (cvv like replicate('[0-9]',3)), 
constraint Customers_creditCardExpired check (convert(char(4),expirationYear) +'-'+ expirationMonth >= format(getdate(),'yyyy-MM')),
bankNo char(2),
branchNo char(3),
foreign key (bankNo,branchNo) references BanksBranches(bankNo,branchNo),
bankAccountNo bigint constraint Customers_bankAccountNo_validation 
check (bankAccountNo >0 and len(bankAccountNo) >4 and len(bankAccountNo) < 14))

create table PrivateCustomers (
customerNo int references Customers(customerNo) primary key,
firstName nvarchar(20),
lastName nvarchar(20),
cellNo char(10) constraint PrivateCustomers_cellNo_validation check (cellNo like ('05' + replicate('[0-9]',8))),
email varchar(50) constraint PrivateCustomers_email_Validation not null check (email like '_%@_%._%'),
bankOwnerFirstName nvarchar(20),
bankOwnerLastName nvarchar(20),
bankOwnerID int constraint PrivateCustomers_bankOwnerID_validation check (bankOwnerID like replicate('[0-9]',9)))
 
create table BusinessCustomers (
customerNo int references Customers(customerNo) primary key,
companyName nvarchar(50),
contactFirstName nvarchar(20),
contactLastName nvarchar(20),
contactPosition nvarchar(50),
contactCellNo char(10) constraint BusinessCustomers_contactCellNo_validation check (contactCellNo like ('05' + replicate('[0-9]',8))),
contactEmail varchar(50) constraint BusinessCustomers_contactEmail_notNull not null 
constraint BusinessCustomers_contactEmail_validation check (contactEmail like '_%@_%._%'))

create table Discounts (
discountNo int IDENTITY (1,1) primary key,
type char(1) constraint Discounts_type_NotNull not null constraint Discounts_type_B_or_S check (type in ('B','S')),
minConsumption int constraint Discounts_minConsumption_notNull not null 
constraint Discounts_minConsumption_positiveNo check (minConsumption >=0),
maxConsumption int constraint Discounts_maxConsumption_notNull not null, 
maxDiscountMarketing tinyint constraint Discounts_maxDiscountMarketing_notNull not null,
maxDiscountManager tinyint constraint Discounts_maxDiscountManager_notNull not null, 
constraint Discounts_maxConsumption_LargerThan_MinConsumption check (maxConsumption > minConsumption),
constraint Discounts_maxDiscountManager_LargerThan_maxDiscountMarketing check (maxDiscountManager >= maxDiscountMarketing))

create table CostumersDiscount (
customerNo int references Customers(customerNo),
discountNo int references Discounts(discountNo),
primary key (discountNo,customerNo))

create table ProcessStages (
stageName nvarchar(30) primary key )

--process Stages
-- פתיחת בקשת הצטרפות 
-- אישור תנאים מסחריים
-- חתימה על הסכם הצטרפות
-- בקרת אשראי
-- בקרת אשראי מקיפה
-- השלמת ביטחונות
-- השלמת נתונים
-- בדיקת תקינות ההסכם
-- עדכון תנאים מסחריים 
-- מאושר להקמה
-- בקשת ביטול
-- מבוטל


create table StagePermissions (
permissionNo int IDENTITY primary key, 
stageName nvarchar(30) references ProcessStages(stageName) constraint StagePermissions_stageName_notNull not null,
positionNo int references Position(positionNo) constraint StagePermissions_positionNo_notNull not null,
constraint StagePermissions_uniqueStageNameAndRole unique(stageName,positionNo))

-- Stages and permissions:
-- פתיחת בקשת הצטרפות - משווק מחלקת שיווק 
-- אישור תנאים מסחריים - מנהל מחלקת שיווק
-- חתימה על הסכם הצטרפות - לקוח לקוח
-- בקרת אשראי - נציג מחלקת בקרת אשראי
-- בקרת אשראי מקיפה - מנהל מחלקת בקרת אשראי
-- השלמת ביטחונות - משווק מחלקת שיווק
-- השלמת נתונים - משווק מחלקת שיווק
-- עדכון תנאים מסחריים - משווק מחלקת שיווק
-- בדיקת תקינות ההסכם - נציג מחלקת תפעול הסכמים
-- מאושר להקמה - משווק מחלקת שיווק 
-- בקשת ביטול - משווק מחלקת שיווק
-- מבוטל - משווק מחלקת שיווק

create table Status (
customerNo int references Customers(customerNo),
stageName nvarchar(30) references ProcessStages(stageName),
owner varchar(50) references Users(userEmail),
startDate datetime default getdate() constraint CustomerStatus_startDate_currentDate check (startDate = getdate()),
endDate datetime, 
details nvarchar(50),
constraint Status_endDate_LargerThan_startDate check (endDate >= startDate),
duration as endDate - startDate,
primary key (customerNo,stageName,startDate))

create table Attachments (
serialNo int IDENTITY(1,1) primary key,
fileType nvarchar(50) constraint Attachments_fileType_notNull not null,
fileName nvarchar(20) constraint Attachments_fileName_notNull not null,
fileDate datetime default getdate() constraint Attachments_fileDate_CurrentDate check (FileDate = getdate()),
customerNo int,
status nvarchar(30),
startDate datetime,
foreign key (customerNo,status,startDate) references Status(customerNo,stageName,startDate))

-- file type
-- אישור ניהול חשבון
-- ביטחונות
-- הסכם הצטרפות
-- דוח בדיקה פיננסית
-- דוח בדיקה פיננסית מקיפה
-- אישור ניכוי מס במקור וניהול ספרים
-- אישור ניהול חשבון בנק
-- אחר


-- Business rules & triggers:
-- 1. if Customers(BenzineConsumption) is not null then Customers(BenzineDiscount) is not null
-- 2. if Customers(SolerConsumption) is not null then Customers(SolerDiscount) is not null
-- 3. Customers(RecruitBy) can only be a user when Users(PositionNo) = [insert later the number related to Position(RoleTitle) = 'îùåå÷']
-- 4. if Customers(ModeOfPayment) = 'credit' then Customers(CreditCardNo, CreditCardOwnerFirstName, 
--    CreditCardOwnerLastName, CreditCardOwnerID, ExpirationYear, ExpirationMonth, CVV) is not null
-- 5. if Customers(ModeOfPayment) = 'bank' then Customers(BankNo, BranchNo, BankAccountNo) is not null
-- 6. if Customers(ModeOfPayment) and Customers(Type) = 'P' then 
--    PrivateCustomers(BankOwnerFirstName, BankOwnerLastName, BankOwnerID) is not null
-- 7. if Customers(Type) = 'B' then Customers(BankNo, BranchNo, BankAccountNo) is not null
-- 8. if Discounts(Type) = 'D' then CostumersDiscount(DiscountNo) = Discounts(DiscountNo) 
--    where get max Discounts(MinConsumption) < Customers(SolerConsumption)
-- 9. if Discounts(Type) = 'P' then CostumersDiscount(DiscountNo) = Discounts(DiscountNo) 
--    where get max Discounts(MinConsumption) < Customers(BenzineDiscount)
-- 10. Customers(BenzineDiscount) <= Discounts(MaxDiscountManager) where Discounts(Type) = 'P' 
--     based on Customer(CustomerNo) and CostumersDiscount(DiscountNo) 
-- 11. Customers(SolerConsumption) <= Discounts(MaxDiscountManager) where Discounts(Type) = 'D'
--     based on Customer(CustomerNo) and CostumersDiscount(DiscountNo)
-- 12. consider adding notification or limiting all together 


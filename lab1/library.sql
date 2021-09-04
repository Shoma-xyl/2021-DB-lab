drop database library;
create database library;
use library;
create table Book (
	ID char(8) primary key,
    name varchar(20) not null,
    author varchar(10),
    price float,
    status int default 0 check(status=0 or status=1)
	);

create table Reader (
	ID char(8) primary key,
    name varchar(10),
    age int,
    address varchar(20)
    );
    
create table Borrow (
	Book_ID char(8),
    Reader_ID char(8),
    Borrow_Date date,
    Return_Date date,
    foreign key(book_ID) references Book(ID) On Delete Cascade,
    foreign key(Reader_ID) references Reader(ID) On Delete Cascade,
    Constraint PK_Borrow Primary Key(Book_Id,Reader_ID)
    );


# 插入书籍
insert into Book value('b1', '数据库系统实现', 'Ullman', 59.0, 1);
insert into Book value('b2', '数据库系统概念', 'Abraham', 59.0, 1);
insert into Book value('b3', 'C++ Primer', 'Stanley', 78.6, 1);
insert into Book value('b4', 'Redis设计与实现', '黄建宏', 79.0, 1);
insert into Book value('b5', '人类简史', 'Yuval', 68.00, 0);
insert into Book value('b6', '史记(公版)', '司马迁', 220.2, 1);
insert into Book value('b7', 'Oracle Database 编程艺术', 'Thomas', 43.1, 1);
insert into Book value('b8', '分布式数据库系统及其应用', '邵佩英', 30.0, 0);
insert into Book value('b9', 'Oracle 数据库系统管理与运维', '张立杰', 51.9, 0);
insert into Book value('b10', '数理逻辑', '汪芳庭', 22.0, 0);
insert into Book value('b11', '三体', '刘慈欣', 23.0, 1);
insert into Book value('b12', 'Fluent python', 'Luciano', 354.2, 1);

# 插入读者
insert into Reader value('r1', '李林', 18, '中国科学技术大学东校区');
insert into Reader value('r2', 'Rose', 22, '中国科学技术大学北校区');
insert into Reader value('r3', '罗永平', 23, '中国科学技术大学西校区');
insert into Reader value('r4', 'Nora', 26, '中国科学技术大学北校区');
insert into Reader value('r5', '汤晨', 22, '先进科学技术研究院');
insert into Reader value('r6', 'Alice', 22, '中国科学技术大学南校区'); #新增
insert into Reader value('r7', 'Tom', 22, '中国科学技术大学中校区'); #新增

# 插入借书
insert into Borrow value('b5','r1',  '2021-03-12', '2021-04-07');
insert into Borrow value('b6','r1',  '2021-03-08', '2021-03-19');
insert into Borrow value('b11','r1',  '2021-01-12', NULL);

insert into Borrow value('b3', 'r2', '2021-02-22', NULL);
insert into Borrow value('b9', 'r2', '2021-02-22', '2021-04-10');
insert into Borrow value('b7', 'r2', '2021-04-11', NULL);

insert into Borrow value('b1', 'r3', '2021-04-02', NULL);
insert into Borrow value('b2', 'r3', '2021-04-02', NULL);
insert into Borrow value('b4', 'r3', '2021-04-02', '2021-04-09');
insert into Borrow value('b7', 'r3', '2021-04-02', '2021-04-09');

insert into Borrow value('b6', 'r4', '2021-03-31', NULL);
insert into Borrow value('b12', 'r4', '2021-03-31', NULL);

insert into Borrow value('b4', 'r5', '2021-04-10', NULL);

select * from Book;
select * from Reader;
select * from Borrow;

#二
#2.1实体完整性：主键不能为空或者重复
insert into Book value('b1', '数据库系统实现', 'Ullman', 59.0, 1);
insert into Book (name,price) value('数据结构', 29.0);
#2.2参照完整性：任一个外码值必须等于被参照关系 S 中所参照的候选码的某个值
insert into Borrow value('b15', 'r4', '2021-03-31', NULL);
#2.3用户自定义完整性
insert into Book value('b16', '数据结构习题集', '严蔚敏', 354.2, 3);
#三
#1
select ID,address
from Reader
where name='Rose';

#2
select Book.name,Borrow.Borrow_date
from Book,Borrow,Reader
where Reader.name='Rose' and Reader.ID=Borrow.Reader_ID and Borrow.Book_ID=Book.ID ;

#3
select Reader.name
from Reader
where Reader.ID not in (select distinct Reader.ID
						from Borrow,Reader
                        where Borrow.Reader_ID=Reader.ID
                        ) ;
                        
#4
select Book.name,Book.price
from Book
where Book.author = 'Ullman';

#5
select Book.ID,Book.name
from Reader,Book,borrow
where Reader.name='李林' and Reader.ID=Borrow.Reader_ID and Borrow.Book_ID=Book.ID and Borrow.Return_Date is NULL;

#6
select Reader.name
from Reader,Borrow
where Reader.ID=Borrow.Reader_ID
group by Borrow.Reader_ID
having count(*)>3;

#7
select Reader.name,Reader.ID
from Reader
where Reader.ID not in ( select Reader.ID
						 from Reader,Borrow
                         where Reader.ID = Borrow.Reader_ID and Borrow.Book_ID in ( select Borrow.Book_ID
																					from Reader,Borrow
                                                                                    where Reader.ID=Borrow.Reader_ID and Reader.name='李林')
                                                                                   ) ;
                                                                                   
#8
select Book.name,Book.ID
from Book
where instr(Book.name,'Oracle')>0;

#9
create view Reader_view (Reader_ID,Reader_name,Book_ID,Book_name,Borrow_date)
as select Reader.ID,Reader.name,Book.ID,Book.name,Borrow.Borrow_Date
	from Reader,Book,borrow
	where Reader.ID = Borrow.Reader_ID and Book.ID=Borrow.Book_ID;
select *
from Reader_view;
select Reader_view.Reader_ID,count(Reader_view.Book_ID) as Book_Number
from Reader_view
where Reader_view.Borrow_date between date_sub(curdate(),interval 1 year) and curdate()
group by Reader_view.Reader_ID;

#四
drop procedure update_BookID;
delimiter //
create procedure update_BookID(In Book_ID_Before char(8),In BooK_ID_After char(8))
begin
declare s int default 0;
declare continue handler for sqlexception set s=1;
declare continue handler for 1062 set s=2; #重复

start transaction;

insert into Book(ID,name,author,price,status)
select Book_ID_After,Book.name,Book.author,Book.price,Book.status
from Book
where Book.ID=Book_ID_Before;

update Borrow
set Book_ID=Book_ID_After
where Book_ID=Book_ID_before;

delete from Book
where Book.ID=Book_ID_Before;

if s=0 then
	commit;
elseif s=1 then
	rollback;
else
	rollback;
end if;
end //
delimiter ;
select * from Book;
select * from Borrow;
call update_BookID('b12','b13');
select * from Book;
select * from Borrow;
call update_BookID('b13','b12');

#五
drop procedure checks;
delimiter //
create  procedure checks(out wrong_num int)
begin
Declare s INT default 0;
Declare num INT default 0;
declare check_ID char(8);
declare check_name varchar(20);
declare check_price float;
declare check_author varchar(10);
declare check_status int;
DECLARE check_Book CURSOR for select * from Book ;
Declare continue Handler for NOT FOUND set s=1;
set wrong_num=0;
open check_Book;

Repeat
	Fetch check_Book Into check_ID,check_name,check_author,check_price,check_status;
	if s = 0 then
		if check_status=0 then 
			select count(*)
            from Borrow
            where Borrow.Book_ID=check_ID and Borrow.Return_Date is null
            into num;
            if(num>0) then
				set wrong_num=wrong_num+1;
			end if;
		elseif check_status=1 then
			select count(*)
            from Borrow
            where Borrow.Book_ID=check_ID and Borrow.Return_Date is null
            into num;
            if(num=0) then
				set wrong_num=wrong_num+1;
			end if;
		end if;
    end if;
Until s=1
End Repeat;

Close check_Book ;
end //
delimiter ;
select * from Book;
select * from Borrow;
call checks(@wrong_num);
select @wrong_num;
update Book set status='1' where ID='b8'; 
update Book set status='1' where ID='b9'; 
select * from Book;
call checks(@wrong_num);
select @wrong_num;
update Book set status='0' where ID='b8'; 
update Book set status='0' where ID='b9'; 

#六
drop trigger if exists Borrow_Book;
delimiter //
create trigger Borrow_Book 
after insert 
on Borrow
for each row
Begin
	Declare counter INT default 0;
	select count(*)
	from Borrow
	where Borrow.Book_ID=new.Book_ID and Borrow.Return_Date is null
	into counter;
    if(counter>0) then
		update Book
        set Book.status=1
        where Book.ID=new.Book_ID;
	elseif(counter=0) then
		update Book
        set Book.status=0
        where Book.ID=new.Book_ID;
	end if;
end //
delimiter ;
drop trigger if exists Return_Book;
delimiter //
create trigger Return_Book 
after update
on Borrow
for each row
Begin
	Declare counter INT default 0;
	select count(*)
	from Borrow
	where Borrow.Book_ID=new.Book_ID and Borrow.Return_Date is null
	into counter;
    if(counter>0) then
		update Book
        set Book.status=1
        where Book.ID=new.Book_ID;
	elseif(counter=0) then
		update Book
        set Book.status=0
        where Book.ID=new.Book_ID;
	end if;
end //
delimiter ;
select * from Book;
select * from Borrow;
insert into Borrow value('b8', 'r6', '2021-04-10', NULL);
select * from Book;
select * from Borrow;
update Borrow set Return_Date='2021-04-21' where Book_ID='b8' and Reader_ID='r6';
select * from Book;
select * from Borrow;


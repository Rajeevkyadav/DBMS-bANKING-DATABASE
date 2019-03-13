


create or replace trigger tri_transaction after insert on transaction 
declare
t transaction%rowtype;
bal number(38,2);
cursor c1 is select * from transaction;
begin
open c1;
loop
fetch c1 into t;
exit when c1%notfound;
end loop;
select current_balance into bal from account_details where account_no=t.account_no;
if (t.transaction_type_code=122) then
update account_details set current_balance=current_balance+t.amount where account_no=t.account_no;
elsif ((t.transaction_type_code=121) AND (t.amount >bal)) then
raise_application_error(-20113,' Insufficient amount');
elsif ((t.transaction_type_code=121) and (t.amount <=bal)) then
update account_details set current_balance=current_balance-t.amount where account_no=t.account_no;
elsif(t.transaction_type_code=123) then
    if(t.amount>bal) then
  raise_application_error(-20116,'Insufficient amount');
 elsif((t.amount<=bal)and (substr(t.merchant_id_ifsc,1,2)='GB')) then
update account_details set current_balance=current_balance-t.amount where account_no=t.account_no;
update account_details set current_balance=current_balance+t.amount where account_no=t.merchant_id;
  else
update account_details set current_balance=current_balance-t.amount where account_no=t.account_no;
   end if;


end if;
close c1;
end;
/
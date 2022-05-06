with Ada.Text_IO; use Ada.Text_IO;

with GNAT.Semaphores; use GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Dinner_Philosophers_Token is

   package Integer_Lists is new Indefinite_Doubly_Linked_Lists (Integer);
   use Integer_Lists;

   forks : array (1 .. 5) of Counting_Semaphore (1, Default_Ceiling);

   ready_dinner : array (1 .. 5) of Counting_Semaphore (0, Default_Ceiling);

   Access_Order : Counting_Semaphore (1, Default_Ceiling);
   Empty_Order  : Counting_Semaphore (0, Default_Ceiling);

   dinner_order : List;

   dinner_numbers : Integer := 7;

   task token;

   task body token is
      phil_num : integer;
   begin
      for i in 1 .. dinner_numbers * 5 loop

         Empty_Order.Seize;

         --Access_Order.Seize;

         phil_num := dinner_order.First_Element;
         Put_Line("token go to" & phil_num'Img & " philosopher");
         ready_dinner(phil_num).Release;
         dinner_order.Delete_First;

         Access_Order.Seize;
      end loop;
   end token;

   task type philosopher is
      entry set_id (id : in Integer);
   end philosopher;

   task body philosopher is
      id : Integer;

      num_second_fork : Integer;
   begin
      accept set_id (id : in Integer) do
         philosopher.id := id;
      end set_id;
      num_second_fork := id rem 5 + 1;

      for i in 1 .. dinner_numbers loop
         Put_Line ("philosopher" & id'Img & " thinking");

         delay 2.0;
         --Access_Order.Seize;
         dinner_order.Append(id);
         Empty_Order.Release;
         --Access_Order.Release;

         Put_Line ("philosopher" & id'Img & " await token");
         ready_dinner(id).Seize;

         delay 2.0;
         forks (id).Seize;
         delay 1.0;
         forks (num_second_fork).Seize;

         Put_Line ("philosopher" & id'Img & " eating" & i'Img & " times");

         forks (num_second_fork).Release;
         forks (id).Release;
         Access_Order.Release;
      end loop;
   end philosopher;

   philosophers : array (1 .. 5) of philosopher;
begin
   for i in philosophers'Range loop
      philosophers (i).set_id (i);
   end loop;
end Dinner_Philosophers_Token;

library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--use work.mp.all;

entity MAC_tb is
    PORT(
--        clk : in std_logic;
--        cntrl : in integer;
--        kernel : in integer;
--        element : in integer;
        o : out integer
    );
end MAC_tb;

architecture Behavioral of MAC_tb is

signal index : integer := 0;
signal ct : integer := 0;
signal tmp : integer;
signal total : integer := 0;

signal clk : std_logic;
signal cntrl : integer := 0;
signal kernel : integer;
signal element : integer; 

begin

clock : process
begin
clk <= '0';
wait for 5 ns;
clk <= '1';
wait for 5 ns;
end process;

control : process
begin
kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;

kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;

kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;

kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;

kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;

kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;

kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;

kernel <= 1;
element <= 5;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;
kernel <= -2;
element <= 1;
cntrl <= 2;
wait for 10 ns;
cntrl <= 3;
wait for 10 ns;

cntrl <= 4;
wait for 20 ns;
end process;

process(clk, cntrl)
begin
if rising_edge(clk) then
    if cntrl = 2 then
        tmp <= kernel*element;
    elsif cntrl = 3 then
        total <= total + tmp;
    elsif cntrl = 4 then
        o <= total;
        total <= 0;
    end if;
end if;
end process;

end Behavioral;
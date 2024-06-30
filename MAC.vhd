library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--use work.mp.all;

entity MAC is
    PORT(
        clk : in std_logic;
        cntrl : in integer;
        kernel : in integer;
        element : in integer;
        o : out integer
    );
end MAC;

architecture Behavioral of MAC is

signal index : integer := 0;
signal ct : integer := 0;
signal tmp : integer;
signal total : integer := 0;
begin

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
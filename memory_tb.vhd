LIBRARY IEEE;
LIBRARY WORK;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory_tb is
--PORT(
--    clk : IN std_logic;
--    cntrl : IN integer;
--    image_add : IN std_logic_vector(11 downto 0);
--    kernel_add : IN std_logic_vector(3 downto 0);
--    image_data : OUT std_logic_vector(7 downto 0);
--    kernel_data : OUT std_logic_vector(7 downto 0);
--    output_add : IN std_logic_vector(11 downto 0);
--    write_enable : IN std_logic_vector(0 downto 0);
--    output_data_in : IN std_logic_vector(19 downto 0);
--    output_data_out : OUT std_logic_vector(19 downto 0)
--);
end ENTITY memory_tb;

ARCHITECTURE send of memory_tb is

signal en : std_logic := '1';
signal clk : std_logic;
signal cntrl : integer := 0;
signal image_add : std_logic_vector(11 downto 0);
signal kernel_add : std_logic_vector(3 downto 0);
signal output_add : std_logic_vector(11 downto 0);
signal write_enable : std_logic_vector(0 downto 0) := "1";
signal output_data_in : std_logic_vector(19 downto 0);
signal count : integer := 0;
signal pos : integer := 0;
signal kernel_pos : integer := 0;
signal id : integer;
signal ke : integer;
signal image_data : std_logic_vector(7 downto 0);
signal kernel_data : std_logic_vector(7 downto 0);
signal output_data_out : std_logic_vector(19 downto 0);
    
COMPONENT filter
    PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END COMPONENT;

COMPONENT image
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
END COMPONENT;

COMPONENT computed
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
      );
END COMPONENT;

begin

original : image
PORT MAP(
    clka => clk,
    ena => en,
    addra => image_add,
    douta => image_data
);

kernel : filter
PORT MAP(
    clka => clk,
    ena => en,
    addra => kernel_add,
    douta => kernel_data
);

output : computed
PORT MAP(
    clka => clk,
    wea => write_enable,
    addra => output_add,
    dina => output_data_in,
    douta => output_data_out
);

clock : process
begin
clk <= '0';
wait for 5 ns;
clk <= '1';
wait for 5 ns;
end process;

process(clk)
begin
if rising_edge(clk) then
    if pos <= 4095 then
        if count = 0 then
            image_add <= std_logic_vector(to_unsigned(pos, 12));
            kernel_add <= std_logic_vector(to_unsigned(kernel_pos, 4));
            count <= 1;
        elsif count = 1 then
            count <= 2;
        elsif count = 2 then
            output_add <= std_logic_vector(to_unsigned(pos, 12));
            id <= TO_INTEGER(unsigned(image_data));
            ke <= TO_INTEGER(signed(kernel_data));
            pos <= (pos+1) mod 4096;
            kernel_pos <= (kernel_pos+1) mod 9;
            count <= 3;
        elsif count = 3 then count <= 4;
        elsif count = 4 then
            output_data_in <= std_logic_vector(TO_SIGNED(id*ke, 20));
            count <= 5;
        elsif count = 5 then count <= 6;
        elsif count = 6 then count <= 7;
        elsif count = 7 then count <= 8;
        elsif count = 8 then count <= 9;
        elsif count = 9 then count <= 0;
        end if;
    end if;
end if;
end process;

end send;
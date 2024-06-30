LIBRARY IEEE;
LIBRARY WORK;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory is
PORT(
    clk : IN std_logic;
    cntrl : IN integer;
    image_add : IN std_logic_vector(11 downto 0);
    kernel_add : IN std_logic_vector(3 downto 0);
    image_data : OUT std_logic_vector(7 downto 0);
    kernel_data : OUT std_logic_vector(7 downto 0);
    output_add : IN std_logic_vector(11 downto 0);
    write_enable : IN std_logic_vector(0 downto 0);
    output_data_in : IN std_logic_vector(19 downto 0);
    output_data_out : OUT std_logic_vector(19 downto 0)
);
end ENTITY memory;

ARCHITECTURE send of memory is

signal en : std_logic := '1';

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

--process(clk)
--begin
--if rising_edge(clk) then
    
--end if;
--end process;

end send;
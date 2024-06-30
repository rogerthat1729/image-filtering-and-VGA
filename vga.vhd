library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga_controller is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        vidon : out STD_LOGIC;
        x : out std_logic_vector(5 downto 0);
        y : out std_logic_vector(5 downto 0);
        concatenated_address: out STD_LOGIC_VECTOR(11 downto 0)
    );
end entity vga_controller;

architecture vga_module of vga_controller is
    constant h_end : integer := 799;

    constant v_end : integer := 524;

    constant start_h : integer := 150;
    constant start_v : integer := 150;

    constant width : integer := 64;
    constant height : integer := 64;

    signal clk_25M : STD_LOGIC := '0';

    signal p1 : integer := 0;
    signal horiz_curr : STD_LOGIC_VECTOR(9 downto 0);
    signal horiz_nxt : STD_LOGIC_VECTOR(9 downto 0);
    signal vert_curr : STD_LOGIC_VECTOR(9 downto 0);
    signal vert_nxt : STD_LOGIC_VECTOR(9 downto 0);
    signal enable : std_logic := '0';

    signal vsync_curr : STD_LOGIC;
    signal hsync_curr : STD_LOGIC;
    signal vsync_nxt : STD_LOGIC;
    signal hsync_nxt : STD_LOGIC;

--    signal clk : std_logic;
--    signal reset : std_logic := '0';
--    signal hsync : std_logic;
--    signal vidon : std_logic;
--    signal vsync : std_logic;
--    signal x : std_logic_vector(5 downto 0);
--    signal y : std_logic_vector(5 downto 0);
--    signal concatenated_address: STD_LOGIC_VECTOR(11 downto 0);
    
    
begin

--   clock : process
--   begin
--       clk <= '0';
--       wait for 5 ns;
--       clk <= '1';
--       wait for 5 ns;
--   end process;
   
--   resetproc : process
--   begin
--        reset <= '1';
--        wait for 5 ns;
--        reset <= '0';
--        wait for 500000ns;
--  end process;

--clock divider module

    clock_process: process(clk, reset)
    begin
        if(rising_edge(clk)) then
        if reset='1' then
            clk_25M <= '0';
        elsif p1 = 0 then
            clk_25M <= '1';
            p1 <= 1;
        elsif p1 = 1 then
            clk_25M <= '0';
            p1 <= 2;
        elsif p1 = 2 then
            clk_25M <= '0';
            p1 <= 3;
        elsif p1 = 3 then
            clk_25M <= '0';
            p1 <= 0;
        end if;
        end if;
    end process;

-- the next two processes handle horizontal and vertical counters

    change_curr: process(clk, reset)
    begin
        if reset = '1' then
            vert_curr <= (others => '0');
            horiz_curr <= (others => '0');
            vsync_curr <= '0';
            hsync_curr <= '0';
        elsif rising_edge(clk) then
            vert_curr <= vert_nxt;
            horiz_curr <= horiz_nxt;
            vsync_curr <= vsync_nxt;
            hsync_curr <= hsync_nxt;
        end if;
    end process;

    change_counters: process(clk_25M, horiz_curr)
    begin
        if clk_25M = '1' then
            if horiz_curr = h_end then
                horiz_nxt <= (others => '0');
                if(vert_curr = v_end) then
                    vert_nxt <= (others => '0');
                else
                    vert_nxt <= vert_curr + 1;
                 end if;
            else
                horiz_nxt <= horiz_curr + 1;
                vert_nxt <= vert_curr;
            end if;
        else
            horiz_nxt <= horiz_curr;
            vert_nxt <= vert_curr;
        end if;
    end process;

-- the next three processes control hsync, vsync and consequently vidon

    change_h_sync : process (horiz_curr)
    begin
       if horiz_curr >= 656 and horiz_curr <= 751 then
            hsync_nxt <= '1';
        else
            hsync_nxt <= '0';
       end if;
    end process;

    change_v_sync : process (vert_curr)
    begin
        if vert_curr >= 513 and vert_curr <= 514 then
            vsync_nxt <= '1';
        else
            vsync_nxt <= '0';
        end if;
    end process;

    sendVidOn: process (horiz_curr,vert_curr)
    begin

        if   start_h<=horiz_curr and horiz_curr<= start_h + width - 1 and start_v<=vert_curr and vert_curr <= start_v + height - 1 then
            vidon <= '1';
        else
            vidon <= '0';
        end if;
    end process;

    hsync <=  hsync_curr;
    vsync <= vsync_curr;

-- this address represents the pixel location
   x <= horiz_curr(5 downto 0)-start_h;
   y <= vert_curr(5 downto 0)-start_v;
   concatenated_address<= (vert_curr(5 downto 0)-start_v)&(horiz_curr(5 downto 0)-start_h);
end vga_module;
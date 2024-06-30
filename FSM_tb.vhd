LIBRARY IEEE;
LIBRARY WORK;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY FSM_module_tb is
Port(
    Hsync : OUT STD_LOGIC;
    Vsync : OUT STD_LOGIC;
    color : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
);
END ENTITY FSM_module_tb;

ARCHITECTURE control of FSM_module_tb is
    signal pos : integer := 0;
    signal itr : integer := 0;
    signal index : integer := 0;
    signal imAdd : std_logic_vector(11 downto 0);
    signal keAdd : std_logic_vector(3 downto 0);
    signal ouAdd : std_logic_vector(11 downto 0);
    signal we : std_logic_vector(0 downto 0) := "1";
    signal ouDataIn : std_logic_vector(19 downto 0);
    signal ouDataOut : std_logic_vector(19 downto 0);
    signal imData : std_logic_vector(7 downto 0);
    signal keData : std_logic_vector(7 downto 0);

    signal reg1 : integer;
    signal reg2 : integer;
    signal reg3 : integer;
    signal reg4 : integer;

    signal mn : integer := 100000;
    signal mx : integer := -100000;

    signal pixel_coordinates : std_logic_vector(11 downto 0);
    signal videoOn : std_logic;
    signal color_reg : std_logic_vector(11 downto 0);

    signal cntrl : integer := -1;
    signal count : integer := 0;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal switch : std_logic := '1';


    COMPONENT memory is
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
    end COMPONENT;

    COMPONENT MAC is
    PORT(
        clk : in std_logic;
        cntrl : in integer;
        kernel : in integer;
        element : in integer;
        o : inout integer
    );
    END COMPONENT;

    COMPONENT vga_controller is
    PORT(
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        vidon : out STD_LOGIC;
        concatenated_address: out STD_LOGIC_VECTOR(11 downto 0)
    );
    END COMPONENT;

begin

    mem : memory
    PORT MAP(
        clk => clk,
        cntrl => cntrl,
        image_add => imAdd,
        kernel_add => keAdd,
        output_add=>ouAdd,
        image_data => imData,
        kernel_data => keData,
        write_enable => we,
        output_data_in => ouDataIn,
        output_data_out => ouDataOut
    );

    comp : MAC
    PORT MAP(
        clk => clk,
        cntrl => cntrl,
        kernel => reg1,
        element => reg2,
        o => reg3
    );

    vga_sync : vga_controller
    PORT MAP(
        clk => clk,
        reset => reset,
        hsync => Hsync,
        vsync => Vsync,
        vidon => videoOn,
        concatenated_address => pixel_coordinates
    );

    clock : process
    begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    end process;


    writeIntoRAM : process(clk, reset)
    variable x : integer;
    variable y : integer;
    begin
        if rising_edge(clk) then
            if pos <= 4095 and itr = 0 then
                x := pos/64;
                y := pos mod 64;

                if index = 0 then
                        if count = 0 then
                            if x = 0 or y = 0 then
                                imAdd <= std_logic_vector(to_unsigned(0, 12));
                            else
                                imAdd <= std_logic_vector(to_unsigned(64*(x-1) + y-1, 12));
                            end if;
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then
                            count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count = 4 then
                            if x= 0 or y = 0 then
                                reg1 <= 0;
                            else
                                reg1 <= to_integer(unsigned(imData));
                            end if;
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            count <= 0;
                        end if;
                 end if;

                 if index = 1 then
                        if count = 0 then
                            if x = 0 then
                                imAdd <= std_logic_vector(to_unsigned(0, 12));
                            else
                                imAdd <= std_logic_vector(to_unsigned(64*(x-1) + y, 12));
                            end if;
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count=4 then
                            if x= 0 then
                                reg1 <= 0;
                            else
                                reg1 <= to_integer(unsigned(imData));
                            end if;
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            reg1 <= 0;
                            reg2 <= 0;
                            count <= 0;
                        end if;
                 end if;

                 if index = 2 then
                        if count = 0 then
                            if x = 0 or y = 63 then
                                imAdd <= std_logic_vector(to_unsigned(0, 12));
                            else
                                imAdd <= std_logic_vector(to_unsigned(64*(x-1) + y+1, 12));
                            end if;
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count=4 then
                            if x= 0 or y = 63 then
                                reg1 <= 0;
                            else
                                reg1 <= to_integer(unsigned(imData));
                            end if;
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            reg1 <= 0;
                            reg2 <= 0;
                            count <= 0;
                        end if;
                 end if;

                 if index = 3 then
                        if count = 0 then
                            if y=0 then
                                imAdd <= std_logic_vector(to_unsigned(0, 12));
                            else
                                imAdd <= std_logic_vector(to_unsigned(64*x + y-1, 12));
                            end if;
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count=4 then
                            if y=0 then
                                reg1 <= 0;
                            else
                                reg1 <= to_integer(unsigned(imData));
                            end if;
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            reg1 <= 0;
                            reg2 <= 0;
                            count <= 0;
                        end if;
                 end if;

                 if index = 4 then
                        if count = 0 then
                            imAdd <= std_logic_vector(to_unsigned(64*x + y, 12));
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count=4 then
                            reg1 <= to_integer(unsigned(imData));
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            reg1 <= 0;
                            reg2 <= 0;
                            count <= 0;
                        end if;
                 end if;

                 if index = 5 then
                        if count = 0 then
                            if y = 63 then
                                imAdd <= std_logic_vector(to_unsigned(0, 12));
                            else
                                imAdd <= std_logic_vector(to_unsigned(64*x + y+1, 12));
                            end if;
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count=4 then
                            if y = 63 then
                                reg1 <= 0;
                            else
                                reg1 <= to_integer(unsigned(imData));
                            end if;
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            reg1 <= 0;
                            reg2 <= 0;
                            count <= 0;
                        end if;
                 end if;

                 if index = 6 then
                        if count = 0 then
                            if x = 63 or y=0 then
                                imAdd <= std_logic_vector(to_unsigned(0, 12));
                            else
                                imAdd <= std_logic_vector(to_unsigned(64*(x+1) + y-1, 12));
                            end if;
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count=4 then
                            if x= 63 or y = 0 then
                                reg1 <= 0;
                            else
                                reg1 <= to_integer(unsigned(imData));
                            end if;
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            reg1 <= 0;
                            reg2 <= 0;
                            count <= 0;
                        end if;
                 end if;

                 if index = 7 then
                        if count = 0 then
                            if x=63 then
                                imAdd <= std_logic_vector(to_unsigned(0, 12));
                            else
                                imAdd <= std_logic_vector(to_unsigned(64*(x+1) + y, 12));
                            end if;
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count=4 then
                            if x=63 then
                                reg1 <= 0;
                            else
                                reg1 <= to_integer(unsigned(imData));
                            end if;
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            reg1 <= 0;
                            reg2 <= 0;
                            count <= 0;
                        end if;
                 end if;

                 if index = 8 then
                        if count = 0 then
                            if x = 63 or y = 63 then
                                imAdd <= std_logic_vector(to_unsigned(0, 12));
                            else
                                imAdd <= std_logic_vector(to_unsigned(64*(x+1) + y+1, 12));
                            end if;
                            count <= 1;
                        elsif count = 1 then count <= 2;
                        elsif count = 2 then count <= 3;
                        elsif count = 3 then count <= 4;
                        elsif count=4 then
                            if x= 63 or y = 63 then
                                reg1 <= 0;
                            else
                                reg1 <= to_integer(unsigned(imData));
                            end if;
                            cntrl <= -1;
                            count <= 5;
                        elsif count = 5 then
                            keAdd <= std_logic_vector(to_unsigned(index, 4));
                            count <= 6;
                        elsif count = 6 then count <= 7;
                        elsif count = 7 then
                            count <= 8;
                        elsif count = 8 then count <= 9;
                        elsif count = 9 then
                            reg2 <= to_integer(signed(keData));
                            cntrl <= -1;
                            count <= 10;
                        elsif count = 10 then count <= 11;
                        elsif count = 11 then cntrl <= 2; count <= 12;
                        elsif count = 12 then cntrl <= 3; count <= 13;
                        elsif count = 13 then cntrl <= -1; count <= 14;
                        elsif count = 14 then
                            index <= index + 1;
                            reg1 <= 0;
                            reg2 <= 0;
                            count <= 0;
                        end if;
                 end if;

                 if index = 9 then
                    if count = 0 then cntrl <= 4; count <= 1;
                    elsif count = 1 then cntrl <= -1; count <= 2;
                    elsif count = 2 then
                        ouAdd <= std_logic_vector(to_unsigned(pos, 12));
                        count <= 3;
                    elsif count = 3 then count <= 4;
                    elsif count = 4 then
                        ouDataIn <= std_logic_vector(to_unsigned(reg3, 20));
                        count <= 5;
                    elsif count = 5 then count <= 6;
                    elsif count = 6 then count <= 7;
                    elsif count = 7 then count <= 8;
                    elsif count = 8 then count <= 9;
                    elsif count = 9 then count <= 10;
                    elsif count = 10 then
                        if reg3 < mn then
                            mn <= reg3;
                        end if;
                        if reg3 > mx then
                            mx <= reg3;
                        end if;
                        count <= 11;
                        cntrl <= -1;
                    elsif count = 11 then
                        if pos = 4095 then
                            pos <= 0;
                            itr <= 1;
                        else
                            pos <= pos + 1;
                        end if;
                        count <= 0;
                        index <= 0;
                    end if;
                 end if;
            end if;

            if pos <= 4095 and itr = 1 then
                if count = 0 then
                    ouAdd <= std_logic_vector(to_unsigned(pos, 12));
                    we <= "0";
                    count <= 1;
                elsif count = 1 then count <= 2;
                elsif count = 2 then count <= 3;
                elsif count = 3 then
                    reg4 <= to_integer(signed(ouDataOut));
                    we <= "1";
                    cntrl <= -1;
                    count <= 4;
                elsif count = 4 then
                    reg4 <= reg4 - mn;
                    count <= 105;
                elsif count = 105 then count <= 106;
                elsif count = 106 then
                    reg4 <= 255*reg4;
                    count <= 107;
                elsif count = 107 then count <= 108;
                elsif count = 108 then count <= 109;
                elsif count = 109 then
                    reg4 <= reg4/(mx - mn);
                    count <= 110;
                elsif count = 110 then count <= 111;
                elsif count = 111 then count <= 112;
                elsif count = 112 then count <= 113;
                elsif count = 113 then count <= 5;
                elsif count = 5 then
                    ouDataIn <= std_logic_vector(to_unsigned(reg4, 20));
                    count <= 6;
                elsif count = 6 then count <= 7;
                elsif count = 7 then count <= 8;
                elsif count = 8 then count <= 9;
                elsif count = 9 then count <= 10;
                elsif count = 10 then count <= 11;
                elsif count = 11 then count <= 12;
                elsif count = 12 then
                    pos <= pos + 1;
                    count <= 0;
                end if;
            end if;

            if pos > 4095 then
                we <= "0";
                imAdd <= pixel_coordinates;
                ouAdd <= pixel_coordinates;
            end if;
       end if;
  end process;

sendColor: process (imData, ouDataOut, switch)
    begin
    if pos > 4095 then
        if(switch='1') then
             color_reg <= imData(7 DOWNTO 4) & imData(7 DOWNTO 4) & imData(7 DOWNTO 4);
        else
             color_reg <= ouDataOut(7 DOWNTO 4) & ouDataOut(7 DOWNTO 4) & ouDataOut(7 DOWNTO 4);
        end if;
    end if;
    end process;

--syncing with video_on to display right data

color <= color_reg when videoOn = '1' else "000000000000";

end control;
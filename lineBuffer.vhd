library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lineBuffer is
    Port (
        i_clk         : in  std_logic;
        i_rst         : in  std_logic;
        i_data        : in  std_logic_vector(7 downto 0);
        i_data_valid  : in  std_logic;
        o_data        : out std_logic_vector(23 downto 0);
        i_rd_data     : in  std_logic
    );
end entity lineBuffer;

architecture Behavioral of lineBuffer is
    type line_array is array (0 to 511) of std_logic_vector(7 downto 0);
    signal line     : line_array;
    signal wrPntr   : unsigned(8 downto 0) := (others => '0');
    signal rdPntr   : unsigned(8 downto 0) := (others => '0');
begin

    
    write_process: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_data_valid = '1' then
                line(to_integer(wrPntr)) <= i_data;
            end if;
        end if;
    end process;

   
    wrPntr_process: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                wrPntr <= (others => '0');
            elsif i_data_valid = '1' then
                wrPntr <= wrPntr + 1;
            end if;
        end if;
    end process;

   
    rdPntr_process: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                rdPntr <= (others => '0');
            elsif i_rd_data = '1' then
                rdPntr <= rdPntr + 1;
            end if;
        end if;
    end process;

    
    o_data <= line(to_integer(rdPntr)) & line(to_integer(rdPntr + 1)) & line(to_integer(rdPntr + 2));

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity imageControl is
    Port (
        i_clk               : in  std_logic;
        i_rst               : in  std_logic;
        i_pixel_data        : in  std_logic_vector(7 downto 0);
        i_pixel_data_valid  : in  std_logic;
        o_pixel_data        : out std_logic_vector(71 downto 0);
        o_pixel_data_valid  : out std_logic;
        o_intr              : out std_logic
    );
end imageControl;

architecture Behavioral of imageControl is
    signal pixelCounter       : unsigned(8 downto 0);
    signal currentWrLineBuffer: unsigned(1 downto 0);
    signal lineBuffDataValid  : std_logic_vector(3 downto 0);
    signal lineBuffRdData     : std_logic_vector(3 downto 0);
    signal currentRdLineBuffer: unsigned(1 downto 0);
    signal lb0data            : std_logic_vector(23 downto 0);
    signal lb1data            : std_logic_vector(23 downto 0);
    signal lb2data            : std_logic_vector(23 downto 0);
    signal lb3data            : std_logic_vector(23 downto 0);
    signal rdCounter          : unsigned(8 downto 0);
    signal rd_line_buffer     : std_logic;
    signal totalPixelCounter  : unsigned(11 downto 0);
    type state_type is (IDLE, RD_BUFFER);
    signal rdState            : state_type;

   

begin

    o_pixel_data_valid <= rd_line_buffer;

   
    totalPixelCounter_process: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                totalPixelCounter <= (others => '0');
            else
                if i_pixel_data_valid = '1' and rd_line_buffer = '0' then
                    totalPixelCounter <= totalPixelCounter + 1;
                elsif i_pixel_data_valid = '0' and rd_line_buffer = '1' then
                    totalPixelCounter <= totalPixelCounter - 1;
                end if;
            end if;
        end if;
    end process;

   
    readStateMachine_process: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                rdState <= IDLE;
                rd_line_buffer <= '0';
                o_intr <= '0';
            else
                case rdState is
                    when IDLE =>
                        o_intr <= '0';
                        if totalPixelCounter >= 1536 then
                            rd_line_buffer <= '1';
                            rdState <= RD_BUFFER;
                        end if;
                    when RD_BUFFER =>
                        if rdCounter = 511 then
                            rdState <= IDLE;
                            rd_line_buffer <= '0';
                            o_intr <= '1';
                        end if;
                end case;
            end if;
        end if;
    end process;

  
    pixelCounter_process: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                pixelCounter <= (others => '0');
            elsif i_pixel_data_valid = '1' then
                pixelCounter <= pixelCounter + 1;
            end if;
        end if;
    end process;

 
       
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                currentWrLineBuffer <= (others => '0');
            elsif pixelCounter = 511 and i_pixel_data_valid = '1' then
                currentWrLineBuffer <= currentWrLineBuffer + 1;
            end if;
        end if;
    end process;

    
    lineBuffDataValid_process: process(currentWrLineBuffer, i_pixel_data_valid)
    begin
        lineBuffDataValid <= (others => '0');
        lineBuffDataValid(to_integer(currentWrLineBuffer)) <= i_pixel_data_valid;
    end process;

   
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                rdCounter <= (others => '0');
            elsif rd_line_buffer = '1' then
                rdCounter <= rdCounter + 1;
            end if;
        end if;
    end process;

    
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                currentRdLineBuffer <= (others => '0');
            elsif rdCounter = 511 and rd_line_buffer = '1' then
                currentRdLineBuffer <= currentRdLineBuffer + 1;
            end if;
        end if;
    end process;
    

  
        o_pixel_data_process: process(currentRdLineBuffer)
        begin
            case currentRdLineBuffer is
                when "00" =>
                    o_pixel_data <= lb2data & lb1data & lb0data;
                when "01" =>
                    o_pixel_data <= lb3data & lb2data & lb1data;
                when "10" =>
                    o_pixel_data <= lb0data & lb3data & lb2data;
                when others =>
                    o_pixel_data <= lb1data & lb0data & lb3data;
            end case;
        end process;

 
    lineBuffRdData_process: process(currentRdLineBuffer, rd_line_buffer)
    begin
        case currentRdLineBuffer is
            when "00" =>
                lineBuffRdData(0) <= rd_line_buffer;
                lineBuffRdData(1) <= rd_line_buffer;
                lineBuffRdData(2) <= rd_line_buffer;
                lineBuffRdData(3) <= '0';
            when "01" =>
                lineBuffRdData(0) <= '0';
                lineBuffRdData(1) <= rd_line_buffer;
                lineBuffRdData(2) <= rd_line_buffer;
                lineBuffRdData(3) <= rd_line_buffer;
            when "10" =>
                lineBuffRdData(0) <= rd_line_buffer;
                lineBuffRdData(1) <= '0';
                lineBuffRdData(2) <= rd_line_buffer;
                lineBuffRdData(3) <= rd_line_buffer;
            when others =>
                lineBuffRdData(0) <= rd_line_buffer;
                lineBuffRdData(1) <= rd_line_buffer;
                lineBuffRdData(2) <= '0';
                lineBuffRdData(3) <= rd_line_buffer;
        end case;
    end process;

    
        -- Instantiation of lineBuffer components
        -- Ensure the entity and architecture names match your design
        lB0: entity work.lineBuffer
            port map(
                i_clk => i_clk,
                i_rst => i_rst,
                i_data => i_pixel_data,
                i_data_valid => lineBuffDataValid(0),
                o_data => lb0data,
                i_rd_data => lineBuffRdData(0)
            );
            
        lB1: entity work.lineBuffer
            port map(
                i_clk => i_clk,
                i_rst => i_rst,
                i_data => i_pixel_data,
                i_data_valid => lineBuffDataValid(1),
                o_data => lb1data,
                i_rd_data => lineBuffRdData(1)
            );
            
        lB2: entity work.lineBuffer
            port map(
                i_clk => i_clk,
                i_rst => i_rst,
                i_data => i_pixel_data,
                i_data_valid => lineBuffDataValid(2),
                o_data => lb2data,
                i_rd_data => lineBuffRdData(2)
            );
            
        lB3: entity work.lineBuffer
            port map(
                i_clk => i_clk,
                i_rst => i_rst,
                i_data => i_pixel_data,
                i_data_valid => lineBuffDataValid(3),
                o_data => lb3data,
                i_rd_data => lineBuffRdData(3)
            );


end Behavioral;

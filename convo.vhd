library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity convolution is
    Port ( i_clk, control : in STD_LOGIC;
           i_pixel_data : in STD_LOGIC_VECTOR (71 downto 0);
           i_pixel_data_valid : in STD_LOGIC;
           o_convolved_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_convolved_data_valid : out STD_LOGIC);
end convolution;

architecture Behavioral of convolution is
    type kernel1_type is array(0 to 8) of signed(7 downto 0);
    type multData1_type is array(0 to 8) of signed(16 downto 0);
     
    signal kernel1, kernel2 : kernel1_type;
    signal multData1,multData2 : multData1_type;
    signal  sumData1, sumData2 : signed(16 downto 0);
    signal multDataValid, sumDataValid, convolved_data_int_valid : STD_LOGIC;
  

    signal conc_i_pixel_data0 : STD_LOGIC_VECTOR(8 downto 0);
    signal conc_i_pixel_data1 : STD_LOGIC_VECTOR(8 downto 0);
    signal conc_i_pixel_data2 : STD_LOGIC_VECTOR(8 downto 0);
    signal conc_i_pixel_data3 : STD_LOGIC_VECTOR(8 downto 0);
    signal conc_i_pixel_data4 : STD_LOGIC_VECTOR(8 downto 0);
    signal conc_i_pixel_data5 : STD_LOGIC_VECTOR(8 downto 0);
    signal conc_i_pixel_data6 : STD_LOGIC_VECTOR(8 downto 0);
    signal conc_i_pixel_data7 : STD_LOGIC_VECTOR(8 downto 0);
    signal conc_i_pixel_data8 : STD_LOGIC_VECTOR(8 downto 0);
    

    
begin
    
        kernel1(0) <= "11111111";
        kernel1(1) <= "11111111";
        kernel1(2) <= "11111111";
        kernel1(3) <= "11111111";
        kernel1(4) <= "00001000";
        kernel1(5) <= "11111111";
        kernel1(6) <= "11111111";
        kernel1(7) <= "11111111";
        kernel1(8) <= "11111111";
        
        kernel2(0) <= "00000000";
        kernel2(1) <= "11111111";
        kernel2(2) <= "00000000";
        kernel2(3) <= "11111111";
        kernel2(4) <= "00000101";
        kernel2(5) <= "11111111";
        kernel2(6) <= "00000000";
        kernel2(7) <= "11111111";
        kernel2(8) <= "00000000";
  
  conc_i_pixel_data0 <= "0" & i_pixel_data(7 downto 0);
  conc_i_pixel_data1 <= "0" & i_pixel_data(15 downto 8);
  conc_i_pixel_data2 <= "0" & i_pixel_data(23 downto 16);
  conc_i_pixel_data3 <= "0" & i_pixel_data(31 downto 24);
  conc_i_pixel_data4 <= "0" & i_pixel_data(39 downto 32);
  conc_i_pixel_data5 <= "0" & i_pixel_data(47 downto 40);
  conc_i_pixel_data6 <= "0" & i_pixel_data(55 downto 48);
  conc_i_pixel_data7 <= "0" & i_pixel_data(63 downto 56);
  conc_i_pixel_data8 <= "0" & i_pixel_data(71 downto 64);
  
  multData1(0) <= signed(kernel1(0)) * signed(conc_i_pixel_data0);
  multData1(1) <= signed(kernel1(1)) * signed(conc_i_pixel_data1);
  multData1(2) <= signed(kernel1(2)) * signed (conc_i_pixel_data2);
  multData1(3) <= signed(kernel1(3)) * signed(conc_i_pixel_data3);
  multData1(4) <= signed(kernel1(4)) * signed(conc_i_pixel_data4);
  multData1(5) <= signed(kernel1(5)) * signed(conc_i_pixel_data5);
  multData1(6) <= signed(kernel1(6)) * signed(conc_i_pixel_data6);
  multData1(7) <= signed(kernel1(7)) * signed(conc_i_pixel_data7);
  multData1(8) <= signed(kernel1(8)) * signed(conc_i_pixel_data8);
  


  
  multData2(0) <= signed(kernel2(0)) * signed(conc_i_pixel_data0);
  multData2(1) <= signed(kernel2(1)) * signed(conc_i_pixel_data1);
  multData2(2) <= signed(kernel2(2)) * signed(conc_i_pixel_data2);
  multData2(3) <= signed(kernel2(3)) * signed(conc_i_pixel_data3);
  multData2(4) <= signed(kernel2(4)) * signed(conc_i_pixel_data4);
  multData2(5) <= signed(kernel2(5)) * signed(conc_i_pixel_data5);
  multData2(6) <= signed(kernel2(6)) * signed(conc_i_pixel_data6);
  multData2(7) <= signed(kernel2(7)) * signed(conc_i_pixel_data7);
  multData2(8) <= signed(kernel2(8)) * signed(conc_i_pixel_data8);
 
 
sumData1 <=  multData1(0) + multData1(1) + multData1(2) + multData1(3) + multData1(4) + multData1(5) + multData1(6) + multData1(7) + multData1(8);
sumData2 <= multData2(0) + multData2(1) + multData2(2) + multData2(3) + multData2(4) + multData2(5) + multData2(6) + multData2(7) + multData2(8);

multDataValid <= i_pixel_data_valid;
sumDataValid <= multDataValid;
convolved_data_int_valid <= sumDataValid;

    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if control = '1' then
                o_convolved_data <= std_logic_vector(sumData1(7 downto 0)); -- white pixel
            else
                 o_convolved_data <= std_logic_vector(sumData2(7 downto 0));
            end if;
            o_convolved_data_valid <= convolved_data_int_valid;
        end if;
    end process;

end Behavioral;

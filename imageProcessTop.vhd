library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity imageProcessTop is
    Port ( 
        axi_clk       : in  std_logic;
        axi_reset_n   : in  std_logic;
        i_data_valid  : in  std_logic;
        i_data        : in  std_logic_vector(7 downto 0);
        o_data_ready  : out std_logic;
        o_data_valid  : out std_logic;
        o_data        : out std_logic_vector(7 downto 0);
        i_data_ready  : in  std_logic;
        o_intr        : out std_logic;
        i_control     : in std_logic

    );
end imageProcessTop;

architecture Behavioral of imageProcessTop is
    signal pixel_data          : std_logic_vector(71 downto 0);
    signal pixel_data_valid    : std_logic;
    signal axis_prog_full      : std_logic;
    signal convolved_data      : std_logic_vector(7 downto 0);
    signal convolved_data_valid: std_logic;
    signal inverted_axi_reset_n: std_logic;
    
COMPONENT outputBuffer1
      PORT (
        wr_rst_busy : OUT STD_LOGIC;
        rd_rst_busy : OUT STD_LOGIC;
        s_aclk : IN STD_LOGIC;
        s_aresetn : IN STD_LOGIC;
        s_axis_tvalid : IN STD_LOGIC;
        s_axis_tready : OUT STD_LOGIC;
        s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        m_axis_tvalid : OUT STD_LOGIC;
        m_axis_tready : IN STD_LOGIC;
        m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        axis_prog_full : OUT STD_LOGIC
      );
    END COMPONENT;

begin
    
    o_data_ready <= not axis_prog_full;
    inverted_axi_reset_n <= not axi_reset_n;

    IC: entity work.imageControl
        port map (
            i_clk              => axi_clk,
            i_rst              => inverted_axi_reset_n,
            i_pixel_data       => i_data,
            i_pixel_data_valid => i_data_valid,
            o_pixel_data       => pixel_data,
            o_pixel_data_valid => pixel_data_valid,
            o_intr             => o_intr
        );


    conv_inst: entity work.conv
        port map (
            i_clk               => axi_clk,
            control => i_control,
            i_pixel_data        => pixel_data,
            i_pixel_data_valid  => pixel_data_valid,
            o_convolved_data    => convolved_data,
            o_convolved_data_valid => convolved_data_valid
        );

   
    OB: outputBuffer1
        port map (
            wr_rst_busy    => open,
            rd_rst_busy    => open,
            s_aclk         => axi_clk,
            s_aresetn      => axi_reset_n,
            s_axis_tvalid  => convolved_data_valid,
            s_axis_tready  => open,
            s_axis_tdata   => convolved_data,
            m_axis_tvalid  => o_data_valid,
            m_axis_tready  => i_data_ready,
            m_axis_tdata   => o_data,
            axis_prog_full => axis_prog_full
        );

end Behavioral;

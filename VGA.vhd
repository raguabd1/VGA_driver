

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity Declaration
entity dataGen is
    Port (
        i_clk        : in  STD_LOGIC;
        i_reset_n    : in  STD_LOGIC;
        o_data       : out STD_LOGIC_VECTOR(23 downto 0);
        o_data_valid : out STD_LOGIC;
        i_data_ready : in  STD_LOGIC;
        o_sof        : out STD_LOGIC;
        o_eol        : out STD_LOGIC
    );
end dataGen;


architecture Behavioral of dataGen is

    -- Constants
    constant lineSize   : integer := 1920;
    constant frameSize  : integer := 1920 * 1080;

    -- States
    type state_type is (IDLE, SEND_DATA, END_LINE);
    signal state        : state_type := IDLE;
    
    -- Signals for counters
    signal linePixelCounter : integer range 0 to lineSize-1 := 0;
    signal dataCounter      : integer range 0 to frameSize-1 := 0;

begin

    -- Process to generate the output data
    process(i_clk, i_reset_n)
    begin
        if (i_reset_n = '0') then
            state               <= IDLE;
            linePixelCounter    <= 0;
            dataCounter         <= 0;
            o_data_valid        <= '0';
            o_sof               <= '0';
            o_eol               <= '0';
        elsif rising_edge(i_clk) then
            case state is
                when IDLE =>
                    o_sof <= '1';
                    o_data_valid <= '1';
                    state <= SEND_DATA;
                    
                when SEND_DATA =>
                    if (i_data_ready = '1') then
                        o_sof <= '0';
                        linePixelCounter <= linePixelCounter + 1;
                        dataCounter <= dataCounter + 1;
                    end if;
                    if (linePixelCounter = lineSize - 2) then
                        o_eol <= '1';
                        state <= END_LINE;
                    end if;
                    
                when END_LINE =>
                    if (i_data_ready = '1') then
                        o_eol <= '0';
                        linePixelCounter <= 0;
                        dataCounter <= dataCounter + 1;
                    end if;
                    if (dataCounter = frameSize - 1) then
                        state <= IDLE;
                        o_data_valid <= '0';
                        dataCounter <= 0;
                    else
                        state <= SEND_DATA;
                    end if;
            end case;
        end if;
    end process;

    -- Assign output data based on linePixelCounter
    process(linePixelCounter)
    begin
        if (linePixelCounter >= 0 and linePixelCounter < 640) then
            o_data <= x"0000FF";  -- Blue color
        elsif (linePixelCounter >= 640 and linePixelCounter < 1280) then
            o_data <= x"00FF00";  -- Green color
        else
            o_data <= x"FF0000";  -- Red color
        end if;
    end process;

end Behavioral;
